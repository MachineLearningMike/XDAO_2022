// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "./interfaces/INode.sol";
import "../libraries/WireLibrary.sol";

import "hardhat/console.sol";

abstract contract Node is INode {
    address public prevNode;
    address public nextNode;

    Nodes nodes;


    function getOwner() public virtual returns (address);

    modifier wired {
        require(msg.sender == prevNode || msg.sender == getOwner(), "Invalid caller 1");
        _;
    }

    modifier internalCall virtual {
        require( WireLibrary.isWiredCall(nodes), "Invalid caller 2");
        _;
    }

    function wire(address _prevNode, address _nextNode) external override virtual {
        require( msg.sender == getOwner(), "Invalid caller 3");
        prevNode = _prevNode;
        nextNode = _nextNode;
    }

    function informOfPair(address pair, address token0, address token1, address caller) public override virtual wired {
        if (caller != address(this)) {  // let caller be address(0) when an actor initiats this loop.
            address trueCaller = caller == address(0) ? address(this) : caller;
            INode(nextNode).informOfPair(pair, token0, token1, trueCaller);
        }
    }

    function setNode(NodeType nodeType, address node, address caller) public override virtual wired {
        if (caller != address(this)) {  // let caller be address(0) when an actor initiats this loop.
            WireLibrary.setNode(nodeType, node, nodes);
            emit SetNode(nodeType, node, msg.sender);
            address trueCaller = caller == address(0) ? address(this) : caller;
            if (nextNode != address(0)) {
                INode(nextNode).setNode(nodeType, node, trueCaller);
            }
        }
    }

    function setFeeStores(FeeStores memory _feeStores, address caller) public override virtual wired {
        if (caller != address(this)) {  // let caller be address(0) when an actor initiats this loop.  
            // Do NOT call WireLibrary.setFeeStores.... Wired contracts that host fee stores will call it.    
            address trueCaller = caller == address(0) ? address(this) : caller;
            if (nextNode != address(0)) INode(nextNode).setFeeStores(_feeStores, trueCaller);
        }
    }

    function setFeeRates(SessionType _sessionType, FeeRates memory _feeRates, address caller) public override virtual wired {
        if (caller != address(this)) {  // let caller be address(0) when an actor initiats this loop.
            // Do NOT call WireLibrary.setFeeRates.... Wired contracts that host fee retes will call it.
            address trueCaller = caller == address(0) ? address(this) : caller;
            if (nextNode != address(0)) { 
                INode(nextNode).setFeeRates(_sessionType, _feeRates, trueCaller);
            }
        }
    }
}
