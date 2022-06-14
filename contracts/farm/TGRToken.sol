// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "solidity-math-utils/project/contracts/AnalyticMath.sol";

import "./interfaces/ITGRToken.sol";
import "../session/interfaces/IConstants.sol";
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

    //====================== Pulse core data ============================

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

    //====================== Pulse internal functions ============================

    function _checkForConsistency() internal view {
        // Defines user_burn attributes, based on the ERC20 core data.
        require(user_burn.sum_balances + _balances[tgrftm] + _balances[tgrhtz] + _balances[votes] == _totalSupply, 
        "sum_balances + _bal[tgrftm] + _bal[tgrhtz + _bal[votes != _totalSupply");
        require(_balances[admin] + _balances[alice] + _balances[bob] + _balances[carol] == user_burn.sum_balances,
        "_bal[admin] + _bal[alice] + _bal[bob] + _bal[carol] != sum_balances");
    }

    function _isUserAccount(address account) internal view returns (bool) {
        return account != tgrftm && account != tgrhtz && account != votes;
    }


    function _settleWithPendingBurn(address account) internal { // user account only
        uint256 pendingBurn = _balances[account] * user_burn.accDecayPerShare / 1e12 - Users[account].debtToPendingBurn; // smaller than its real value
        if (pendingBurn > 0) {
            _balances[account] -= pendingBurn; // larger than its real value
            _totalSupply -= pendingBurn; // larger than its real value
            user_burn.sum_balances -= pendingBurn; // larger
            user_burn.pending_burn -= pendingBurn; // larger
            Users[account].debtToPendingBurn =  _balances[account] * user_burn.accDecayPerShare / 1e12;
        }
    }

    function _changeBalance(address account, uint256 amount, bool addNotSubtract) internal {
        if (_isUserAccount(account)) {
            _settleWithPendingBurn(account);
            _balances[account] = addNotSubtract ?  _balances[account] + amount : _balances[account] - amount;
            user_burn.sum_balances = addNotSubtract ? user_burn.sum_balances + amount : user_burn.sum_balances - amount;

            Users[account].debtToPendingBurn =  _balances[account] * user_burn.accDecayPerShare / 1e12;
        } else {
            _balances[account] = addNotSubtract ? _balances[account] + amount : _balances[account] - amount;
        }
    }

    AnalyticMath analyticMath;

    constructor(address _analyticMath) Ownable() {
        analyticMath = AnalyticMath(_analyticMath);

        //--------- test users ---------
        admin = _msgSender();
        alice = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8;
        bob = 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC;
        carol = 0x90F79bf6EB2c4f870365E785982E1f101E93b906;

        tgrftm = 0x97713c3c752F3bb80CBFAaCC6830a36A72Eb6E97; // tgr_bnb
        tgrhtz = 0x3924A2cf72d190023667609Dd91e70Ed11127D78; // tgr_mck
        votes = 0x02EED5Ac83f1c3D1624c0437c9E682e83E95BcFf; // tgr_mck2

        lp_reward = Pulse(0, 2 seconds, 690, tgrftm, 0, 0, 0, block.timestamp / (2 seconds));
        vote_burn = Pulse(0, 2 seconds, 70, votes, 0, 0, 0, block.timestamp / (2 seconds));
        user_burn = Pulse(0, 4 seconds, 777, zero_address, 0, 0, 0, block.timestamp / (4 seconds));

        _mint(_msgSender(), 1e6 * 10 ** _decimals);

    }

    //==================== ERC20 internal functions ====================

    function _balanceOf(address account) internal view returns (uint256 balance) {
        if (_isUserAccount(account)) {
            // This line of code produces dust, due to numerical error. pendingBurn becomes less than its real value.
            uint256 pendingBurn = _balances[account] * user_burn.accDecayPerShare / 1e12 - Users[account].debtToPendingBurn;
            // so, balance becomes greater than its real value.
            balance = _balances[account] - pendingBurn; // larger than its real value
        } else {
            balance = _balances[account];
        }
    }

    function _getTotalSupply() internal view returns (uint256) {
        return _totalSupply - user_burn.pending_burn;
    }

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
        uint256 accountBalance = _balanceOf(from);
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
        _changeBalance(sender, amount, false);
        _changeBalance(recipient, amount, true);
        //_afterTokenTransfer(sender, recipient, amount);

        emit Transfer(sender, recipient, amount);
    }

    function _transferHub(address sender, address recipient, uint256 amount) internal virtual {
        if (amount > 0) {
            _transfer(sender, recipient, amount);
        }
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


    //==================== ERC20 public funcitons ====================

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
        return _getTotalSupply();
    }

    function balanceOf(address account) public view override virtual returns (uint256) {
        return _balanceOf(account); // larger than its real value
    }

    function mint(address to, uint256 amount) public override onlyOwner {
        require(_getTotalSupply() + amount <= maxSupply, "Exceed Max Supply");
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) public override onlyOwner {
        _burn(from, amount);
    }

    function bury(address from, uint256 amount) public override onlyOwner {
        _bury(from, amount);
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

    //==================== Pulse public functions ====================

    function _getDecayPer1e12(Pulse storage pulse) internal returns (uint256 decayPer1e12) {
        // pulse.lastTime, pulse.cycle, pulse.decayRate

        uint256 round = block.timestamp / pulse.cycle;
        if (round > pulse.latestRound) {
            uint256 missingRounds = round - pulse.latestRound;
            pulse.latestRound = round;
            pulse.latestTime = block.timestamp; // Not used.

            decayPer1e12 = 1e12;
            if (missingRounds <= 5) { // 5 optimized
                uint256 remain = FeeMagnifier - pulse.decayRate; 
                uint256 numerator = remain; 
                uint256 denominator = FeeMagnifier;
                for(uint256 i = 1; i < missingRounds; i++) { // note 1.
                    numerator *= remain;
                    denominator *= FeeMagnifier;
                }
                decayPer1e12 = 1e12 - 1e12 * numerator / denominator;
            } else {
                (uint256 P, uint256 Q) = analyticMath.pow(FeeMagnifier - pulse.decayRate, FeeMagnifier, missingRounds, uint256(1));
                // Function pow(a, b, c, d) approximates the power of a / b by c / d.
                // When a >= b, the output of this function is guaranteed to be smaller than or equal to the actual value of (a / b) ^ (c / d).
                // When a <= b, the output of this function is guaranteed to be larger than or equal to the actual value of (a / b) ^ (c / d).
                // As a <= b, the output is larger than its real value.
                decayPer1e12 = 1e12 - 1e12 * P / Q;
                // Now, decayPer1e12 is smaller than its real value.
            }
        }
    }

    function pulse_lp_reward() external {
        // 0.69% of XDAO/FTM LP has the XDAO side sold for FTM, 
        // then the FTM is used to buy HTZ which is added to XDAO lps airdrop rewards every 12 hours.

        uint256 round = block.timestamp / lp_reward.cycle;
        if (round > lp_reward.latestRound) {
            uint256 missingRounds = lp_reward.latestRound - round;
            lp_reward.latestRound = round;

            uint256 decayPer1e12 = _getDecayPer1e12(lp_reward); // smaller than its real value.
            // Use decayPer12 portion of tgrftm pool to obtain FTM to buy HTZ tokens at the htzftm pool, then add them to airdrop rewards.
            // TGR/FTM price falls and HTZ/FTM price rises, at their respective pools.

            lp_reward.latestTime = block.timestamp;
        }
    }

    function pulse_vote_burn() external {
        // 0.07% of tokens in the Agency dapp actively being used for voting burned every 12 hours.

        uint256 decayPer1e12 = _getDecayPer1e12(vote_burn); // smaller than its real value.
        // burn decayPer1e12 portion of votes account's TRG balance.
        _burn(vote_burn.account, _balances[vote_burn.account] * decayPer1e12 / 1e12);

        vote_burn.latestTime = block.timestamp;
    }

    function pulse_user_burn() external {
        // 0.777% of tokens(not in Cyberswap/Agency dapp) burned each 24 hours from users wallets.
        // Interpretation: TGR tokens not in Cyberswap accounts (tgrftm and tgrhtz), and not in Agency account (votes account), 
        // will be burned at the above rate and interval.

        uint256 decayPer1e12 = _getDecayPer1e12(user_burn); // smaller than its real value.
        if (decayPer1e12 > 0) {
            uint256 net_value = user_burn.sum_balances - user_burn.pending_burn;
            uint256 new_burn = net_value * decayPer1e12 / 1e12;  // smaller than its real value
            user_burn.pending_burn += new_burn;
            user_burn.accDecayPerShare += new_burn * 1e12 / user_burn.sum_balances;   // smaller than its real value

            user_burn.latestTime = block.timestamp;
        }
    }

    function checkForConsistency() external view {
        _checkForConsistency();

        // This requirement cannot be met due to numerical errors.
        // require(user_burn.sum_balances - user_burn.pending_burn == balanceOf(admin) + balanceOf(alice) + balanceOf(bob) + balanceOf(carol),
        // "sum_balances - pending_burn != balOf(admin) + balOf(alice) + balOf(bob) + balOf(carol)");

        // Instead, 
        uint256 net_collective = user_burn.sum_balances - user_burn.pending_burn;
        uint256 sum_net_of_users = balanceOf(admin) + balanceOf(alice) + balanceOf(bob) + balanceOf(carol);

        uint256 abs_error;
        if (net_collective < sum_net_of_users) {
            abs_error = sum_net_of_users - net_collective;
        } else {
            abs_error = net_collective - sum_net_of_users;
        }

        require( 1e7 * abs_error < net_collective, "Error exceeds a million-th");
    }

}
