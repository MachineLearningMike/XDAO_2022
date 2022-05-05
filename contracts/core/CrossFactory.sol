// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "../session/Node.sol";
import "./interfaces/ICrossFactory.sol";
import "../periphery/interfaces/ICrossRouter.sol";
import "./CrossPair.sol";

contract CrossFactory is Node, ICrossFactory {
    bytes32 public constant INIT_CODE_PAIR_HASH = keccak256(abi.encodePacked(type(CrossPair).creationCode));

    address public override feeTo;
    address public override owner;
    
    mapping(address => mapping(address => address)) public override getPair;
    address[] public override allPairs;

    constructor(address _owner) {
        owner = _owner;
    }

    function getOwner() public view override returns (address) {
        return owner;
    }

    function setNode(NodeType nodeType, address node, address caller) public override {
        if (caller != address(this)) {  // let caller be address(0) when an actor initiats this loop
            for (uint256 i = 0; i < allPairs.length; i++) {
                ICrossPair(allPairs[i]).setNodes(nodes.maker, nodes.taker, nodes.farm);
            }
            super.setNode(nodeType, node, caller);
        }
    }

    function allPairsLength() external view override returns (uint256) {
        return allPairs.length;
    }

    function createPair(address tokenA, address tokenB) external override returns (address pair) {
        require(nodes.maker != address(0), "Cross: NO_MAKER");
        require(nodes.taker != address(0), "Cross: NO_TAKER");
        require(nodes.farm != address(0), "Cross: NO_FARM");
        require(tokenA != tokenB, "Cross: IDENTICAL_ADDRESSES");
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), "Cross: ZERO_ADDRESS");
        require(getPair[token0][token1] == address(0), "Cross: PAIR_EXISTS"); // single check is sufficient
        bytes memory bytecode = type(CrossPair).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(token0, token1));
        assembly {
            pair := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        ICrossPair(pair).initialize(token0, token1);
        ICrossPair(pair).setNodes(nodes.maker, nodes.taker, nodes.farm);

        getPair[token0][token1] = pair;
        getPair[token1][token0] = pair; // populate mapping in the reverse direction
        allPairs.push(pair);
        
        INode(nextNode).informOfPair(pair, token0, token1, address(this));

        emit PairCreated(token0, token1, pair, allPairs.length);
    }

    function setFeeTo(address _feeTo) external override {
        require(msg.sender == owner, "Cross: FORBIDDEN");
        feeTo = _feeTo;
    }

    function setOwner(address _owner) external override {
        require(msg.sender == owner, "Cross: FORBIDDEN");
        owner = _owner;
    }
}
