// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "./interfaces/ICrossFarmTypes.sol";
import "./interfaces/ICrossFarm.sol";

import "../session/SessionManager.sol";
import "../session/Node.sol";
import "../libraries/WireLibrary.sol";
import "../periphery/interfaces/IMaker.sol";
import "../periphery/interfaces/ITaker.sol";
import "./interfaces/ICrssToken.sol"; 
import "./interfaces/IXCrssToken.sol";
import "../core/interfaces/ICrossPair.sol";
import "./interfaces/ICrssReferral.sol";
import "./BaseRelayRecipient.sol";
import "../libraries/math/SafeMath.sol";
import "../libraries/FarmLibrary.sol";

import "../libraries/utils/TransferHelper.sol";
import "../libraries/CrossLibrary.sol";

import "hardhat/console.sol";

contract CrossFarm is Node, ICrossFarm, BaseRelayRecipient, SessionManager { 
    // Do not inherit from Ownable and Context, as they conflicts with BaseRelayRecipient at _mseSender().
    // Instead, implement them here, except _msgSender(). Context plays a role for that.

    //--------------------- Context, except _msgSender -----------------------
    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    //--------------------- Ownerble -----------------------------------------

    address private _owner;
    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "caller is not the owner");
        _;
    }
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    //================================================================


    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    //==================== super class data ===================
    mapping(address => Pair) public pairs;
    mapping(address => mapping(address => address)) public getPairQuick;

    FeeStores public override feeStores;
    mapping(SessionType => FeeRates) public override feeRates;

    //=========================================================

    uint256 constant vestMonths = 5;
    uint256 constant depositFeeLimit = 5000; // 5.0%

    uint256 public crssPerBlock;
    uint256 public bonusMultiplier;
    
    PoolInfo[] public poolInfo;
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;

    uint256 public totalAllocPoint;
    uint256 public startBlock;

    uint256 public lastPatrolDay;

    FarmFeeParams feeParams;

    IMigratorChef public migrator;

    string private constant sForbidden = "Forbidden";
    string private constant sZeroAddress = "Zero address";
    string private constant sInvalidPoolId = "Invalid pool id";
    string private constant sExceedsBalance = "Exceeds balance";
    string private constant sInvalidFee = "Invalid fee";
    string private constant sInconsistent = "Inconsistent";

    // modifier onlyOwner() {
    //     require(_msgSender() == owner(), "Caller must be owner");
    //     _;
    // }

    function getOwner() public view override virtual returns (address) {
        return owner();
    }
    modifier validPid(uint256 _pid) {
        require(_pid < poolInfo.length, sInvalidPoolId);
        _;
    }
    receive() external payable {}

    function informOfPair(address pair, address token0, address token1, address caller) public override virtual {
        super.informOfPair(pair, token0, token1, caller);
        pairs[pair] = Pair(token0, token1);
        getPairQuick[token0][token1] = pair;
        getPairQuick[token1][token0] = pair;
    }

   constructor(
        address crss,
        uint256 _crssPerBlock,
        uint256 _startBlock
    ) {
        _transferOwnership(_msgSender());  
        // This is the contrutor part of Ownable. Read the comments at the contract declaration.

       crssPerBlock = _crssPerBlock;

        require(block.number < _startBlock, sForbidden);
        startBlock = _startBlock;

        feeParams.crssReferral = address(0);
        feeParams.referralCommissionRate = 100; // 0.1%
        feeParams.nonVestBurnRate = 25000; // 25.0%
        feeParams.compoundFeeRate = 5000; // 5%
        feeParams.stakeholders = 0x23C6D84c09523032B08F9124A349760721aF64f6;

        add(1000, crss, true, 0);
        bonusMultiplier = 1;
    }

    function setNode(NodeType nodeType, address node, address caller) public override virtual {
        if (caller != address(this)) {  // let caller be address(0) when an actor initiats this loop
            if (nodeType == NodeType.Token) {
                sessionRegistrar = ISessionRegistrar(node);
                sessionFees = ISessionFees(node);
            }
            super.setNode(nodeType, node, caller);
        }
    }


    function setFeeStores(FeeStores memory _feeStores, address caller) public override virtual {
        super.setFeeStores(_feeStores, caller);
        WireLibrary.setFeeStores(feeStores, _feeStores);
        feeParams.treasury = _feeStores.treasury; // ---------------------- crooked.
        emit SetFeeStores(_feeStores);
    }

    function setFeeRates(SessionType _sessionType, FeeRates memory _feeRates, address caller) public override virtual {
        if (caller != address(this)) {
            WireLibrary.setFeeRates(_sessionType, feeRates, _feeRates);
            emit SetFeeRates(_sessionType, _feeRates);
            super.setFeeRates(_sessionType, _feeRates, caller);
        }
    }

    function _revertOnZeroAddress(address addr) internal pure {
        require(addr != address(0), sZeroAddress);
    }

    //==================== Fee Rates and Accounts ====================

    function setFeeParams(
       uint256 _referralCommissionRate,
        uint256 _nonVestBurnRate,
        address _stakeholders, 
        uint256 _compoundFeeRate) external onlyOwner {

      feeParams.referralCommissionRate = _referralCommissionRate;
        emit SetReferralCommissionRate(_referralCommissionRate);
        feeParams.nonVestBurnRate = _nonVestBurnRate;
        _revertOnZeroAddress(_stakeholders);
        feeParams.stakeholders = _stakeholders;
        feeParams.compoundFeeRate = _compoundFeeRate;
    }


    function setCrssReferral(address _crssReferral) external override virtual onlyOwner {
        feeParams.crssReferral = _crssReferral;
        emit SetcrssReferral(_crssReferral);
    }

    function setReferralCommissionRate(uint256 _referralCommissionRate) external override virtual onlyOwner {
        feeParams.referralCommissionRate = _referralCommissionRate;
        emit SetReferralCommissionRate(_referralCommissionRate);
    }

    ///==================== Farming ====================

    function updateMultiplier(uint256 multiplierNumber) public override onlyOwner {
        bonusMultiplier = multiplierNumber;

    }

    function poolLength() external view override returns (uint256) {
        return poolInfo.length;
    }

    /**
    * @dev Add a farming pool.
    */
    function add(
        uint256 _allocPoint,
        address _lpToken,
        bool _withUpdate,
        uint256 _depositFeeRate
    ) public override onlyOwner {
        require(_depositFeeRate <= depositFeeLimit, sInvalidFee);
        //Commented out for compensatoin. require(pairs[lpToken].token0 != address(0), "Invalid LP token");
        if (_withUpdate) massUpdatePools();

        IERC20 lpToken = IERC20(_lpToken);
        for (uint i = 0; i < poolInfo.length; i++) {
            require( poolInfo[i].lpToken != lpToken, "Used LP");
        }

        totalAllocPoint = FarmLibrary.addPool(_allocPoint, _lpToken, _depositFeeRate, startBlock, poolInfo);
    }

    /**
    * @dev Reset a farming pool, with new alloccation points and deposit fee rate.
    */
    function set(
        uint256 _pid,
        uint256 _allocPoint,
        bool _withUpdate,
        uint256 _depositFeeRate
    ) public override onlyOwner {
        require(_pid != 0, sInvalidPoolId);
        require(_depositFeeRate <= depositFeeLimit, sInvalidFee);
        if (_withUpdate) massUpdatePools();
        totalAllocPoint = FarmLibrary.setPool(poolInfo, _pid, _allocPoint, _depositFeeRate);
    }

    // Migrate lp token to another lp contract. Can be called by anyone. We trust that migrator contract is good.
    function migrate(uint256 _pid) public onlyOwner {
        require(address(migrator) != address(0), "migrate: no migrator");
        PoolInfo storage pool = poolInfo[_pid];
        IERC20 lpToken = pool.lpToken;
        uint256 bal = lpToken.balanceOf(address(this));
        lpToken.safeApprove(address(migrator), bal);
        IERC20 newLpToken = migrator.migrate(lpToken);
        require(bal == newLpToken.balanceOf(address(this)), "migrate: bad");
        pool.lpToken = newLpToken;
    }

    function getMultiplier(uint256 _from, uint256 _to) public view override returns (uint256) {
        return (_to - _from) * bonusMultiplier;
    }

    /**
    * @dev View function to see pending CRSSs on frontend.
    * Returns the current pending amount of Crss rewards for a give user.
    * Depneds on the user's current deposit.
    * The user has to collect the pending amount before further chaning their deposit, hense called 'pending'.
    */

    function massUpdatePools() public override {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            PoolInfo storage pool = poolInfo[pid];
            FarmLibrary.updatePool(pool, totalAllocPoint, crssPerBlock, bonusMultiplier, nodes);
        }
    }

    /**
    * @dev Update pool from outside.
    * Control its session.
    */
    function updatePool(uint256 _pid) public override validPid(_pid) {
        PoolInfo storage pool = poolInfo[_pid];
        FarmLibrary.updatePool(pool, totalAllocPoint, crssPerBlock, bonusMultiplier, nodes);
    }

    /**
    * @dev Change the referral ledger contract.
    */
    function changeReferrer(address user, address referrer) public override onlyOwner {
        require (referrer != user, "Invalid referrer");
        ICrssReferral(feeParams.crssReferral).recordReferral(user, referrer);
        emit ChangeReferer(user, referrer);
    }

    /**
    * Call coming from off-chain part. Supposed to be once a day.
    */

    function dailyPatrol() public override virtual returns (bool done) {
        uint256 newLastPatrolDay = FarmLibrary.dailyPatrol(poolInfo, totalAllocPoint, crssPerBlock, bonusMultiplier, feeParams, nodes, lastPatrolDay);
        if (newLastPatrolDay != 0) {
            lastPatrolDay = newLastPatrolDay;
            done = true;
        }
    }


    function getUserState(uint256 pid, address userAddress) external view validPid(pid)
    returns ( UserState memory) {
        return FarmLibrary.getUserState(userAddress, pid, poolInfo, userInfo, nodes, totalAllocPoint, crssPerBlock, bonusMultiplier, vestMonths);
    }

    function getVestList(uint256 pid, address userAddress) external view validPid(pid) returns(VestChunk[] memory) {
        return userInfo[pid][userAddress].vestList;
    }

    function getSubPooledCrss(uint256 pid, address userAddress) external view validPid(pid) returns(SubPooledCrss memory) {
        return FarmLibrary.getSubPooledCrss(poolInfo[pid], userInfo[pid][userAddress]);
    }

    // ============================== Session (Transaction) Area ==============================

    /** 
    * @dev Deposit LP tokens to gain reward emission.
    */
    function deposit(uint256 _pid, uint256 _amount) public override validPid(_pid) returns (uint256 deposited) {
        _openSession(SessionType.Deposit);
        bool patroled = dailyPatrol();

        address msgSender = _msgSender();
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msgSender];

        if (! patroled)
        FarmLibrary.finishRewardCycle(pool, user, msgSender, feeParams, nodes, totalAllocPoint, crssPerBlock, bonusMultiplier);

        if (_amount > 0) {
            _amount = FarmLibrary.pullFromUser(pool, msgSender, _amount);
            _amount -= _payTransactonFee(address(pool.lpToken), address(this), _amount, false);
            _amount -= FarmLibrary.payDepositFeeLPFromFarm(pool, _amount, feeStores);
            deposited = _amount;
            emit Deposit(_msgSender(), _pid, deposited);
            FarmLibrary.startRewardCycle(pool, user, deposited, feeParams, true); // false: addNotSubract
        }

        _closeSession();
    }

    /**
    * @dev Withdraw LP tokens deposited in the past.
    */
    function withdraw(uint256 _pid, uint256 _amount) public override validPid(_pid) returns (uint256 withdrawn){
        _openSession(SessionType.Withdraw);
        bool patroled = dailyPatrol();

        address msgSender = _msgSender();
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msgSender];

        if (! patroled)
        FarmLibrary.finishRewardCycle(pool, user, msgSender, feeParams, nodes, totalAllocPoint, crssPerBlock, bonusMultiplier);
        if (user.amount < _amount) _amount = user.amount;

        if (_amount > 0) {
            withdrawn = _amount;
            _amount -= _payTransactonFee(address(pool.lpToken), address(this), _amount, false);
            pool.lpToken.safeTransfer(msgSender, _amount);  // withdraw
            emit Withdraw(msgSender, _pid, withdrawn);
            FarmLibrary.startRewardCycle(pool, user, withdrawn, feeParams, false); // false: addNotSubract
        }

        _closeSession();
    }

    /**
    * @dev Withdraw a given amount of unlocked Crss amount form the user's vesting process.
    */

    function withdrawVest(uint256 _pid, uint256 _amount) public override validPid(_pid)  returns (uint256 withdrawn) {
        _openSession(SessionType.WithdrawVest); 
        bool patroled = dailyPatrol();

        address msgSender = _msgSender();
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msgSender];

        if (! patroled)
        FarmLibrary.finishRewardCycle(pool, user, msgSender, feeParams, nodes, totalAllocPoint, crssPerBlock, bonusMultiplier);

        if (_amount > 0) {
            _amount -= FarmLibrary.withdrawVestPieces(user.vestList, vestMonths, _amount);
            withdrawn = _amount;
            _amount -= _payTransactonFee(nodes.token, nodes.xToken, _amount, false);
            FarmLibrary.tolerableCrssTransferFromXTokenAccount(nodes.xToken, msgSender, _amount);
            emit WithdrawVest(msgSender, _pid, withdrawn);
        }

        _closeSession();
    }

    /**
    * @dev Withdraw a user's deposit in a given pool, without operning session, for emergency use.
    */

    function vestAccumulated(uint256 _pid) public override virtual validPid(_pid) returns (uint256 vested) {
        _openSession(SessionType.VestAccumulated);
        bool patroled = dailyPatrol();

        address msgSender = _msgSender();
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msgSender];
      
        if (! patroled)
        FarmLibrary.finishRewardCycle(pool, user, msgSender, feeParams, nodes, totalAllocPoint, crssPerBlock, bonusMultiplier);

        uint256 amount = user.accumulated;
        if (amount > 0) {
            amount -= _payTransactonFee(nodes.token, nodes.xToken, amount, false);
            user.vestList.push( VestChunk( { principal: amount, withdrawn: 0, startTime: block.timestamp } ) );
            vested = amount;
            user.accumulated = 0;
            emit VestAccumulated(msgSender, _pid, vested);
        }

        _closeSession();
    }

    // function compoundAccumulated(uint256 _pid) public override virtual validPid(_pid) returns (uint256 compounded) {
    //     _openSession(SessionType.CompoundAccumulated);
    //     bool patroled = dailyPatrol();

    //     address msgSender = _msgSender();
    //     PoolInfo storage pool = poolInfo[_pid];
    //     UserInfo storage user = userInfo[_pid][msgSender];

    //     if (! patroled)
    //     FarmLibrary.finishRewardCycle(pool, user, msgSender, feeParams, nodes, totalAllocPoint, crssPerBlock, bonusMultiplier);

    //     uint256 amount = user.accumulated;
    //     uint256 newLpAmount;
    //     if (amount > 0) {
    //         amount -= _payTransactonFee(nodes.token, nodes.xToken, amount, false);
    //         amount -= FarmLibrary.payCompoundFee(nodes.token, feeParams, amount, nodes);
    //         compounded = amount;
    //         newLpAmount = FarmLibrary.changeCrssInXTokenToLpInFarm(address(pool.lpToken), nodes, amount, feeParams.treasury);
    //         FarmLibrary.startRewardCycle(pool, user, newLpAmount, true);  // true: addNotSubract
    //         user.accumulated = 0;
    //         emit CompoundAccumulated(msgSender, _pid, compounded, newLpAmount);
    //     }    
    //     _closeSession();
    // }

    function harvestAccumulated(uint256 _pid) public override virtual validPid(_pid) returns (uint256 harvested) {
        _openSession(SessionType.HarvestAccumulated);
        bool patroled = dailyPatrol();

        address msgSender = _msgSender();
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msgSender];

        if (! patroled)
        FarmLibrary.finishRewardCycle(pool, user, msgSender, feeParams, nodes, totalAllocPoint, crssPerBlock, bonusMultiplier);

        uint256 amount = user.accumulated;
        if (amount > 0) {
            amount -= _payTransactonFee(nodes.token, nodes.xToken, amount, false);
            harvested = amount;
            FarmLibrary.tolerableCrssTransferFromXTokenAccount(nodes.xToken, msgSender, amount);
            user.accumulated = 0;
            emit HarvestAccumulated(msgSender, _pid, amount);
        }

        _closeSession();
    }

    function stakeAccumulated(uint256 _pid) public override virtual validPid(_pid) returns (uint256 staked) {
        _openSession(SessionType.StakeAccumulated);
        bool patroled = dailyPatrol();

        address msgSender = _msgSender();
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msgSender];

        if (! patroled)
        FarmLibrary.finishRewardCycle(pool, user, msgSender, feeParams, nodes, totalAllocPoint, crssPerBlock, bonusMultiplier);

        uint256 amount = user.accumulated;
        if (amount > 0) {
            amount -= _payTransactonFee(nodes.token, nodes.xToken, amount, false);
            PoolInfo storage pool = poolInfo[0];
            UserInfo storage user = userInfo[0][msgSender];
            FarmLibrary.finishRewardCycle(pool, user, msgSender, feeParams, nodes, totalAllocPoint, crssPerBlock, bonusMultiplier);
            uint256 balance0 = IERC20(nodes.token).balanceOf(address(this));
            FarmLibrary.tolerableCrssTransferFromXTokenAccount(nodes.xToken, address(this), amount);
            amount = IERC20(nodes.token).balanceOf(address(this)) - balance0;           
            amount -= FarmLibrary.payDepositFeeLPFromFarm(pool, amount, feeStores);
            staked = amount;
            FarmLibrary.startRewardCycle(pool, user, staked, feeParams, true); // false: addNotSubract
            user.accumulated = 0;
            emit StakeAccumulated(msgSender, _pid, amount);
        }

        _closeSession();
    }

    function emergencyWithdraw(uint256 _pid) public override validPid(_pid) {
        _openSession(SessionType.EmergencyWithdraw);

        address msgSender = _msgSender();
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msgSender];

        // give up: FarmLibrary.finishRewardCycle(pool, user, msgSender, feeParams, nodes, totalAllocPoint, crssPerBlock, bonusMultiplier);
        uint256 amount = user.amount;

        if (amount > 0) {
            uint256 withdrawn = amount;
            pool.lpToken.safeTransfer(msgSender, amount);  // withdraw
            FarmLibrary.startRewardCycle(pool, user, withdrawn, feeParams, false); // false: addNotSubract
            emit EmergencyWithdraw(msgSender, _pid, withdrawn);
        }

        _closeSession();
    }

    /**
    * @dev Take all accumulated Crss rewards, across the given list of pool, of the calling user to their wallet.
    */
    function massHarvestRewards() public override virtual returns (uint256 rewards) {
        _openSession(SessionType.MassHarvestRewards);
        dailyPatrol();

        address msgSender = _msgSender();

        uint256 amount = FarmLibrary.collectAccumulated(msgSender, poolInfo, userInfo, feeParams, nodes, totalAllocPoint, crssPerBlock, bonusMultiplier);
        if (amount > 0) {
            rewards = amount;
            amount -= _payTransactonFee(nodes.token, nodes.xToken, amount, false);
            FarmLibrary.tolerableCrssTransferFromXTokenAccount(nodes.xToken, msgSender, amount);
            emit MassHarvestRewards(msgSender, rewards);
        }

        _closeSession();
    }

    /**
    * @dev Stake all accumulated Crss rewards, accross the given list of pools, of the calling user to the first Crss staking pool.
    */
    function massStakeRewards() external override virtual returns (uint256 rewards) {
        _openSession(SessionType.MassStakeRewards);
        dailyPatrol();

        address msgSender = _msgSender();
        uint256 amount = FarmLibrary.collectAccumulated(msgSender, poolInfo, userInfo, feeParams, nodes, totalAllocPoint, crssPerBlock, bonusMultiplier);
        if (amount > 0) {
            amount -= _payTransactonFee(nodes.token, nodes.xToken, amount, false);
            PoolInfo storage pool = poolInfo[0];
            amount -= FarmLibrary.payDepositFeeCrssFromXCrss(pool, nodes.xToken, amount, feeStores);
            uint256 balance0 = IERC20(nodes.token).balanceOf(address(this));
            FarmLibrary.tolerableCrssTransferFromXTokenAccount(nodes.xToken, address(this), amount);
            amount = IERC20(nodes.token).balanceOf(address(this)) - balance0;

            rewards = amount;

            UserInfo storage user = userInfo[0][msgSender];
            FarmLibrary.startRewardCycle(pool, user, rewards, feeParams, true); // false: addNotSubract
            emit MassStakeRewards(msgSender, rewards);
        }

        _closeSession();
    }

    function massCompoundRewards() external override virtual {
        _openSession(SessionType.MassCompoundRewards);
        dailyPatrol();

        address msgSender = _msgSender();
        (uint256 totalCompounded, )
        = FarmLibrary.massCompoundRewards(msgSender, poolInfo, userInfo, nodes, feeParams);
        emit MassCompoundRewards(msgSender, totalCompounded);

        _closeSession();
    }

    /**
    * @dev Change users' auto option.
    */
    function switchCollectOption(uint256 _pid, CollectOption newOption) public override validPid(_pid)  {
        _openSession(SessionType.SwitchCollectOption);

        address msgSender = _msgSender();
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msgSender];

        if (FarmLibrary.switchCollectOption(pool, user, newOption,
        msgSender, feeParams, nodes, totalAllocPoint, crssPerBlock, bonusMultiplier
        )) {
            emit SwitchCollectOption(msgSender, _pid, newOption);
        }

        _closeSession();
    }


    function _payTransactonFee(address payerToken, address payerAddress, uint256 principal, bool fromAllowance)
    internal virtual returns (uint256 feesPaid) {

        if (sessionParams.isOriginAction && principal > 0) {
            if (address(payerToken) == nodes.token) {
                feesPaid = _payFeeCrss(payerAddress, principal, feeRates[sessionParams.sessionType], fromAllowance);
            } else {
                feesPaid = CrossLibrary.payFeeLP(payerToken, principal, feeRates[sessionParams.sessionType], feeStores); // payerAddress: address(this).
            }
        }
    }

    //==============================   ==============================

 /**
    * @dev Set the trusted forwarder who works as a middle man between client and this contract.
    * The forwarder verifies client signature, append client's address to call data, and forward the client's call.
    * This contract, as a BaseRelayRecipient, calls _msgSender() to get the appended client address, 
    * if msg.sender matches the trusted forwarder. If not, msg.sender itself is returned.
    * This way, the trusted forwader can pay gas fee for the client.
    * See https://eips.ethereum.org/EIPS/eip-2771 for more.
    */
    function setTrustedForwarder(address _trustedForwarder) external onlyOwner {
        require(_trustedForwarder != address(0), sForbidden);
        trustedForwarder = _trustedForwarder;
        emit SetTrustedForwarder(_trustedForwarder);
    }

    // Set the migrator contract. Can only be called by the owner.
    function setMigrator(IMigratorChef _migrator) public onlyOwner {
        migrator = _migrator;
    }
}
