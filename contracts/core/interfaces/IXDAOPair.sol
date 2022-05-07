// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "./IPancakePair.sol";

interface IXDAOPair is IPancakePair {
    function initialize(address, address) external;
    function setNodes(address maker, address taker, address farm) external;
    function tolerableTransfer(address from, address to, uint256 value) external returns (bool);
}
