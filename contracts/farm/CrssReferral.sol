// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/ICrssReferral.sol";

contract CrssReferral is ICrssReferral, Ownable {
    mapping(address => address) public referrers; // user address => referrer address
    mapping(address => uint256) public countReferrals; // referrer address => referrals count
    mapping(address => uint256) public totalReferralCommissions; // referrer address => total referral commissions

    event ReferralRecorded(address indexed user, address indexed referrer);
    event ReferralCommissionRecorded(address indexed referrer, uint256 commission);
    event OperatorUpdated(address indexed operator, bool indexed status);

    constructor() Ownable() {
    }

    function recordReferral(address _user, address _referrer) public override onlyOwner {
        referrers[_user] = _referrer;
        countReferrals[_referrer] += 1;
        emit ReferralRecorded(_user, _referrer);
    }

    function recordReferralCommission(address _referrer, uint256 _commission) public override onlyOwner {
        totalReferralCommissions[_referrer] += _commission;
        emit ReferralCommissionRecorded(_referrer, _commission);
    }

    // Get the referrer address that referred the user
    function getReferrer(address _user) public view override returns (address) {
        return referrers[_user];
    }
}
