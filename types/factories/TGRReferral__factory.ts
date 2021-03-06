/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */

import { Signer, utils, Contract, ContractFactory, Overrides } from "ethers";
import { Provider, TransactionRequest } from "@ethersproject/providers";
import type { TGRReferral, TGRReferralInterface } from "../TGRReferral";

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
        name: "operator",
        type: "address",
      },
      {
        indexed: true,
        internalType: "bool",
        name: "status",
        type: "bool",
      },
    ],
    name: "OperatorUpdated",
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
        name: "referrer",
        type: "address",
      },
      {
        indexed: false,
        internalType: "uint256",
        name: "commission",
        type: "uint256",
      },
    ],
    name: "ReferralCommissionRecorded",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "address",
        name: "user",
        type: "address",
      },
      {
        indexed: true,
        internalType: "address",
        name: "referrer",
        type: "address",
      },
    ],
    name: "ReferralRecorded",
    type: "event",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "",
        type: "address",
      },
    ],
    name: "countReferrals",
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
        name: "_user",
        type: "address",
      },
    ],
    name: "getReferrer",
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
    inputs: [
      {
        internalType: "address",
        name: "_user",
        type: "address",
      },
      {
        internalType: "address",
        name: "_referrer",
        type: "address",
      },
    ],
    name: "recordReferral",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "_referrer",
        type: "address",
      },
      {
        internalType: "uint256",
        name: "_commission",
        type: "uint256",
      },
    ],
    name: "recordReferralCommission",
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
    ],
    name: "referrers",
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
        name: "",
        type: "address",
      },
    ],
    name: "totalReferralCommissions",
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
  "0x608060405234801561001057600080fd5b5061001a3361001f565b61006f565b600080546001600160a01b038381166001600160a01b0319831681178455604051919092169283917f8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e09190a35050565b6105598061007e6000396000f3fe608060405234801561001057600080fd5b50600436106100835760003560e01c80630c7f7b6b146100885780634a3b68cc1461009d5780634a9fefc7146100e3578063715018a6146100f6578063898ee259146100fe5780638da5cb5b1461012c5780639ecfc6ea14610134578063dc1694b814610154578063f2fde38b14610167575b600080fd5b61009b61009636600461046f565b61017a565b005b6100c66100ab36600461044e565b6001602052600090815260409020546001600160a01b031681565b6040516001600160a01b0390911681526020015b60405180910390f35b6100c66100f136600461044e565b61023e565b61009b61025f565b61011e61010c36600461044e565b60026020526000908152604090205481565b6040519081526020016100da565b6100c661029a565b61011e61014236600461044e565b60036020526000908152604090205481565b61009b6101623660046104a1565b6102a9565b61009b61017536600461044e565b610347565b3361018361029a565b6001600160a01b0316146101b25760405162461bcd60e51b81526004016101a9906104ca565b60405180910390fd5b6001600160a01b03828116600090815260016020818152604080842080546001600160a01b03191695871695861790559383526002905291812080549091906101fc9084906104ff565b90915550506040516001600160a01b0380831691908416907ff61ccbe316daff56654abed758191f9a4dcac526d43747a50a2d545c0ca64d8290600090a35050565b6001600160a01b03808216600090815260016020526040902054165b919050565b3361026861029a565b6001600160a01b03161461028e5760405162461bcd60e51b81526004016101a9906104ca565b61029860006103e7565b565b6000546001600160a01b031690565b336102b261029a565b6001600160a01b0316146102d85760405162461bcd60e51b81526004016101a9906104ca565b6001600160a01b038216600090815260036020526040812080548392906103009084906104ff565b90915550506040518181526001600160a01b038316907f91badd4ef769cf56b7db0b350b95c9fb6d973e6e37d28a51fed219cc7d53184f9060200160405180910390a25050565b3361035061029a565b6001600160a01b0316146103765760405162461bcd60e51b81526004016101a9906104ca565b6001600160a01b0381166103db5760405162461bcd60e51b815260206004820152602660248201527f4f776e61626c653a206e6577206f776e657220697320746865207a65726f206160448201526564647265737360d01b60648201526084016101a9565b6103e4816103e7565b50565b600080546001600160a01b038381166001600160a01b0319831681178455604051919092169283917f8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e09190a35050565b80356001600160a01b038116811461025a57600080fd5b60006020828403121561045f578081fd5b61046882610437565b9392505050565b60008060408385031215610481578081fd5b61048a83610437565b915061049860208401610437565b90509250929050565b600080604083850312156104b3578182fd5b6104bc83610437565b946020939093013593505050565b6020808252818101527f4f776e61626c653a2063616c6c6572206973206e6f7420746865206f776e6572604082015260600190565b6000821982111561051e57634e487b7160e01b81526011600452602481fd5b50019056fea26469706673582212200decad99bb822e25bf016e8312626d28d312a252a811a27db55cd07f2d86e8a964736f6c63430008030033";

export class TGRReferral__factory extends ContractFactory {
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
  ): Promise<TGRReferral> {
    return super.deploy(overrides || {}) as Promise<TGRReferral>;
  }
  getDeployTransaction(
    overrides?: Overrides & { from?: string | Promise<string> }
  ): TransactionRequest {
    return super.getDeployTransaction(overrides || {});
  }
  attach(address: string): TGRReferral {
    return super.attach(address) as TGRReferral;
  }
  connect(signer: Signer): TGRReferral__factory {
    return super.connect(signer) as TGRReferral__factory;
  }
  static readonly bytecode = _bytecode;
  static readonly abi = _abi;
  static createInterface(): TGRReferralInterface {
    return new utils.Interface(_abi) as TGRReferralInterface;
  }
  static connect(
    address: string,
    signerOrProvider: Signer | Provider
  ): TGRReferral {
    return new Contract(address, _abi, signerOrProvider) as TGRReferral;
  }
}
