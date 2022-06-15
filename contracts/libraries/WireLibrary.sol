// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../session/interfaces/INode.sol";

library WireLibrary {
    function setNode(
        NodeType nodeType,
        address node,
        Nodes storage nodes
    ) external {
        if (nodeType == NodeType.Token) {
            nodes.token = node;
        } else if (nodeType == NodeType.Center) {
            nodes.center = node;
        } else if (nodeType == NodeType.Maker) {
            nodes.maker = node;
        } else if (nodeType == NodeType.Taker) {
            nodes.taker = node;
        } else if (nodeType == NodeType.XFactory) {
            nodes.factory = node;
        }
    }

    function isWiredCall(Nodes storage nodes) external view returns (bool) {
        return
            msg.sender != address(0) &&
            (msg.sender == nodes.token ||
                msg.sender == nodes.maker ||
                msg.sender == nodes.taker ||
                msg.sender == nodes.factory);
    }

    function setFeeStores(FeeStores storage feeStores, FeeStores memory _feeStores) external {
        require(_feeStores.accountant != address(0), "Zero address");
        feeStores.accountant = _feeStores.accountant;
    }

    function setFeeRates(
        ActionType _sessionType,
        mapping(ActionType => FeeRates) storage feeRates,
        FeeRates memory _feeRates
    ) external {
        require(uint256(_sessionType) < NumberSessionTypes, "Wrong ActionType");
        require(_feeRates.accountant <= FeeMagnifier, "Fee rates exceed limit");

        feeRates[_sessionType].accountant = _feeRates.accountant;
    }
}
