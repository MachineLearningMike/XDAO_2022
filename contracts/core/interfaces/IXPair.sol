// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "./IPancakePair.sol";
import "../../session/interfaces/IConstants.sol";

interface IXPair is IPancakePair {
    function initialize(address, address) external;
    function setNodes(address token, address maker, address taker) external;
    function status() external view returns (ListStatus);
    function changeStatus(ListStatus _status) external;
}
