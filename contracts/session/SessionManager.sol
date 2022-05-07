// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "./interfaces/IConstants.sol";
import "./interfaces/ISessionRegistrar.sol";
import "./interfaces/ISessionManager.sol";

abstract contract SessionManager is ISessionManager {

    SessionParams sessionParams;
    ISessionRegistrar sessionRegistrar;
    ISessionFees sessionFees;

    function _openSession(SessionType sessionType) internal {
        sessionParams = sessionRegistrar.registerSession(sessionType);
    }
    function _closeSession() internal {
        sessionRegistrar.unregisterSession();
    }

    function _payFeeTGR(address account, uint256 principal, FeeRates memory rates, bool fromAllowance ) internal virtual returns (uint256 feesPaid) {
        feesPaid = sessionFees.payFeeTGRLogic(account, principal, rates, fromAllowance);
    }
}