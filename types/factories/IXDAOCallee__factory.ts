/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */

import { Contract, Signer, utils } from "ethers";
import { Provider } from "@ethersproject/providers";
import type { IXDAOCallee, IXDAOCalleeInterface } from "../IXDAOCallee";

const _abi = [
  {
    inputs: [
      {
        internalType: "address",
        name: "sender",
        type: "address",
      },
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
      {
        internalType: "bytes",
        name: "data",
        type: "bytes",
      },
    ],
    name: "crossCall",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
];

export class IXDAOCallee__factory {
  static readonly abi = _abi;
  static createInterface(): IXDAOCalleeInterface {
    return new utils.Interface(_abi) as IXDAOCalleeInterface;
  }
  static connect(
    address: string,
    signerOrProvider: Signer | Provider
  ): IXDAOCallee {
    return new Contract(address, _abi, signerOrProvider) as IXDAOCallee;
  }
}
