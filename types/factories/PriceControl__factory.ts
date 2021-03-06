/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */

import { Contract, Signer, utils } from "ethers";
import { Provider } from "@ethersproject/providers";
import type { PriceControl, PriceControlInterface } from "../PriceControl";

const _abi = [
  {
    inputs: [],
    name: "sessionPriceChangeLimit",
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
        internalType: "uint256",
        name: "newLimit",
        type: "uint256",
      },
    ],
    name: "setPriceChangeLimit",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
];

export class PriceControl__factory {
  static readonly abi = _abi;
  static createInterface(): PriceControlInterface {
    return new utils.Interface(_abi) as PriceControlInterface;
  }
  static connect(
    address: string,
    signerOrProvider: Signer | Provider
  ): PriceControl {
    return new Contract(address, _abi, signerOrProvider) as PriceControl;
  }
}
