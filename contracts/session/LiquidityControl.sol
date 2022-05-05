// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "./BaseControl.sol";
import "hardhat/console.sol";

abstract contract LiquidityControl is BaseControl {

    modifier canChangeLiquidityChangeLimit virtual;

    uint256 public sessionLiquidityChangeLimit = 5000; // 5% remove.
    uint256 constant sqaureMagnifier = FeeMagnifier * FeeMagnifier;
    uint256 private constant safety = 1e2;
    function _ruleOutInvalidLiquidity(PairSnapshot memory ps) internal view virtual {
        uint256 squareLiquidity = ps.reserve0 * ps.reserve1 * safety;
        uint256 prevSquareLiquidity = pairStateAtSessionBirth[ps.pair].reserve0 * pairStateAtSessionBirth[ps.pair].reserve1;
        uint256 squareExponent = (FeeMagnifier + sessionLiquidityChangeLimit);
        squareExponent = squareExponent * squareExponent;
        uint256 squareMin = prevSquareLiquidity * sqaureMagnifier * safety / squareExponent; // uint256 can accommodate 1e77. 1e15 tokens possible.
        uint256 squareMax = prevSquareLiquidity * squareExponent * safety / sqaureMagnifier;

        require(squareMin <= squareLiquidity && squareLiquidity <= squareMax, "Excessive deviation from previous liquidity");
    }

    function setLiquidityChangeLimit(uint256 newLimit) external virtual canChangeLiquidityChangeLimit {
        require( 100 <= newLimit && newLimit <= 5000, "Price limit out of range"); // 0.1% to 5.0%
        sessionLiquidityChangeLimit = newLimit;
    }
}