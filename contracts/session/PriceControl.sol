// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "./BaseControl.sol";

abstract contract PriceControl is BaseControl {

    uint256 public sessionPriceChangeLimit = 5000; // 5%
    uint256 constant private safety = 1e28;

    modifier canChangePriceChangeLimit virtual;
    function _ruleOutInvalidPrice(PairSnapshot memory ps) internal view virtual {
        uint256 price = ps.reserve0 * safety / ps.reserve1;
        uint256 prevPrice = pairStateAtSessionBirth[ps.pair].reserve0 * 1e28 / pairStateAtSessionBirth[ps.pair].reserve1;
        uint256 exponent = FeeMagnifier + sessionPriceChangeLimit;
        uint256 min = prevPrice * FeeMagnifier / exponent;
        uint256 max = prevPrice * exponent / FeeMagnifier;
        require(min <= price && price <= max, "Excessive deviation from previous price");
    }

    function setPriceChangeLimit(uint256 newLimit) external virtual canChangePriceChangeLimit {
        require( 100 <= newLimit && newLimit <= 5000, "Price limit out of range"); // 0.1% to 5.0%
       sessionPriceChangeLimit = newLimit;
    }
}