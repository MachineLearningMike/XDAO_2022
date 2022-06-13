// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./interfaces/ITGRToken.sol";
// import "../session/SessionRegistrar.sol";
// import "../session/SessionManager.sol";
// import "../session/SessionFees.sol";
// import "../session/Node.sol";
// import "../libraries/WireLib.sol";
// import "../periphery/interfaces/IMaker.sol";
// import "../periphery/interfaces/ITaker.sol";
// import "../core/interfaces/IXDAOFactory.sol"; 
// import "../core/interfaces/IXDAOPair.sol";
// import "../farm/interfaces/IXDAOFarm.sol";
import "../libraries/math/SafeMath.sol";
// import "../libraries/GovLib.sol";

import "hardhat/console.sol";

// TGRToken with Governance.
contract TGRToken is Ownable, ITGRToken {
    using SafeMath for uint256;

    //==================== Constants ====================
    string private constant sForbidden = "Forbidden";
    string private constant sZeroAddress = "Zero address";
    string private constant sExceedsBalance = "Exceeds balance";
    uint256 public constant override maxSupply = 50 * 1e6 * 10**_decimals;
    address constant zero_address = 0x0000000000000000000000000000000000000000;

    //====================

    receive() external payable {}

    //==================== ERC20 core data ====================
    string private constant _name = "TGR Token";
    string private constant _symbol = "TGR";
    uint8 private constant _decimals = 18;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;

    //====================== Pulses ============================

    // The non-user TGR accounts, not limited to the below items.
    address tgrftm; // The address of TGR_FTM pool, which has TGR and WFTM balances.
    address tgrhtz; // The address of TGR_HTZ pool, which has TGR and HTZ balances.
    address votes;  // The address of the share-based, TGR staking account in the Agency dapp.

    Pulse public lp_reward;
    Pulse public vote_burn;
    Pulse public user_burn;

    mapping(address => User) Users;

    // test accounts
    address admin; address alice; address bob; address carol;

    function _getDecay(Pulse pulse) internal pure returns (uint256 decayPer1e12) {
        // pulse.lastTime, pulse.cycle, pulse.decayRate
    }

    function _checkForConsistency() internal view {
        // Defines user_burn attributes, based on the ERC20 core data.

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

    function _isUserAccount(address account) internal view returns (bool) {
        return account != tgrftm && account != tgrhtz && account != votes;
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
        // burn decayPer1e12 portion of votes account's TRG balance.

        vote_burn.latestTime = block.timestamp;
    }

    function pulse_user_burn() external {
        // 0.777% of tokens(not in Cyberswap/Agency dapp) burned each 24 hours from users wallets.
        // Interpretation: TGR tokens not in Cyberswap accounts (tgrftm and tgrhtz), and not in Agency account (votes account), 
        // will be burned at the above rate and interval.

        uint256 decayPer1e12 = _getDecay(user_burn);
        if (decayPer1e12 > 0) {
            uint256 net_value = user_burn.sum_balance - user_burn.pending_burn;
            uint256 new_burn = net_value * decayPer1e12 / 1e12;
            user_burn.pending_burn += new_burn;
            user_burn.accBurnPerShare += new_burn * 1e12 / user_burn.sum_balances;

            user_burn.latestTime = block.timestamp;
        }
    }

    function _balanceOf(address account) internal view returns (uint256 balance) { // user account only
        uint256 pendingBurn = _balances[account] * user_burn.accBurnPerShare - Users[account].debtToPendingBurn;
        balance = _balances[account] - pendingBurn;
    }

    function _settleWithPendingBurn(address account) internal { // user account only
        uint256 pendingBurn = _balances[account] * user_burn.accBurnPerShare - Users[account].debtToPendingBurn;
        if (pendingBurn > 0) {
            _balances[account] -= pendingBurn;
            user_burn.sum_balances -= pendingBurn;
            user_burn.pending_burn -= pendingBurn;
            Users[account].debtToPendingBurn =  _balances[account] * user_burn.accBurnPerShare
        }
    }

    function _changeBalance(address account, uint256 amount, bool addNotSubtract) internal {
        if (_isUserAccount(account)) {
            _settleWithPendingBurn(account);
            _balances[account] += addNotSubtract ? amount : - amount;
            user_burn.sum_balance += addNotSubtract ? amount : - amount;
            Users[account].debtToPendingBurn =  _balances[account] * user_burn.accBurnPerShare;
        } else {
            _balances[account] += addNotSubtract ? amount : - amount;
        }
    }

    function _totalSupply() internal return (uint256) {
        return _totalSupply - user_burn.panding_burn;
    }



    constructor() Ownable() {

        // Mint 1e6 TGR to the caller for testing - MUST BE REMOVED WHEN DEPLOY
        _mint(_msgSender(), 1e6 * 10 ** _decimals);

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



    //========== Modifiers. Some of them required by super classes ====================
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
        return _totalSupply();
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
    }

    /**
    * @dev Implements the business logic of the tansfer and transferFrom funcitons.
    * Collect transfer fee if the calling transfer functions are a top session, 
    * or, equivalently, an external actor invoked the transfer.
    * If the transfer is 100% of transfer amount if  external actor wants to transfer to a pool created by XDAOFactory.
    */
    function _transferHub(address sender, address recipient, uint256 amount) internal virtual {
        if (amount > 0) {
            _transfer(sender, recipient, amount);
        }
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




}
