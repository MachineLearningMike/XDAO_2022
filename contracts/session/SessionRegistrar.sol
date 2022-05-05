// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "./interfaces/IConstants.sol";
import "./interfaces/ISessionRegistrar.sol";

abstract contract SessionRegistrar is ISessionRegistrar {

    uint256 public session;
    mapping(SessionType => uint256) public sessionsLastSeenBySType;

    SessionType[10] private stackSTypes;
    uint256 stackPointer;

    modifier dsManagersOnly virtual;

    function registerSession(SessionType sessionType) external override virtual dsManagersOnly returns (SessionParams memory sessionParams) {
        require(sessionType != SessionType.None, "Cross: Invalid SessionType Type");
        // reading stackPointer costs 5,000 gas, while updating costs 20,000 gas.
        if ( ! (stackPointer == 0 && stackSTypes[0] == SessionType.None) ) stackPointer ++;
        require(stackPointer < stackSTypes.length, "Cross: Session stack overflow");
        require(stackSTypes[stackPointer] == SessionType.None, "Cross: Session stack inconsistent");

        stackSTypes[stackPointer] = sessionType;

        sessionParams.sessionType = sessionType;
        (sessionParams.session, sessionParams.lastSession) = _seekInitializeSession(sessionType);
        sessionParams.isOriginAction = _isPrimarySession();

        _initializeSession(sessionType);
    }

    function unregisterSession() external override dsManagersOnly {
        // reading stackPointer costs 5,000 gas, while updating costs 20,000 gas.
        require(stackPointer < stackSTypes.length, "Cross: Session stack overflow");
        SessionType sessionType = stackSTypes[stackPointer];
        require(sessionType != SessionType.None, "Cross: Session stack inconsistent");
        stackSTypes[stackPointer] = SessionType.None;

        if (stackPointer > 0) stackPointer --;      
        sessionsLastSeenBySType[sessionType] = session;

        _finalizeSession(sessionType);
    }

    function getInnermostSType() external view override returns (SessionType) {
        return stackSTypes[stackPointer];
    }

    function getOutermostSType() external view override returns (SessionType) {
        return stackSTypes[0];
    }

    function _isPrimarySession() internal view returns (bool) {
        return stackPointer == 0; // && stackSTypes[stackPointer] != SessionType.None; // A None session will have 100% fee.
    }

    function _initializeSession(SessionType sessionType) internal virtual {
    }

    function _finalizeSession(SessionType sessionType) internal virtual {
    }

    function _seekInitializeSession(SessionType sessionType) internal virtual returns (uint256 _session, uint256 _lastSession) {

        uint256 hashBNOrigin = uint256(keccak256(abi.encode(block.number, tx.origin)));
        if (session != hashBNOrigin ) {
            session = hashBNOrigin;
        }
        _session = session;
        _lastSession = sessionsLastSeenBySType[sessionType];
    }
}