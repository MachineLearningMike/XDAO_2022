// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./interfaces/ITGRToken.sol";
import "../session/SessionRegistrar.sol";
import "../session/SessionManager.sol";
import "../session/SessionFees.sol";
import "../session/Node.sol";
import "../libraries/WireLib.sol";
import "../periphery/interfaces/IMaker.sol";
import "../periphery/interfaces/ITaker.sol";
import "../core/interfaces/IXDAOFactory.sol"; 
import "../core/interfaces/IXDAOPair.sol";
import "../farm/interfaces/IXDAOFarm.sol";
import "../libraries/math/SafeMath.sol";
import "../libraries/GovLib.sol";

import "hardhat/console.sol";

// TGRToken with Governance.
contract TGRToken is Node, Ownable, ITGRToken, SessionRegistrar, SessionFees, SessionManager {
    using SafeMath for uint256;

    //==================== super class data ===================
    mapping(address => Pair) public pairs;
    mapping(address => mapping(address => address)) public getPairQuick;

    FeeStores public feeStores;
    mapping(SessionType => FeeRates) public feeRates;

    //==================== ERC20 core data ====================
    string private constant _name = "XDAO Token";
    string private constant _symbol = "TGR";
    uint8 private constant _decimals = 18;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;

    //==================== Constants ====================
    string private constant sForbidden = "Forbidden";
    string private constant sZeroAddress = "Zero address";
    string private constant sExceedsBalance = "Exceeds balance";
    uint256 public constant override maxSupply = 50 * 1e6 * 10**_decimals;

    //==================== Transfer control attributes ====================
    struct TransferAmountSession {
        uint256 sent;
        uint256 received;
        uint256 session;
    }
    mapping(address => TransferAmountSession) accTransferAmountSession;
    uint256 public override maxTransferAmountRate; // rate based on FeeMagnifier.
    uint256 public maxTransferAmount;
    address[] transferUsers;

    //==================== Governance ====================
    mapping(address => address) internal _delegates;
    struct Checkpoint {
        uint32 fromBlock;
        uint256 votes;
    }
    mapping(address => mapping(uint32 => Checkpoint)) public checkpoints;
    mapping(address => uint32) public numCheckpoints;
    bytes32 public constant DOMAIN_TYPEHASH =
        keccak256("EIP712Domain(string name,uint256 chainId,address verifyingContract)");
    bytes32 public constant DELEGATION_TYPEHASH =
        keccak256("Delegation(address delegatee,uint256 nonce,uint256 expiry)");
    mapping(address => uint256) public nonces;
    event DelegateChanged(address indexed delegator, address indexed fromDelegate, address indexed toDelegate);
    event DelegateVotesChanged(address indexed delegate, uint256 previousBalance, uint256 newBalance);
    event SwapAndLiquify(uint256 crssPart, uint256 crssForEthPart, uint256 ethPart, uint256 liquidity);

    //=================== TGR =========================
    
    struct User {
        uint256 debtToPendingBurn;        
    }
    mapping(address => User) Users;

    //=================================================
    receive() external payable {}

    function informOfPair(address pair, address token0, address token1, address caller) public override virtual {
        super.informOfPair(pair, token0, token1, caller);
        pairs[pair] = Pair(token0, token1);
        getPairQuick[token0][token1] = pair;
        getPairQuick[token1][token0] = pair;
    }

    address constant zero_address = 0x0000000000000000000000000000000000000000;

    address admin;
    address alice;
    address bob;
    address carol;

    address tgrftm; // tgr_bnb
    address tgrhtz; // tgr_mck
    address votes; // tgr_mck2

    struct Pulse {
        uint256 lastestTime;
        uint256 cycle;
        uint256 decayRate;
        address account;
        uint256 accDecayPerShare;
        uint256 sum_balances;
        uint256 pending_burn;
    }

    Pulse public lp_reward;
    Pulse public vote_burn;
    Pulse public user_burn;

    constructor() Ownable() {
        GovLib.test();

        sessionRegistrar = ISessionRegistrar(address(this));
        sessionFees = ISessionFees(address(this));                               

        maxTransferAmountRate = 5000; // 5%

        // Mint 1e6 TGR to the caller for testing - MUST BE REMOVED WHEN DEPLOY
        _mint(_msgSender(), 1e6 * 10 ** _decimals);
        _moveDelegates(address(0), _delegates[_msgSender()], 1e6 * 10 ** _decimals);

        //--------- test users ---------
        admin = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
        alice = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8;
        bob = 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC;
        carol = 0x90F79bf6EB2c4f870365E785982E1f101E93b906;

        tgrftm = 0x97713c3c752F3bb80CBFAaCC6830a36A72Eb6E97; // tgr_bnb
        tgrhtz = 0x3924A2cf72d190023667609Dd91e70Ed11127D78; // tgr_mck
        votes = 0x02EED5Ac83f1c3D1624c0437c9E682e83E95BcFf; // tgr_mck2

        lp_reward = Pulse(tgrftm, 0, 2 seconds, 690, 0, 0, 0);
        vote_burn = Pulse(votes, 0, 2 seconds, 70, 0, 0, 0);
        user_burn = Pulse(zero_address, 0, 4 seconds, 777, 0, 0, 0);

    }

    //------------------- pulses ------------------------------------


    function _getDecay(Pulse pulse) internal pure returns (uint256 decayPer1e12) {
        // pulse.lastTime, pulse.cycle, pulse.decayRate
    }

    function _checkForConsistency() internal view {
        assert (user_burn.sum_balances + _balances[tgrftm] + _balances[tgrhtz] + _balances[votes] == _totalSupply);
        assert (_balance[owner] + _balances[alice] + _balances[bob] + _balances[carol] == user_burn.sum_balances);
        // totalSupply = _totalSupply - user_burn.pending_burn
        // balanceOf(account) = _isUserAccount(account) ? _balances[account] * user_burn.accDecayPerShare / 1e12 - Users[account].debtToPendingBurn : _balances[account]
        // user_burn.accDecayPerShare += new_pending_burn * 1e12 / user_burn.sum_balances;
        // transfer(sender, recipient, amount)
        // if _isUserAccount(sender, recipient) 
            // settlw with pending_burn, by using Users[account].debtToPendingBurn
            // transfer ...
            // 
    }

    function _isUserAccount(address account) internal view returns (bool yes) {
        yes = account != tgrftm && account != tgrhtz && account != votes;

        // Assumes the following are the only non-user TGR accounts.
        // lp_reward.account = tgrftm
        // vote_burn.account = votes: the share-based staking account used to keep all voting tgr tokens.
        // tgrhtz
    }

    function pulse_lp_reward() external {
        // 0.69% of XDAO/FTM LP has the XDAO side sold for FTM, 
        // then the FTM is used to buy HTZ which is added to XDAO lps airdrop rewards every 12 hours.

        uint256 decayPer1e12 = _getDecay(lp_reward);
        // Use decayPer12 portion of tgrftm pool to obtain FTM to buy HTZ tokens at the htzftm pool, then add them to airdrop rewards.
        // TGR/FTM price falls and HTZ/FTM price rises, at their respective pools.

        lp_reward.latestTime = block.timestamp;
    }

    function pulse_vote_burn() external {
        // 0.07% of tokens in the Agency dapp actively being used for voting burned every 12 hours.

        uint256 decayPer1e12 = _getDecay(vote_burn);
        // burn decayPer1e12 portion of vote_burn.account's balance. vote_burn.account should be share-based staking account.

        vote_burn.latestTime = block.timestamp;
    }

    function pulse_user_burn() external {
        // 0.777% of tokens(not in Cyberswap/Agency dapp) burned each 24 hours from users wallets.

        // Interpretation: TGR tokens not in Cyberswap accounts, which are tgrftm and tgrhtz, and not in Agency account, 
        // which is the votes account, will be burned at the above rate and interval.

        uint256 decayPer1e12 = _getDecay(user_burn);
        if (decayPer1e12 > 0) {
            // nominally burn all user accounts' balance.
            uint256 true_value = user_burn.sum_balance - user_burn.pending_burn;
            uint256 new_burn = true_value * decayPer1e12 / 1e12;
            user_burn.pending_burn += new_burn;
            user_burn.accBurnPerShare += new_burn * 1e12 / user_burn.sum_balances;

            user_burn.latestTime = block.timestamp;
        }
    }

    function _balanceOf(address account) internal view returns (uint256 balance) {
        //uint256 pendingBurn = accountInfo[account].burnShare * user_burn.accBurnPerShare - accountInfo[account].burnDebt;
        uint256 pendingBurn = _balances[account] * user_burn.accBurnPerShare - accountInfo[account].burnDebt;
        balance = _balances[account] - pendingBurn;
    }

    function _settleWithPendingBurn(address account) internal { // user account only
        uint256 pendingBurn = _balances[account] * user_burn.accBurnPerShare - Users[account].debtToPendingBurn;
        if (pendingBurn > 0) {
            user_burn.pending_burn -= pendingBurn;
            _balances[account] -= pendingBurn;
            user_burn.sum_balances -= pendingBurn;
            Users[account].debtToPendingBurn =  _balances[account] * user_burn.accBurnPerShare
        }
    }

    function _changeBalance(address account, uint256 amount, bool addNotSubtract) internal { // user account only
        _settleWithPendingBurn(account);
        _balances[account] += addNotSubtract ? amount : - amount;
        Users[account].debtToPendingBurn =  _balances[account] * user_burn.accBurnPerShare;

    } 

    //========== Modifiers. Some of them required by super classes ====================
    modifier onlySessionManager override virtual {
        require(msg.sender == address(this) 
        || msg.sender == nodes.maker  
        || msg.sender == nodes.taker 
        || msg.sender == nodes.farm, sForbidden);
        _;
    }

    function getOwner() public view override returns (address) {
        return owner();
    }

    modifier dsManagersOnly override virtual {
        address msgSender = _msgSender();
        require(msgSender == nodes.maker 
        || msgSender == nodes.taker 
        || msgSender == nodes.farm
        || msgSender == nodes.repay
        || msgSender == address(this), sForbidden);
        _;
    }

    function setFeeStores(FeeStores memory _feeStores, address caller) public override virtual {
        super.setFeeStores(_feeStores, caller);
        WireLib.setFeeStores(feeStores, _feeStores);
        emit SetFeeStores(_feeStores);
    }

    function setFeeRates(SessionType _sessionType, FeeRates memory _feeRates, address caller) public override virtual {
        if (caller != address(this)) {
            WireLib.setFeeRates(_sessionType, feeRates, _feeRates);
            emit SetFeeRates(_sessionType, _feeRates);
            super.setFeeRates(_sessionType, _feeRates, caller);
        }
    }

    //==================== Basic ERC20 functions ====================
    function name() public view virtual returns (string memory) {
        return _name;
    }

    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override virtual returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override virtual returns (uint256) {
        return _balanceOf(account);
    }


    //==================== Intrinsic + business internal logic ====================

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {}

    function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual {}

    function _mint(address to, uint256 amount) internal virtual {
        require(to != address(0), sZeroAddress);

        _beforeTokenTransfer(address(0), to, amount);
        _totalSupply += amount;
        _changeBalance(to, amount, true);
        _afterTokenTransfer(address(0), to, amount);

        emit Transfer(address(0), to, amount);
    }

    function _burn(address from, uint256 amount) internal virtual {
        require(from != address(0), sZeroAddress);
        uint256 accountBalance = _balanceOf(account);
        require(accountBalance >= amount, sExceedsBalance);

        _beforeTokenTransfer(from, address(0), amount);
        _changeBalance(from, amount, false);
        _totalSupply -= amount;
        _afterTokenTransfer(from, address(0), amount);
        

        emit Transfer(from, address(0), amount);
    }

    function _bury(address from, uint256 amount) internal virtual {
        require(from != address(0), sZeroAddress);
        uint256 accountBalance = _balanceOf(from);
        require(accountBalance >= amount, sExceedsBalance);

        _beforeTokenTransfer(from, address(0), amount);
        _changeBalance(from, amount, false);
        _afterTokenTransfer(from, address(0), amount);

        emit Transfer(from, address(0), amount);    
        //s[address(0)], amount);
    }

    /**
    * @dev Implements the business logic of the tansfer and transferFrom funcitons.
    * Collect transfer fee if the calling transfer functions are a top session, 
    * or, equivalently, an external actor invoked the transfer.
    * If the transfer is 100% of transfer amount if  external actor wants to transfer to a pool created by XDAOFactory.
    */
    function _transferHub(address sender, address recipient, uint256 amount) internal virtual {
        _openSession(SessionType.Transfer);

        _refreshBalance(sender);
        _refreshBalance(recipient);

        _limitTransferPerSession(sender, recipient, amount);

        if (sessionParams.isOriginAction) { // transfer call coming from external actors.
            FeeRates memory rates;
            if (pairs[recipient].token0 != address(0)) { // An injection detected!
                rates = FeeRates( uint32(FeeMagnifier), 0, 0, 0 ); // 100% fee.
            } else {
                if (pairs[sender].token0 != address(0) 
                || pairs[recipient].token0 != address(0) 
                || sender == address(this) 
                || recipient == address(this)) {
                    rates = FeeRates(0, 0, 0, 0);
                } else {
                    rates = feeRates[SessionType.Transfer];
                }
            }

            amount -= _payFeeTGR(sender, amount, rates, false); // Free of nested recurssion
        }
        if (amount > 0) {
            _transfer(sender, recipient, amount);
            _moveDelegates(_delegates[sender], _delegates[recipient], amount);
        }

        _closeSession();
    }


    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), sZeroAddress);
        require(recipient != address(0), sZeroAddress);
        uint256 senderBalance = _balanceOf(sender);
        require(senderBalance >= amount, sExceedsBalance);
        //_beforeTokenTransfer(sender, recipient, amount);
        _changeFreshBalance(sender, amount, false);
        _changeFreshBalance(recipient, amount, true);
        //_afterTokenTransfer(sender, recipient, amount);

        emit Transfer(sender, recipient, amount);
    }

    function _approve(
        address _owner,
        address _spender,
        uint256 _amount
    ) internal virtual {
        require(_owner != address(0), sZeroAddress);
        require(_spender != address(0), sZeroAddress);
        _allowances[_owner][_spender] = _amount;
        emit Approval(_owner, _spender, _amount);
    }

   function _increaseAllowance(address _owner, address _spender, uint256 addedValue) internal virtual returns (bool) {
        require(_owner != address(0), sZeroAddress);
        _approve(_owner, _spender, _allowances[_owner][_spender] + addedValue);
        return true;
    }

    function _decreaseAllowance(address _owner, address _spender, uint256 subtractedValue) public virtual returns (bool) {
        require(_owner != address(0), sZeroAddress);
        _approve(_owner, _spender, _allowances[_owner][_spender] - subtractedValue);
        return true;
    }


    //==================== Main ERC20 funcitons, working on intrinsic + business internal logic ====================
    function mint(address to, uint256 amount) public override {
        require(_totalSupply + amount <= maxSupply, "Exceed Max Supply");
        require(_msgSender() == nodes.farm || _msgSender() == nodes.repay, sForbidden);
        _mint(to, amount);
        _moveDelegates(address(0), _delegates[to], amount);
    }

    function burn(address from, uint256 amount) public override {
        require(_msgSender() == nodes.farm || _msgSender() == nodes.repay, sForbidden);
        _burn(from, amount);
        _moveDelegates(_delegates[from], _delegates[address(0)], amount);
    }

    function bury(address from, uint256 amount) public override {
        require(_msgSender() == nodes.farm, sForbidden);
        _bury(from, amount);
        _moveDelegates(_delegates[from], _delegates[address(0)], amount);
    }

    function transfer(address recipient, uint256 amount) public override virtual returns (bool) {
        _transferHub(_msgSender(), recipient, amount);
        return true;
    }

    function tolerableTransfer(
        address from,
        address to,
        uint256 value
    ) external override virtual returns (bool) {
        require(_msgSender() == nodes.farm || _msgSender() == nodes.repay , "Forbidden");
        if ( value > _balanceOf(from) ) value = _balanceOf(from);
        _transferHub(_msgSender(), to, value);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override virtual returns (bool) {
        if (sender != _msgSender()) {
            uint256 currentAllowance = _allowances[sender][_msgSender()];
            require(currentAllowance >= amount, "Transfer exceeds allowance");
            _approve(sender, _msgSender(), currentAllowance - amount);
        }
        _transferHub(sender, recipient, amount); // No guarentee it doesn't make a change to _allowances. Revert if it fails.

        return true;
    }

    function allowance(address _owner, address _spender) public view override virtual returns (uint256) {
        return _allowances[_owner][_spender];
    }

    function approve(address spender, uint256 amount) public override virtual returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        return _increaseAllowance(_msgSender(), spender, addedValue);
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        return _decreaseAllowance(_msgSender(), spender, subtractedValue);
    }

    //==================== Business logic ====================

    function changeMaxTransferAmountRate(uint _maxTransferAmountRate) external override virtual  onlyOwner {
        require(FeeMagnifier / 1000 <= _maxTransferAmountRate   // 0.1% totalSupply <= maxTransferRate
        && _maxTransferAmountRate <= FeeMagnifier / 20,        // maxTransferRate <= 5.0% totalSupply
        "maxTransferAmountRate out of range");
        maxTransferAmountRate = _maxTransferAmountRate;
    }

    /**
    * @dev msg.sender collects fees from payer, only called by sesison managers - this, maker, taker, and farm.
    * fromAllowance: whether the fee should be subtracted from the allowance that the payer approved to the msg.caller.
    * develp fee is paid to develop account
    * buyback fee is paid to buyback account
    * liquidity fee is liqufied to the TGR/Bnb pool.
    * If liquidity fees are accumulated to a certain degree, they are liquified.
    */
    function payFeeTGRLogic(address payer, uint256 principal, FeeRates calldata rates, bool fromAllowance ) 
    public override virtual onlySessionManager returns (uint256 feesPaid) {
        if (principal != 0) {
            if (rates.develop != 0) {
                feesPaid += _payFeeImplementation(payer, principal, rates.develop, feeStores.develop, fromAllowance);
            }
            if (rates.buyback != 0) {
                feesPaid += _payFeeImplementation(payer, principal, rates.buyback, feeStores.buyback, fromAllowance);
            }
            if (rates.liquidity != 0) {
                feesPaid += _payFeeImplementation(payer, principal, rates.liquidity, feeStores.liquidity, fromAllowance);

                uint256 crssOnTGRBnbPair = IMaker(nodes.maker).getReserveOnETHPair(address(this));
                uint256 liquidityFeeAccumulated = _balances[feeStores.liquidity];
                if ( liquidityFeeAccumulated * 500 >= crssOnTGRBnbPair ) {
                    _liquifyLiquidityFees();
                    // If there is ETH residue.
                    uint256 remainETH = address(this).balance;
                    if (remainETH >= 10 ** 17) {
                        (bool sent, ) = feeStores.develop.call{value: remainETH}("");
                        require(sent, "Failed to send Ether");
                    }
                }
            }
            if (rates.treasury != 0) {
                feesPaid += _payFeeImplementation(payer, principal, rates.treasury, feeStores.treasury, fromAllowance);
            }
        }
    }

    function _payFeeImplementation(address payer, uint256 principal, uint256 rate, address payee, bool fromAllowance) 
    internal virtual returns (uint256 feePaid) {
        feePaid = principal * rate / FeeMagnifier;
        _transfer(payer, payee, feePaid);
        if (fromAllowance) _decreaseAllowance(payer, _msgSender(), feePaid);
        _moveDelegates(_delegates[payer], _delegates[payee], feePaid);
    }

    /**
    * @dev Prevent excessive net transfer amount of a single account during a single session.
    * Refer the SessionRegistrar._seekInitializeSession(...) for the meaning of session.
    */
    function _limitTransferPerSession(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        if ( ( sender == owner() || sender == address(this) ) && pairs[recipient].token0 != address(0) ) { // they are sending to an open pool.
            require( pairs[recipient].token0 == address(this) || pairs[recipient].token1 == address(this), sForbidden ); // let it be a crss/--- pool.
        } else{
            if (sessionParams.session != sessionParams.lastSession) { // Refresh maxTransferAmount every session.
                maxTransferAmount = _totalSupply.mul(maxTransferAmountRate).div(FeeMagnifier);
                if (transferUsers.length > 2000) _freeUpTransferUsersSpace();
            }

            _initailizeTransferUser(sender);
            accTransferAmountSession[sender].sent += amount;

            _initailizeTransferUser(recipient);
            accTransferAmountSession[recipient].received += amount;

            require(accTransferAmountSession[sender].sent.abs(accTransferAmountSession[sender].received) < maxTransferAmount
            && accTransferAmountSession[recipient].sent.abs(accTransferAmountSession[recipient].received) < maxTransferAmount, 
            "Exceed MaxTransferAmount");
        }
    }

    function _initailizeTransferUser(address user) internal virtual {
        if( accTransferAmountSession[user].session == 0 ) transferUsers.push(user);  // A new user. Register them.
        if (accTransferAmountSession[user].session != sessionParams.session) {  // A new user, or an existing user involved in a previous session.
            accTransferAmountSession[user].sent = 0;
            accTransferAmountSession[user].received = 0;
            accTransferAmountSession[user].session = sessionParams.session; // Tag with the current session id.
        }
    }

    function _freeUpTransferUsersSpace() internal virtual {
        uint256 length = transferUsers.length;
        for( uint256 i = 0; i < length; i ++) {
            address user = transferUsers[i];
            accTransferAmountSession[user].sent = 0;
            accTransferAmountSession[user].received = 0;
            accTransferAmountSession[user].session = 0;
        }
        delete transferUsers;
        transferUsers = new address[](0);
    }
    function _liquifyLiquidityFees() internal {
        // Assume: this->Pair is free of TransferControl.

        uint256 liquidityFeeAccumulated = _balances[feeStores.liquidity];
        _transfer(feeStores.liquidity, address(this), liquidityFeeAccumulated);

        uint256 crssPart = liquidityFeeAccumulated / 2;
        uint256 crssForEthPart = liquidityFeeAccumulated - crssPart;

        uint256 initialBalance = address(this).balance;
        _swapForETH(crssForEthPart); // 
        uint256 ethPart = address(this).balance.sub(initialBalance);
        uint256 liquidity = _addLiquidity(crssPart, ethPart);
        
        emit SwapAndLiquify(crssPart, crssForEthPart, ethPart, liquidity);
    }

    function _swapForETH(uint256 tokenAmount) internal {
        // generate the uniswap pair path of token -> WBNB
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = IMaker(nodes.taker).WETH();

        _approve(address(this), address(nodes.taker), tokenAmount);
        ITaker(nodes.taker).swapExactTokensForETH(
            // We know this will open a new nested session, which is not subject to fees.
            tokenAmount,
            0, // in trust of taker's price control.
            path,
            address(this),
            block.timestamp
        );
    }

    function _addLiquidity(uint256 tokenAmount, uint256 ethAmount) internal returns (uint256 liquidity) {
        _approve(address(this), address(nodes.maker), tokenAmount);

        (, , liquidity) = IMaker(nodes.maker).addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            address(this),
            block.timestamp
        );
    }

    //==================== Governance power ====================

    function _delegate(address delegator, address delegatee) internal {
        address oldDelegate = _delegates[delegator];
        uint256 delegatorBalance = balanceOf(delegator); // balance of underlying CRSSs (not scaled);
        _delegates[delegator] = delegatee;

        emit DelegateChanged(delegator, oldDelegate, delegatee);

        _moveDelegates(oldDelegate, delegatee, delegatorBalance);
    }

    function delegates(address delegator) external view returns (address) {
        return _delegates[delegator];
    }

    function delegate(address delegatee) external {
        return _delegate(_msgSender(), delegatee);
    }

    function delegateBySig(
        address delegatee,
        uint256 nonce,
        uint256 expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        bytes32 domainSeparator = keccak256(
            abi.encode(DOMAIN_TYPEHASH, keccak256(bytes(name())), getChainId(), address(this))
        );

        bytes32 structHash = keccak256(abi.encode(DELEGATION_TYPEHASH, delegatee, nonce, expiry));
        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));

        address signatory = ecrecover(digest, v, r, s);
        require(signatory != address(0), "Invalid signature");
        require(nonce == nonces[signatory]++, "Invalid nonce");
        require(block.timestamp <= expiry, "Signature expired");
        return _delegate(signatory, delegatee);
    }

    function getCurrentVotes(address account) external view returns (uint256) {
        uint32 nCheckpoints = numCheckpoints[account];
        return nCheckpoints > 0 ? checkpoints[account][nCheckpoints - 1].votes : 0;
    }

    function getPriorVotes(address account, uint256 blockNumber) external view returns (uint256) {
        require(blockNumber < block.number, "getPriorVotes: not determined yet");

        uint32 nCheckpoints = numCheckpoints[account];
        if (nCheckpoints == 0) {
            return 0;
        }

        // First check most recent balance
        if (checkpoints[account][nCheckpoints - 1].fromBlock <= blockNumber) {
            return checkpoints[account][nCheckpoints - 1].votes;
        }

        // Next check implicit zero balance
        if (checkpoints[account][0].fromBlock > blockNumber) {
            return 0;
        }

        uint32 lower = 0;
        uint32 upper = nCheckpoints - 1;
        while (upper > lower) {
            uint32 center = upper - (upper - lower) / 2; // ceil, avoiding overflow
            Checkpoint memory cp = checkpoints[account][center];
            if (cp.fromBlock == blockNumber) {
                return cp.votes;
            } else if (cp.fromBlock < blockNumber) {
                lower = center;
            } else {
                upper = center - 1;
            }
        }
        return checkpoints[account][lower].votes;
    }

    function safe32(uint256 n, string memory errorMessage) internal pure returns (uint32) {
        require(n < 2**32, errorMessage);
        return uint32(n);
    }

    function getChainId() internal view returns (uint256) {
        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        return chainId;
    }

    function _moveDelegates(
        address srcRep,
        address dstRep,
        uint256 amount
    ) internal {
        if (srcRep != dstRep && amount > 0) {
            if (srcRep != address(0)) {
                // decrease old representative
                uint32 srcRepNum = numCheckpoints[srcRep];
                uint256 srcRepOld = srcRepNum > 0 ? checkpoints[srcRep][srcRepNum - 1].votes : 0;
                uint256 srcRepNew = srcRepOld.sub(amount);
                _writeCheckpoint(srcRep, srcRepNum, srcRepOld, srcRepNew);
            }

            if (dstRep != address(0)) {
                // increase new representative
                uint32 dstRepNum = numCheckpoints[dstRep];
                uint256 dstRepOld = dstRepNum > 0 ? checkpoints[dstRep][dstRepNum - 1].votes : 0;
                uint256 dstRepNew = dstRepOld.add(amount);
                _writeCheckpoint(dstRep, dstRepNum, dstRepOld, dstRepNew);
            }
        }
    }

    function _writeCheckpoint(
        address delegatee,
        uint32 nCheckpoints,
        uint256 oldVotes,
        uint256 newVotes
    ) internal {
        uint32 blockNumber = safe32(block.number, "Block number exceeds 32 bits");

        if (nCheckpoints > 0 && checkpoints[delegatee][nCheckpoints - 1].fromBlock == blockNumber) {
            checkpoints[delegatee][nCheckpoints - 1].votes = newVotes;
        } else {
            checkpoints[delegatee][nCheckpoints] = Checkpoint(blockNumber, newVotes);
            numCheckpoints[delegatee] = nCheckpoints + 1;
        }

        emit DelegateVotesChanged(delegatee, oldVotes, newVotes);
    }
}
