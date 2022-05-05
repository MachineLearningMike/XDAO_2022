/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */

import { Signer, utils, Contract, ContractFactory, Overrides } from "ethers";
import { Provider, TransactionRequest } from "@ethersproject/providers";
import type { RSyrupBar, RSyrupBarInterface } from "../RSyrupBar";

const _abi = [
  {
    inputs: [
      {
        internalType: "address payable",
        name: "_crss",
        type: "address",
      },
    ],
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
        name: "delegator",
        type: "address",
      },
      {
        indexed: true,
        internalType: "address",
        name: "fromDelegate",
        type: "address",
      },
      {
        indexed: true,
        internalType: "address",
        name: "toDelegate",
        type: "address",
      },
    ],
    name: "DelegateChanged",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "address",
        name: "delegate",
        type: "address",
      },
      {
        indexed: false,
        internalType: "uint256",
        name: "previousBalance",
        type: "uint256",
      },
      {
        indexed: false,
        internalType: "uint256",
        name: "newBalance",
        type: "uint256",
      },
    ],
    name: "DelegateVotesChanged",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "address",
        name: "previousOwner",
        type: "address",
      },
      {
        indexed: true,
        internalType: "address",
        name: "newOwner",
        type: "address",
      },
    ],
    name: "OwnershipTransferred",
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
    name: "DELEGATION_TYPEHASH",
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
    name: "DOMAIN_TYPEHASH",
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
        name: "owner",
        type: "address",
      },
      {
        internalType: "address",
        name: "spender",
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
        name: "amount",
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
        name: "account",
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
        name: "_from",
        type: "address",
      },
      {
        internalType: "uint256",
        name: "_amount",
        type: "uint256",
      },
    ],
    name: "burn",
    outputs: [],
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
      {
        internalType: "uint32",
        name: "",
        type: "uint32",
      },
    ],
    name: "checkpoints",
    outputs: [
      {
        internalType: "uint32",
        name: "fromBlock",
        type: "uint32",
      },
      {
        internalType: "uint256",
        name: "votes",
        type: "uint256",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "crss",
    outputs: [
      {
        internalType: "contract CrssToken",
        name: "",
        type: "address",
      },
    ],
    stateMutability: "view",
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
    inputs: [
      {
        internalType: "address",
        name: "spender",
        type: "address",
      },
      {
        internalType: "uint256",
        name: "subtractedValue",
        type: "uint256",
      },
    ],
    name: "decreaseAllowance",
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
        name: "delegatee",
        type: "address",
      },
    ],
    name: "delegate",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "delegatee",
        type: "address",
      },
      {
        internalType: "uint256",
        name: "nonce",
        type: "uint256",
      },
      {
        internalType: "uint256",
        name: "expiry",
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
    name: "delegateBySig",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "delegator",
        type: "address",
      },
    ],
    name: "delegates",
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
        name: "account",
        type: "address",
      },
    ],
    name: "getCurrentVotes",
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
        name: "account",
        type: "address",
      },
      {
        internalType: "uint256",
        name: "blockNumber",
        type: "uint256",
      },
    ],
    name: "getPriorVotes",
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
        name: "addedValue",
        type: "uint256",
      },
    ],
    name: "increaseAllowance",
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
        name: "_to",
        type: "address",
      },
      {
        internalType: "uint256",
        name: "_amount",
        type: "uint256",
      },
    ],
    name: "mint",
    outputs: [],
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
        name: "",
        type: "address",
      },
    ],
    name: "numCheckpoints",
    outputs: [
      {
        internalType: "uint32",
        name: "",
        type: "uint32",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "owner",
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
    name: "renounceOwnership",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "_to",
        type: "address",
      },
      {
        internalType: "uint256",
        name: "_amount",
        type: "uint256",
      },
    ],
    name: "saferCrssTransfer",
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
        name: "amount",
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
        name: "amount",
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
  {
    inputs: [
      {
        internalType: "address",
        name: "newOwner",
        type: "address",
      },
    ],
    name: "transferOwnership",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
];

const _bytecode =
  "0x60806040523480156200001157600080fd5b5060405162001eeb38038062001eeb8339810160408190526200003491620001de565b604080518082018252600f81526e2929bcb93ab82130b9102a37b5b2b760891b60208083019182528351808501909452600684526505253595255560d41b908401528151919291620000899160039162000138565b5080516200009f90600490602084019062000138565b505050620000bc620000b6620000e260201b60201c565b620000e6565b600680546001600160a01b0319166001600160a01b03929092169190911790556200024b565b3390565b600580546001600160a01b038381166001600160a01b0319831681179093556040519116919082907f8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e090600090a35050565b82805462000146906200020e565b90600052602060002090601f0160209004810192826200016a5760008555620001b5565b82601f106200018557805160ff1916838001178555620001b5565b82800160010185558215620001b5579182015b82811115620001b557825182559160200191906001019062000198565b50620001c3929150620001c7565b5090565b5b80821115620001c35760008155600101620001c8565b600060208284031215620001f0578081fd5b81516001600160a01b038116811462000207578182fd5b9392505050565b600181811c908216806200022357607f821691505b602082108114156200024557634e487b7160e01b600052602260045260246000fd5b50919050565b611c90806200025b6000396000f3fe608060405234801561001057600080fd5b50600436106101545760003560e01c806306fdde0314610159578063095ea7b31461017757806318160ddd1461019a57806320606b70146101ac57806323b872dd146101c1578063313ce567146101d457806339509351146101e357806340c10f19146101f6578063587cde1e1461020b5780635c19a95c1461022b5780636fcfff451461023e57806370a0823114610279578063715018a61461028c578063782d6fe1146102945780637ecebe00146102a7578063806a4390146102c75780638da5cb5b146102da57806395d89b41146102e25780639dc29fac146102ea578063a457c2d7146102fd578063a9059cbb14610310578063b4b5ea5714610323578063c3cda52014610336578063dd62ed3e14610349578063e7a324dc1461035c578063f1127ed814610371578063f1b6e96c146103c8578063f2fde38b146103db575b600080fd5b6101616103ee565b60405161016e9190611a27565b60405180910390f35b61018a6101853660046118fd565b610480565b604051901515815260200161016e565b6002545b60405190815260200161016e565b61019e600080516020611bc783398151915281565b61018a6101cf3660046118c2565b61049a565b6040516012815260200161016e565b61018a6101f13660046118fd565b6104be565b6102096102043660046118fd565b6104e0565b005b61021e610219366004611876565b61054b565b60405161016e91906119fa565b610209610239366004611876565b61056c565b61026461024c366004611876565b60096020526000908152604090205463ffffffff1681565b60405163ffffffff909116815260200161016e565b61019e610287366004611876565b610579565b610209610594565b61019e6102a23660046118fd565b6105cf565b61019e6102b5366004611876565b600a6020526000908152604090205481565b6102096102d53660046118fd565b610834565b61021e610a03565b610161610a12565b6102096102f83660046118fd565b610a21565b61018a61030b3660046118fd565b610a80565b61018a61031e3660046118fd565b610afb565b61019e610331366004611876565b610b09565b610209610344366004611926565b610b7e565b61019e610357366004611890565b610e28565b61019e600080516020611be783398151915281565b6103ac61037f366004611984565b60086020908152600092835260408084209091529082529020805460019091015463ffffffff9091169082565b6040805163ffffffff909316835260208301919091520161016e565b60065461021e906001600160a01b031681565b6102096103e9366004611876565b610e53565b6060600380546103fd90611b5a565b80601f016020809104026020016040519081016040528092919081815260200182805461042990611b5a565b80156104765780601f1061044b57610100808354040283529160200191610476565b820191906000526020600020905b81548152906001019060200180831161045957829003601f168201915b5050505050905090565b60003361048e818585610ef0565b60019150505b92915050565b6000336104a8858285611014565b6104b3858585611088565b506001949350505050565b60003361048e8185856104d18383610e28565b6104db9190611aaf565b610ef0565b336104e9610a03565b6001600160a01b0316146105185760405162461bcd60e51b815260040161050f90611a7a565b60405180910390fd5b6105228282611244565b6001600160a01b03808316600090815260076020526040812054610547921683611312565b5050565b6001600160a01b03808216600090815260076020526040902054165b919050565b6105763382611471565b50565b6001600160a01b031660009081526020819052604090205490565b3361059d610a03565b6001600160a01b0316146105c35760405162461bcd60e51b815260040161050f90611a7a565b6105cd6000611500565b565b60004382106106305760405162461bcd60e51b815260206004820152602760248201527f637273733a3a6765745072696f72566f7465733a206e6f742079657420646574604482015266195c9b5a5b995960ca1b606482015260840161050f565b6001600160a01b03831660009081526009602052604090205463ffffffff168061065e576000915050610494565b6001600160a01b03841660009081526008602052604081208491610683600185611b35565b63ffffffff908116825260208201929092526040016000205416116106ec576001600160a01b0384166000908152600860205260408120906106c6600184611b35565b63ffffffff1663ffffffff16815260200190815260200160002060010154915050610494565b6001600160a01b038416600090815260086020908152604080832083805290915290205463ffffffff16831015610727576000915050610494565b600080610735600184611b35565b90505b8163ffffffff168163ffffffff1611156107fd576000600261075a8484611b35565b6107649190611aef565b61076e9083611b35565b6001600160a01b038816600090815260086020908152604080832063ffffffff80861685529083529281902081518083019092528054909316808252600190930154918101919091529192508714156107d1576020015194506104949350505050565b805163ffffffff168711156107e8578193506107f6565b6107f3600183611b35565b92505b5050610738565b506001600160a01b038516600090815260086020908152604080832063ffffffff9094168352929052206001015491505092915050565b3361083d610a03565b6001600160a01b0316146108635760405162461bcd60e51b815260040161050f90611a7a565b6006546040516370a0823160e01b81526000916001600160a01b0316906370a08231906108949030906004016119fa565b60206040518083038186803b1580156108ac57600080fd5b505afa1580156108c0573d6000803e3d6000fd5b505050506040513d601f19601f820116820180604052508101906108e491906119e2565b9050808211156109785760065460405163a9059cbb60e01b81526001600160a01b039091169063a9059cbb906109209086908590600401611a0e565b602060405180830381600087803b15801561093a57600080fd5b505af115801561094e573d6000803e3d6000fd5b505050506040513d601f19601f8201168201806040525081019061097291906119c2565b506109fe565b60065460405163a9059cbb60e01b81526001600160a01b039091169063a9059cbb906109aa9086908690600401611a0e565b602060405180830381600087803b1580156109c457600080fd5b505af11580156109d8573d6000803e3d6000fd5b505050506040513d601f19601f820116820180604052508101906109fc91906119c2565b505b505050565b6005546001600160a01b031690565b6060600480546103fd90611b5a565b33610a2a610a03565b6001600160a01b031614610a505760405162461bcd60e51b815260040161050f90611a7a565b610a5a8282611552565b6001600160a01b0380831660009081526007602052604081205461054792169083611312565b60003381610a8e8286610e28565b905083811015610aee5760405162461bcd60e51b815260206004820152602560248201527f45524332303a2064656372656173656420616c6c6f77616e63652062656c6f77604482015264207a65726f60d81b606482015260840161050f565b6104b38286868403610ef0565b60003361048e818585611088565b6001600160a01b03811660009081526009602052604081205463ffffffff1680610b34576000610b77565b6001600160a01b038316600090815260086020526040812090610b58600184611b35565b63ffffffff1663ffffffff168152602001908152602001600020600101545b9392505050565b6000600080516020611bc7833981519152610b976103ee565b80519060200120610ba54690565b60408051602080820195909552808201939093526060830191909152306080808401919091528151808403909101815260a083018252805190840120600080516020611be783398151915260c08401526001600160a01b038b1660e084015261010083018a90526101208084018a90528251808503909101815261014084019092528151919093012061190160f01b610160830152610162820183905261018282018190529192506000906101a20160408051601f198184030181528282528051602091820120600080855291840180845281905260ff8a169284019290925260608301889052608083018790529092509060019060a0016020604051602081039080840390855afa158015610cbf573d6000803e3d6000fd5b5050604051601f1901519150506001600160a01b038116610d315760405162461bcd60e51b815260206004820152602660248201527f637273733a3a64656c656761746542795369673a20696e76616c6964207369676044820152656e617475726560d01b606482015260840161050f565b6001600160a01b0381166000908152600a60205260408120805491610d5583611b95565b919050558914610db25760405162461bcd60e51b815260206004820152602260248201527f637273733a3a64656c656761746542795369673a20696e76616c6964206e6f6e604482015261636560f01b606482015260840161050f565b87421115610e115760405162461bcd60e51b815260206004820152602660248201527f637273733a3a64656c656761746542795369673a207369676e617475726520656044820152651e1c1a5c995960d21b606482015260840161050f565b610e1b818b611471565b505050505b505050505050565b6001600160a01b03918216600090815260016020908152604080832093909416825291909152205490565b33610e5c610a03565b6001600160a01b031614610e825760405162461bcd60e51b815260040161050f90611a7a565b6001600160a01b038116610ee75760405162461bcd60e51b815260206004820152602660248201527f4f776e61626c653a206e6577206f776e657220697320746865207a65726f206160448201526564647265737360d01b606482015260840161050f565b61057681611500565b6001600160a01b038316610f525760405162461bcd60e51b8152602060048201526024808201527f45524332303a20617070726f76652066726f6d20746865207a65726f206164646044820152637265737360e01b606482015260840161050f565b6001600160a01b038216610fb35760405162461bcd60e51b815260206004820152602260248201527f45524332303a20617070726f766520746f20746865207a65726f206164647265604482015261737360f01b606482015260840161050f565b6001600160a01b0383811660008181526001602090815260408083209487168084529482529182902085905590518481527f8c5be1e5ebec7d5bd14f71427d1e84f3dd0314c0f7b2291e5b200ac8c7c3b925910160405180910390a3505050565b60006110208484610e28565b905060001981146109fc578181101561107b5760405162461bcd60e51b815260206004820152601d60248201527f45524332303a20696e73756666696369656e7420616c6c6f77616e6365000000604482015260640161050f565b6109fc8484848403610ef0565b6001600160a01b0383166110ec5760405162461bcd60e51b815260206004820152602560248201527f45524332303a207472616e736665722066726f6d20746865207a65726f206164604482015264647265737360d81b606482015260840161050f565b6001600160a01b03821661114e5760405162461bcd60e51b815260206004820152602360248201527f45524332303a207472616e7366657220746f20746865207a65726f206164647260448201526265737360e81b606482015260840161050f565b6001600160a01b038316600090815260208190526040902054818110156111c65760405162461bcd60e51b815260206004820152602660248201527f45524332303a207472616e7366657220616d6f756e7420657863656564732062604482015265616c616e636560d01b606482015260840161050f565b6001600160a01b038085166000908152602081905260408082208585039055918516815290812080548492906111fd908490611aaf565b92505081905550826001600160a01b0316846001600160a01b0316600080516020611c078339815191528460405161123791815260200190565b60405180910390a36109fc565b6001600160a01b03821661129a5760405162461bcd60e51b815260206004820152601f60248201527f45524332303a206d696e7420746f20746865207a65726f206164647265737300604482015260640161050f565b80600260008282546112ac9190611aaf565b90915550506001600160a01b038216600090815260208190526040812080548392906112d9908490611aaf565b90915550506040518181526001600160a01b03831690600090600080516020611c078339815191529060200160405180910390a3610547565b816001600160a01b0316836001600160a01b0316141580156113345750600081115b156109fe576001600160a01b038316156113d7576001600160a01b03831660009081526009602052604081205463ffffffff1690816113745760006113b7565b6001600160a01b038516600090815260086020526040812090611398600185611b35565b63ffffffff1663ffffffff168152602001908152602001600020600101545b905060006113c58483611b1e565b90506113d38684848461168e565b5050505b6001600160a01b038216156109fe576001600160a01b03821660009081526009602052604081205463ffffffff169081611412576000611455565b6001600160a01b038416600090815260086020526040812090611436600185611b35565b63ffffffff1663ffffffff168152602001908152602001600020600101545b905060006114638483611aaf565b9050610e208584848461168e565b6001600160a01b038083166000908152600760205260408120549091169061149884610579565b6001600160a01b0385811660008181526007602052604080822080546001600160a01b031916898616908117909155905194955093928616927f3134e8a2e6d97e929a7e54011ea5485d7d196dd5f0ba4d4ef95803e8e3fc257f9190a46109fc828483611312565b600580546001600160a01b038381166001600160a01b0319831681179093556040519116919082907f8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e090600090a35050565b6001600160a01b0382166115b25760405162461bcd60e51b815260206004820152602160248201527f45524332303a206275726e2066726f6d20746865207a65726f206164647265736044820152607360f81b606482015260840161050f565b6001600160a01b038216600090815260208190526040902054818110156116265760405162461bcd60e51b815260206004820152602260248201527f45524332303a206275726e20616d6f756e7420657863656564732062616c616e604482015261636560f01b606482015260840161050f565b6001600160a01b0383166000908152602081905260408120838303905560028054849290611655908490611b1e565b90915550506040518281526000906001600160a01b03851690600080516020611c078339815191529060200160405180910390a36109fe565b60006116b243604051806060016040528060348152602001611c2760349139611830565b905060008463ffffffff1611801561170c57506001600160a01b038516600090815260086020526040812063ffffffff8316916116f0600188611b35565b63ffffffff908116825260208201929092526040016000205416145b15611755576001600160a01b03851660009081526008602052604081208391611736600188611b35565b63ffffffff1681526020810191909152604001600020600101556117e5565b60408051808201825263ffffffff838116825260208083018681526001600160a01b038a166000908152600883528581208a851682529092529390209151825463ffffffff1916911617815590516001918201556117b4908590611ac7565b6001600160a01b0386166000908152600960205260409020805463ffffffff191663ffffffff929092169190911790555b60408051848152602081018490526001600160a01b038716917fdec2bacdd2f05b59de34da9b523dff8be42e5e38e818c82fdb0bae774387a724910160405180910390a25050505050565b600081600160201b84106118575760405162461bcd60e51b815260040161050f9190611a27565b509192915050565b80356001600160a01b038116811461056757600080fd5b600060208284031215611887578081fd5b610b778261185f565b600080604083850312156118a2578081fd5b6118ab8361185f565b91506118b96020840161185f565b90509250929050565b6000806000606084860312156118d6578081fd5b6118df8461185f565b92506118ed6020850161185f565b9150604084013590509250925092565b6000806040838503121561190f578182fd5b6119188361185f565b946020939093013593505050565b60008060008060008060c0878903121561193e578182fd5b6119478761185f565b95506020870135945060408701359350606087013560ff8116811461196a578283fd5b9598949750929560808101359460a0909101359350915050565b60008060408385031215611996578182fd5b61199f8361185f565b9150602083013563ffffffff811681146119b7578182fd5b809150509250929050565b6000602082840312156119d3578081fd5b81518015158114610b77578182fd5b6000602082840312156119f3578081fd5b5051919050565b6001600160a01b0391909116815260200190565b6001600160a01b03929092168252602082015260400190565b6000602080835283518082850152825b81811015611a5357858101830151858201604001528201611a37565b81811115611a645783604083870101525b50601f01601f1916929092016040019392505050565b6020808252818101527f4f776e61626c653a2063616c6c6572206973206e6f7420746865206f776e6572604082015260600190565b60008219821115611ac257611ac2611bb0565b500190565b600063ffffffff808316818516808303821115611ae657611ae6611bb0565b01949350505050565b600063ffffffff80841680611b1257634e487b7160e01b83526012600452602483fd5b92169190910492915050565b600082821015611b3057611b30611bb0565b500390565b600063ffffffff83811690831681811015611b5257611b52611bb0565b039392505050565b600181811c90821680611b6e57607f821691505b60208210811415611b8f57634e487b7160e01b600052602260045260246000fd5b50919050565b6000600019821415611ba957611ba9611bb0565b5060010190565b634e487b7160e01b600052601160045260246000fdfe8cad95687ba82c2ce50e74f7b754645e5117c3a5bec8151c0726d5857980a866e48329057bfd03d55e49b547132e39cffd9c1820ad7b9d4c5307691425d15adfddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef637273733a3a5f7772697465436865636b706f696e743a20626c6f636b206e756d62657220657863656564732033322062697473a2646970667358221220bd4113f5a4ab7a269a55e9a9beb2f15b264f5e8a31edc3f6e10d3dcfaa5ca24f64736f6c63430008030033";

export class RSyrupBar__factory extends ContractFactory {
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
    _crss: string,
    overrides?: Overrides & { from?: string | Promise<string> }
  ): Promise<RSyrupBar> {
    return super.deploy(_crss, overrides || {}) as Promise<RSyrupBar>;
  }
  getDeployTransaction(
    _crss: string,
    overrides?: Overrides & { from?: string | Promise<string> }
  ): TransactionRequest {
    return super.getDeployTransaction(_crss, overrides || {});
  }
  attach(address: string): RSyrupBar {
    return super.attach(address) as RSyrupBar;
  }
  connect(signer: Signer): RSyrupBar__factory {
    return super.connect(signer) as RSyrupBar__factory;
  }
  static readonly bytecode = _bytecode;
  static readonly abi = _abi;
  static createInterface(): RSyrupBarInterface {
    return new utils.Interface(_abi) as RSyrupBarInterface;
  }
  static connect(
    address: string,
    signerOrProvider: Signer | Provider
  ): RSyrupBar {
    return new Contract(address, _abi, signerOrProvider) as RSyrupBar;
  }
}