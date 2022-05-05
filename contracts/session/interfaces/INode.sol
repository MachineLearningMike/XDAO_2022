// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "./IConstants.sol";

struct Nodes {
    address token;
    address maker;
    address taker;
    address farm;
    address repay;
    address factory;
    address xToken;
}

enum NodeType {
    Token,
    Maker,
    Taker,
    Farm,
    Repay,
    Factory,
    XToken
}
interface INode {
    function informOfPair(address pair, address token0, address token1, address caller) external;
    function wire(address _prevNode, address _nextNode) external;
    function setNode(NodeType nodeType, address node, address caller) external;
    function setFeeStores(FeeStores memory _feeStores, address caller) external;
    function setFeeRates(SessionType _sessionType, FeeRates memory _feeRates, address caller) external;
    
    event SetNode(NodeType nodeType, address node, address msgSender);
    event SetFeeStores(FeeStores _feeStores);
    event SetFeeRates(SessionType _sessionType, FeeRates _feeRates);

}
