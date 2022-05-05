// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "./IConstants.sol";
interface ISessionRegistrar {

    function registerSession(SessionType sessionType) external returns (SessionParams memory sessionParams);
    function unregisterSession() external;
    function getInnermostSType() external returns (SessionType);  
    function getOutermostSType() external returns (SessionType);
}