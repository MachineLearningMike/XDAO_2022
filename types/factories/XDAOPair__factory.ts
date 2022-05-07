/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */

import { Signer, utils, Contract, ContractFactory, Overrides } from "ethers";
import { Provider, TransactionRequest } from "@ethersproject/providers";
import type { XDAOPair, XDAOPairInterface } from "../XDAOPair";

const _abi = [
  {
    inputs: [],
    stateMutability: "nonpayable",
    type: "constructor",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "address",
        name: "owner",
        type: "address",
      },
      {
        indexed: true,
        internalType: "address",
        name: "spender",
        type: "address",
      },
      {
        indexed: false,
        internalType: "uint256",
        name: "value",
        type: "uint256",
      },
    ],
    name: "Approval",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "address",
        name: "sender",
        type: "address",
      },
      {
        indexed: false,
        internalType: "uint256",
        name: "amount0",
        type: "uint256",
      },
      {
        indexed: false,
        internalType: "uint256",
        name: "amount1",
        type: "uint256",
      },
      {
        indexed: true,
        internalType: "address",
        name: "to",
        type: "address",
      },
    ],
    name: "Burn",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "address",
        name: "sender",
        type: "address",
      },
      {
        indexed: false,
        internalType: "uint256",
        name: "amount0",
        type: "uint256",
      },
      {
        indexed: false,
        internalType: "uint256",
        name: "amount1",
        type: "uint256",
      },
    ],
    name: "Mint",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "address",
        name: "sender",
        type: "address",
      },
      {
        indexed: false,
        internalType: "uint256",
        name: "amount0In",
        type: "uint256",
      },
      {
        indexed: false,
        internalType: "uint256",
        name: "amount1In",
        type: "uint256",
      },
      {
        indexed: false,
        internalType: "uint256",
        name: "amount0Out",
        type: "uint256",
      },
      {
        indexed: false,
        internalType: "uint256",
        name: "amount1Out",
        type: "uint256",
      },
      {
        indexed: true,
        internalType: "address",
        name: "to",
        type: "address",
      },
    ],
    name: "Swap",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: false,
        internalType: "uint112",
        name: "reserve0",
        type: "uint112",
      },
      {
        indexed: false,
        internalType: "uint112",
        name: "reserve1",
        type: "uint112",
      },
    ],
    name: "Sync",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "address",
        name: "from",
        type: "address",
      },
      {
        indexed: true,
        internalType: "address",
        name: "to",
        type: "address",
      },
      {
        indexed: false,
        internalType: "uint256",
        name: "value",
        type: "uint256",
      },
    ],
    name: "Transfer",
    type: "event",
  },
  {
    inputs: [],
    name: "DOMAIN_SEPARATOR",
    outputs: [
      {
        internalType: "bytes32",
        name: "",
        type: "bytes32",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "MINIMUM_LIQUIDITY",
    outputs: [
      {
        internalType: "uint256",
        name: "",
        type: "uint256",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "PERMIT_TYPEHASH",
    outputs: [
      {
        internalType: "bytes32",
        name: "",
        type: "bytes32",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "",
        type: "address",
      },
      {
        internalType: "address",
        name: "",
        type: "address",
      },
    ],
    name: "allowance",
    outputs: [
      {
        internalType: "uint256",
        name: "",
        type: "uint256",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "spender",
        type: "address",
      },
      {
        internalType: "uint256",
        name: "value",
        type: "uint256",
      },
    ],
    name: "approve",
    outputs: [
      {
        internalType: "bool",
        name: "",
        type: "bool",
      },
    ],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "",
        type: "address",
      },
    ],
    name: "balanceOf",
    outputs: [
      {
        internalType: "uint256",
        name: "",
        type: "uint256",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "to",
        type: "address",
      },
    ],
    name: "burn",
    outputs: [
      {
        internalType: "uint256",
        name: "amount0",
        type: "uint256",
      },
      {
        internalType: "uint256",
        name: "amount1",
        type: "uint256",
      },
    ],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [],
    name: "decimals",
    outputs: [
      {
        internalType: "uint8",
        name: "",
        type: "uint8",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "factory",
    outputs: [
      {
        internalType: "address",
        name: "",
        type: "address",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "getReserves",
    outputs: [
      {
        internalType: "uint112",
        name: "_reserve0",
        type: "uint112",
      },
      {
        internalType: "uint112",
        name: "_reserve1",
        type: "uint112",
      },
      {
        internalType: "uint32",
        name: "_blockTimestampLast",
        type: "uint32",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "_token0",
        type: "address",
      },
      {
        internalType: "address",
        name: "_token1",
        type: "address",
      },
    ],
    name: "initialize",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [],
    name: "kLast",
    outputs: [
      {
        internalType: "uint256",
        name: "",
        type: "uint256",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "to",
        type: "address",
      },
    ],
    name: "mint",
    outputs: [
      {
        internalType: "uint256",
        name: "liquidity",
        type: "uint256",
      },
    ],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [],
    name: "name",
    outputs: [
      {
        internalType: "string",
        name: "",
        type: "string",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "",
        type: "address",
      },
    ],
    name: "nonces",
    outputs: [
      {
        internalType: "uint256",
        name: "",
        type: "uint256",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "owner",
        type: "address",
      },
      {
        internalType: "address",
        name: "spender",
        type: "address",
      },
      {
        internalType: "uint256",
        name: "value",
        type: "uint256",
      },
      {
        internalType: "uint256",
        name: "deadline",
        type: "uint256",
      },
      {
        internalType: "uint8",
        name: "v",
        type: "uint8",
      },
      {
        internalType: "bytes32",
        name: "r",
        type: "bytes32",
      },
      {
        internalType: "bytes32",
        name: "s",
        type: "bytes32",
      },
    ],
    name: "permit",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [],
    name: "price0CumulativeLast",
    outputs: [
      {
        internalType: "uint256",
        name: "",
        type: "uint256",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "price1CumulativeLast",
    outputs: [
      {
        internalType: "uint256",
        name: "",
        type: "uint256",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "_maker",
        type: "address",
      },
      {
        internalType: "address",
        name: "_taker",
        type: "address",
      },
      {
        internalType: "address",
        name: "_farm",
        type: "address",
      },
    ],
    name: "setNodes",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "to",
        type: "address",
      },
    ],
    name: "skim",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "uint256",
        name: "amount0Out",
        type: "uint256",
      },
      {
        internalType: "uint256",
        name: "amount1Out",
        type: "uint256",
      },
      {
        internalType: "address",
        name: "to",
        type: "address",
      },
      {
        internalType: "bytes",
        name: "data",
        type: "bytes",
      },
    ],
    name: "swap",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [],
    name: "symbol",
    outputs: [
      {
        internalType: "string",
        name: "",
        type: "string",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "sync",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [],
    name: "token0",
    outputs: [
      {
        internalType: "address",
        name: "",
        type: "address",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "token1",
    outputs: [
      {
        internalType: "address",
        name: "",
        type: "address",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "from",
        type: "address",
      },
      {
        internalType: "address",
        name: "to",
        type: "address",
      },
      {
        internalType: "uint256",
        name: "value",
        type: "uint256",
      },
    ],
    name: "tolerableTransfer",
    outputs: [
      {
        internalType: "bool",
        name: "",
        type: "bool",
      },
    ],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [],
    name: "totalSupply",
    outputs: [
      {
        internalType: "uint256",
        name: "",
        type: "uint256",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "to",
        type: "address",
      },
      {
        internalType: "uint256",
        name: "value",
        type: "uint256",
      },
    ],
    name: "transfer",
    outputs: [
      {
        internalType: "bool",
        name: "",
        type: "bool",
      },
    ],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "from",
        type: "address",
      },
      {
        internalType: "address",
        name: "to",
        type: "address",
      },
      {
        internalType: "uint256",
        name: "value",
        type: "uint256",
      },
    ],
    name: "transferFrom",
    outputs: [
      {
        internalType: "bool",
        name: "",
        type: "bool",
      },
    ],
    stateMutability: "nonpayable",
    type: "function",
  },
];

const _bytecode =
  "0x60806040526001600f5534801561001557600080fd5b50600580546001600160a01b0319163317905560408051808201825260088152675844414f204c507360c01b6020918201528151808301835260018152603160f81b9082015281517f8b73c3c69bb8fe3d512ecc4cf759cc79239f7b179b0ffacaa9a75d522b39400f818301527f40149021892b8228121b3b9343cf380f91d769d2c36c3cb895ec49faf8325669818401527fc89efdaa54c0f20c7adf612882df0950f5a951637e0307cdcb4c672f298b8bc660608201524660808201523060a0808301919091528351808303909101815260c090910190925281519101206003556124ed806101066000396000f3fe608060405234801561001057600080fd5b506004361061015f5760003560e01c8063022c0d9f1461016457806306fdde03146101795780630902f1ac146101b6578063095ea7b3146101ea5780630dfe16811461020d57806318160ddd1461022d57806323b872dd1461024457806330adf81f14610257578063313ce5671461026c5780633644e51514610286578063485cc9551461028f5780635909c0d5146102a25780635a3d5493146102ab5780636a627842146102b457806370a08231146102c75780637464fc3d146102e75780637ecebe00146102f057806389afcb441461031057806395d89b4114610338578063a9059cbb1461035e578063ba9a7a5614610371578063bc25cf771461037a578063c45a01551461038d578063d21220a7146103a0578063d505accf146103b3578063dd62ed3e146103c6578063e22925d8146103f1578063e98732a514610404578063fff6cae914610417575b600080fd5b610177610172366004612199565b61041f565b005b6101a0604051806040016040528060088152602001675844414f204c507360c01b81525081565b6040516101ad91906122a5565b60405180910390f35b6101be61095b565b604080516001600160701b03948516815293909216602084015263ffffffff16908201526060016101ad565b6101fd6101f8366004612136565b610985565b60405190151581526020016101ad565b600654610220906001600160a01b031681565b6040516101ad9190612245565b61023660005481565b6040519081526020016101ad565b6101fd610252366004612081565b61099c565b61023660008051602061249883398151915281565b610274601281565b60405160ff90911681526020016101ad565b61023660035481565b61017761029d366004611fff565b610a30565b61023660095481565b610236600a5481565b6102366102c2366004611fc7565b610aaa565b6102366102d5366004611fc7565b60016020526000908152604090205481565b610236600b5481565b6102366102fe366004611fc7565b60046020526000908152604090205481565b61032361031e366004611fc7565b610d7e565b604080519283526020830191909152016101ad565b6101a06040518060400160405280600781526020016605844414f2d4c560cc1b81525081565b6101fd61036c366004612136565b611120565b6102366103e881565b610177610388366004611fc7565b61112d565b600554610220906001600160a01b031681565b600754610220906001600160a01b031681565b6101776103c13660046120c1565b61125a565b6102366103d4366004611fff565b600260209081526000928352604080842090915290825290205481565b6101fd6103ff366004612081565b611456565b610177610412366004612037565b611585565b610177611612565b600f5460011461044a5760405162461bcd60e51b8152600401610441906122d8565b60405180910390fd5b6000600f558415158061045d5750600084115b6104b45760405162461bcd60e51b815260206004820152602260248201527f506169723a20496e73756666696369656e7420616d6f756e7420666f72207377604482015261061760f41b6064820152608401610441565b6000806104bf61095b565b5091509150816001600160701b0316871080156104e45750806001600160701b031686105b61053c5760405162461bcd60e51b8152602060048201526024808201527f506169723a20496e73756666696369656e7420726573657276657320666f72206044820152630737761760e41b6064820152608401610441565b60065460075460009182916001600160a01b0391821691908116908916821480159061057a5750806001600160a01b0316896001600160a01b031614155b6105bc5760405162461bcd60e51b8152602060048201526013602482015272506169723a20496e76616c696420666565546f60681b6044820152606401610441565b8a156105cd576105cd828a8d61175e565b89156105de576105de818a8c61175e565b861561064b576040516366b7358560e11b81526001600160a01b038a169063cd6e6b0a906106189033908f908f908e908e90600401612259565b600060405180830381600087803b15801561063257600080fd5b505af1158015610646573d6000803e3d6000fd5b505050505b6040516370a0823160e01b81526001600160a01b038316906370a0823190610677903090600401612245565b60206040518083038186803b15801561068f57600080fd5b505afa1580156106a3573d6000803e3d6000fd5b505050506040513d601f19601f820116820180604052508101906106c79190612181565b6040516370a0823160e01b81529094506001600160a01b038216906370a08231906106f6903090600401612245565b60206040518083038186803b15801561070e57600080fd5b505afa158015610722573d6000803e3d6000fd5b505050506040513d601f19601f820116820180604052508101906107469190612181565b92505050600089856001600160701b03166107619190612398565b831161076e57600061078b565b6107818a6001600160701b038716612398565b61078b9084612398565b905060006107a28a6001600160701b038716612398565b83116107af5760006107cc565b6107c28a6001600160701b038716612398565b6107cc9084612398565b905060008211806107dd5750600081115b6108295760405162461bcd60e51b815260206004820152601f60248201527f506169723a20496e73756666696369656e6420696e70757420616d6f756e74006044820152606401610441565b600061084b61083984601161189c565b6108458761271061189c565b90611922565b9050600061085d61083984601161189c565b90506108836305f5e10061087d6001600160701b038b8116908b1661189c565b9061189c565b61088d838361189c565b10156108e65760405162461bcd60e51b815260206004820152602260248201527f506169723a20496e76616c6964206c6971756964697479206166747265207377604482015261061760f41b6064820152608401610441565b50506108f484848888611964565b60408051838152602081018390529081018c9052606081018b90526001600160a01b038a169033907fd78ad95fa46c994b6551d0da85fc275fe613ce37657fb8d5e3d130840159d8229060800160405180910390a350506001600f55505050505050505050565b6008546001600160701b0380821692600160701b830490911691600160e01b900463ffffffff1690565b6000610992338484611b4a565b5060015b92915050565b6001600160a01b038316600090815260026020908152604080832033845290915281205460001914610a1b576001600160a01b03841660009081526002602090815260408083203384529091529020546109f69083611922565b6001600160a01b03851660009081526002602090815260408083203384529091529020555b610a26848484611bac565b5060019392505050565b6005546001600160a01b03163314610a7c5760405162461bcd60e51b815260206004820152600f60248201526e2c2220a79d102327a92124a22222a760891b6044820152606401610441565b600680546001600160a01b039384166001600160a01b03199182161790915560078054929093169116179055565b6000600f54600114610ace5760405162461bcd60e51b8152600401610441906122d8565b6000600f81905580610ade61095b565b506006546040516370a0823160e01b81529294509092506000916001600160a01b03909116906370a0823190610b18903090600401612245565b60206040518083038186803b158015610b3057600080fd5b505afa158015610b44573d6000803e3d6000fd5b505050506040513d601f19601f82011682018060405250810190610b689190612181565b6007546040516370a0823160e01b81529192506000916001600160a01b03909116906370a0823190610b9e903090600401612245565b60206040518083038186803b158015610bb657600080fd5b505afa158015610bca573d6000803e3d6000fd5b505050506040513d601f19601f82011682018060405250810190610bee9190612181565b90506000610c05836001600160701b038716611922565b90506000610c1c836001600160701b038716611922565b90506000610c2a8787611c3b565b60005490915080610c6157610c4d6103e8610845610c48878761189c565b611d87565b9850610c5c60006103e8611df7565b610ca8565b610ca56001600160701b038916610c78868461189c565b610c829190612336565b6001600160701b038916610c96868561189c565b610ca09190612336565b611e74565b98505b60008911610cf05760405162461bcd60e51b815260206004820152601560248201527416995c9bc81b1a5c5d5a591a5d1e481b5a5b9d1959605a1b6044820152606401610441565b610cfa8a8a611df7565b610d0686868a8a611964565b8115610d3057600854610d2c906001600160701b0380821691600160701b90041661189c565b600b555b604080518581526020810185905233917f4c209b5fc8ad50758f13e2e1088ba56a560dff690a1c6fef26394f4c03821c4f910160405180910390a250506001600f5550949695505050505050565b600080600f54600114610da35760405162461bcd60e51b8152600401610441906122d8565b6000600f81905580610db361095b565b506006546007546040516370a0823160e01b81529395509193506001600160a01b039081169291169060009083906370a0823190610df5903090600401612245565b60206040518083038186803b158015610e0d57600080fd5b505afa158015610e21573d6000803e3d6000fd5b505050506040513d601f19601f82011682018060405250810190610e459190612181565b90506000826001600160a01b03166370a08231306040518263ffffffff1660e01b8152600401610e759190612245565b60206040518083038186803b158015610e8d57600080fd5b505afa158015610ea1573d6000803e3d6000fd5b505050506040513d601f19601f82011682018060405250810190610ec59190612181565b30600090815260016020526040812054919250610ee28888611c3b565b60005490915080610ef3848761189c565b610efd9190612336565b9a5080610f0a848661189c565b610f149190612336565b995060008b118015610f26575060008a115b610f715760405162461bcd60e51b815260206004820152601c60248201527b2830b4b91d102d32b9379030b6b7bab73a1030b33a32b910313ab93760211b6044820152606401610441565b610f7b3084611e8a565b610f86878d8d61175e565b610f91868d8c61175e565b6040516370a0823160e01b81526001600160a01b038816906370a0823190610fbd903090600401612245565b60206040518083038186803b158015610fd557600080fd5b505afa158015610fe9573d6000803e3d6000fd5b505050506040513d601f19601f8201168201806040525081019061100d9190612181565b6040516370a0823160e01b81529095506001600160a01b038716906370a082319061103c903090600401612245565b60206040518083038186803b15801561105457600080fd5b505afa158015611068573d6000803e3d6000fd5b505050506040513d601f19601f8201168201806040525081019061108c9190612181565b935061109a85858b8b611964565b81156110c4576008546110c0906001600160701b0380821691600160701b90041661189c565b600b555b604080518c8152602081018c90526001600160a01b038e169133917fdccd412f0b1252819cb1fd330b93224ca42612892bb3f4f789976e6d81936496910160405180910390a35050505050505050506001600f81905550915091565b6000610992338484611bac565b600f5460011461114f5760405162461bcd60e51b8152600401610441906122d8565b6000600f556006546007546008546040516370a0823160e01b81526001600160a01b0393841693909216916111fd91849186916111f8916001600160701b039091169084906370a08231906111a8903090600401612245565b60206040518083038186803b1580156111c057600080fd5b505afa1580156111d4573d6000803e3d6000fd5b505050506040513d601f19601f820116820180604052508101906108459190612181565b61175e565b61125081846111f86008600e9054906101000a90046001600160701b03166001600160701b0316856001600160a01b03166370a08231306040518263ffffffff1660e01b81526004016111a89190612245565b50506001600f5550565b4284101561129c5760405162461bcd60e51b815260206004820152600f60248201526e5844414f656420646561646c696e6560881b6044820152606401610441565b6003546001600160a01b03881660009081526004602052604081208054919291600080516020612498833981519152918b918b918b9190876112dd83612404565b909155506040805160208101969096526001600160a01b0394851690860152929091166060840152608083015260a082015260c0810187905260e0016040516020818303038152906040528051906020012060405160200161135692919061190160f01b81526002810192909252602282015260420190565b60408051601f198184030181528282528051602091820120600080855291840180845281905260ff88169284019290925260608301869052608083018590529092509060019060a0016020604051602081039080840390855afa1580156113c1573d6000803e3d6000fd5b5050604051601f1901519150506001600160a01b038116158015906113f75750886001600160a01b0316816001600160a01b0316145b6114405760405162461bcd60e51b815260206004820152601a6024820152797265636f766572656420616464726573732069732077726f6e6760301b6044820152606401610441565b61144b898989611b4a565b505050505050505050565b600e546000906001600160a01b031633146114a85760405162461bcd60e51b815260206004820152601260248201527143616c6c6572206973206e6f74206661726d60701b6044820152606401610441565b6001600160a01b0384166000908152600160205260409020548211156114e4576001600160a01b03841660009081526001602052604090205491505b6001600160a01b0384166000908152600160205260408120805484929061150c908490612398565b90915550506001600160a01b038316600090815260016020526040812080548492906115399084906122f8565b92505081905550826001600160a01b0316846001600160a01b03166000805160206124788339815191528460405161157391815260200190565b60405180910390a35060019392505050565b6005546001600160a01b031633146115d35760405162461bcd60e51b815260206004820152601160248201527043616c6c657220213d20666163746f727960781b6044820152606401610441565b600c80546001600160a01b039485166001600160a01b031991821617909155600d805493851693821693909317909255600e8054919093169116179055565b600f546001146116345760405162461bcd60e51b8152600401610441906122d8565b6000600f556006546040516370a0823160e01b8152611757916001600160a01b0316906370a082319061166b903090600401612245565b60206040518083038186803b15801561168357600080fd5b505afa158015611697573d6000803e3d6000fd5b505050506040513d601f19601f820116820180604052508101906116bb9190612181565b6007546040516370a0823160e01b81526001600160a01b03909116906370a08231906116eb903090600401612245565b60206040518083038186803b15801561170357600080fd5b505afa158015611717573d6000803e3d6000fd5b505050506040513d601f19601f8201168201806040525081019061173b9190612181565b6008546001600160701b0380821691600160701b900416611964565b6001600f55565b60408051808201825260198152787472616e7366657228616464726573732c75696e743235362960381b60209182015281516001600160a01b0385811660248301526044808301869052845180840390910181526064909201845291810180516001600160e01b031663a9059cbb60e01b179052915160009283928716916117e69190612229565b6000604051808303816000865af19150503d8060008114611823576040519150601f19603f3d011682016040523d82523d6000602084013e611828565b606091505b50915091508180156118525750805115806118525750808060200190518101906118529190612161565b6118955760405162461bcd60e51b815260206004820152601460248201527317dcd85999551c985b9cd9995c8819985a5b195960621b6044820152606401610441565b5050505050565b6000826118ab57506000610996565b60006118b78385612379565b9050826118c48583612336565b1461191b5760405162461bcd60e51b815260206004820152602160248201527f536166654d6174683a206d756c7469706c69636174696f6e206f766572666c6f6044820152607760f81b6064820152608401610441565b9392505050565b600061191b83836040518060400160405280601e81526020017f536166654d6174683a207375627472616374696f6e206f766572666c6f770000815250611f02565b6001600160701b03841180159061198257506001600160701b038311155b6119bf5760405162461bcd60e51b815260206004820152600e60248201526d57726f6e672062616c616e63657360901b6044820152606401610441565b60006119cf600160201b4261241f565b6008549091506000906119ef90600160e01b900463ffffffff16836123af565b905060008163ffffffff16118015611a0f57506001600160701b03841615155b8015611a2357506001600160701b03831615155b15611ab2578063ffffffff16611a4b85611a3c86611f3c565b6001600160e01b031690611f55565b6001600160e01b0316611a5e9190612379565b60096000828254611a6f91906122f8565b909155505063ffffffff8116611a8884611a3c87611f3c565b6001600160e01b0316611a9b9190612379565b600a6000828254611aac91906122f8565b90915550505b6008805463ffffffff8416600160e01b026001600160e01b036001600160701b03898116600160701b9081026001600160e01b03199095168c83161794909417918216831794859055604080519382169282169290921783529290930490911660208201527f1c411e9a96e071241c2f21f7726b17ae89e3cab4c78be50e062b03a9fffbbad1910160405180910390a1505050505050565b6001600160a01b0383811660008181526002602090815260408083209487168084529482529182902085905590518481527f8c5be1e5ebec7d5bd14f71427d1e84f3dd0314c0f7b2291e5b200ac8c7c3b92591015b60405180910390a3505050565b6001600160a01b03831660009081526001602052604081208054839290611bd4908490612398565b90915550506001600160a01b03821660009081526001602052604081208054839290611c019084906122f8565b92505081905550816001600160a01b0316836001600160a01b031660008051602061247883398151915283604051611b9f91815260200190565b600080600560009054906101000a90046001600160a01b03166001600160a01b031663017e7e586040518163ffffffff1660e01b815260040160206040518083038186803b158015611c8c57600080fd5b505afa158015611ca0573d6000803e3d6000fd5b505050506040513d601f19601f82011682018060405250810190611cc49190611fe3565b600b546001600160a01b038216158015945091925090611d73578015611d6e576000611cff610c486001600160701b0388811690881661189c565b90506000611d0c83611d87565b905080821115611d6b576000611d2e611d258484611922565b6000549061189c565b90506000611d4783611d4186600361189c565b90611f6a565b90506000611d558284612336565b90508015611d6757611d678782611df7565b5050505b50505b611d7f565b8015611d7f576000600b555b505092915050565b60006003821115611de85750806000611da1600283612336565b611dac9060016122f8565b90505b81811015611de257905080600281611dc78186612336565b611dd191906122f8565b611ddb9190612336565b9050611daf565b50611df2565b8115611df2575060015b919050565b600054611e049082611f6a565b60009081556001600160a01b038316815260016020526040902054611e299082611f6a565b6001600160a01b03831660008181526001602052604080822093909355915190919060008051602061247883398151915290611e689085815260200190565b60405180910390a35050565b6000818310611e83578161191b565b5090919050565b6001600160a01b038216600090815260016020526040902054611ead9082611922565b6001600160a01b03831660009081526001602052604081209190915554611ed49082611922565b60009081556040518281526001600160a01b0384169060008051602061247883398151915290602001611e68565b60008184841115611f265760405162461bcd60e51b815260040161044191906122a5565b506000611f338486612398565b95945050505050565b6000610996600160701b6001600160701b03841661234a565b600061191b6001600160701b03831684612310565b600080611f7783856122f8565b90508381101561191b5760405162461bcd60e51b815260206004820152601b60248201527a536166654d6174683a206164646974696f6e206f766572666c6f7760281b6044820152606401610441565b600060208284031215611fd8578081fd5b813561191b8161245f565b600060208284031215611ff4578081fd5b815161191b8161245f565b60008060408385031215612011578081fd5b823561201c8161245f565b9150602083013561202c8161245f565b809150509250929050565b60008060006060848603121561204b578081fd5b83356120568161245f565b925060208401356120668161245f565b915060408401356120768161245f565b809150509250925092565b600080600060608486031215612095578283fd5b83356120a08161245f565b925060208401356120b08161245f565b929592945050506040919091013590565b600080600080600080600060e0888a0312156120db578283fd5b87356120e68161245f565b965060208801356120f68161245f565b95506040880135945060608801359350608088013560ff81168114612119578384fd5b9699959850939692959460a0840135945060c09093013592915050565b60008060408385031215612148578182fd5b82356121538161245f565b946020939093013593505050565b600060208284031215612172578081fd5b8151801515811461191b578182fd5b600060208284031215612192578081fd5b5051919050565b6000806000806000608086880312156121b0578081fd5b853594506020860135935060408601356121c98161245f565b925060608601356001600160401b03808211156121e4578283fd5b818801915088601f8301126121f7578283fd5b813581811115612205578384fd5b896020828501011115612216578384fd5b9699959850939650602001949392505050565b6000825161223b8184602087016123d4565b9190910192915050565b6001600160a01b0391909116815260200190565b600060018060a01b038716825285602083015284604083015260806060830152826080830152828460a084013781830160a090810191909152601f909201601f19160101949350505050565b60006020825282518060208401526122c48160408501602087016123d4565b601f01601f19169190910160400192915050565b602080825260069082015265131bd8dad95960d21b604082015260600190565b6000821982111561230b5761230b612433565b500190565b60006001600160e01b038381168061232a5761232a612449565b92169190910492915050565b60008261234557612345612449565b500490565b60006001600160e01b038281168482168115158284048211161561237057612370612433565b02949350505050565b600081600019048311821515161561239357612393612433565b500290565b6000828210156123aa576123aa612433565b500390565b600063ffffffff838116908316818110156123cc576123cc612433565b039392505050565b60005b838110156123ef5781810151838201526020016123d7565b838111156123fe576000848401525b50505050565b600060001982141561241857612418612433565b5060010190565b60008261242e5761242e612449565b500690565b634e487b7160e01b600052601160045260246000fd5b634e487b7160e01b600052601260045260246000fd5b6001600160a01b038116811461247457600080fd5b5056feddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9a2646970667358221220e27e25754de8354861b4afb85c85f8e986a1f053989938c33efcd50ece74757464736f6c63430008030033";

export class XDAOPair__factory extends ContractFactory {
  constructor(
    ...args: [signer: Signer] | ConstructorParameters<typeof ContractFactory>
  ) {
    if (args.length === 1) {
      super(_abi, _bytecode, args[0]);
    } else {
      super(...args);
    }
  }

  deploy(
    overrides?: Overrides & { from?: string | Promise<string> }
  ): Promise<XDAOPair> {
    return super.deploy(overrides || {}) as Promise<XDAOPair>;
  }
  getDeployTransaction(
    overrides?: Overrides & { from?: string | Promise<string> }
  ): TransactionRequest {
    return super.getDeployTransaction(overrides || {});
  }
  attach(address: string): XDAOPair {
    return super.attach(address) as XDAOPair;
  }
  connect(signer: Signer): XDAOPair__factory {
    return super.connect(signer) as XDAOPair__factory;
  }
  static readonly bytecode = _bytecode;
  static readonly abi = _abi;
  static createInterface(): XDAOPairInterface {
    return new utils.Interface(_abi) as XDAOPairInterface;
  }
  static connect(
    address: string,
    signerOrProvider: Signer | Provider
  ): XDAOPair {
    return new Contract(address, _abi, signerOrProvider) as XDAOPair;
  }
}