/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */

import {
  ethers,
  EventFilter,
  Signer,
  BigNumber,
  BigNumberish,
  PopulatedTransaction,
  BaseContract,
  ContractTransaction,
  Overrides,
  CallOverrides,
} from "ethers";
import { BytesLike } from "@ethersproject/bytes";
import { Listener, Provider } from "@ethersproject/providers";
import { FunctionFragment, EventFragment, Result } from "@ethersproject/abi";
import type { TypedEventFilter, TypedEvent, TypedListener } from "./common";

interface TGRReferralInterface extends ethers.utils.Interface {
  functions: {
    "countReferrals(address)": FunctionFragment;
    "getReferrer(address)": FunctionFragment;
    "owner()": FunctionFragment;
    "recordReferral(address,address)": FunctionFragment;
    "recordReferralCommission(address,uint256)": FunctionFragment;
    "referrers(address)": FunctionFragment;
    "renounceOwnership()": FunctionFragment;
    "totalReferralCommissions(address)": FunctionFragment;
    "transferOwnership(address)": FunctionFragment;
  };

  encodeFunctionData(
    functionFragment: "countReferrals",
    values: [string]
  ): string;
  encodeFunctionData(functionFragment: "getReferrer", values: [string]): string;
  encodeFunctionData(functionFragment: "owner", values?: undefined): string;
  encodeFunctionData(
    functionFragment: "recordReferral",
    values: [string, string]
  ): string;
  encodeFunctionData(
    functionFragment: "recordReferralCommission",
    values: [string, BigNumberish]
  ): string;
  encodeFunctionData(functionFragment: "referrers", values: [string]): string;
  encodeFunctionData(
    functionFragment: "renounceOwnership",
    values?: undefined
  ): string;
  encodeFunctionData(
    functionFragment: "totalReferralCommissions",
    values: [string]
  ): string;
  encodeFunctionData(
    functionFragment: "transferOwnership",
    values: [string]
  ): string;

  decodeFunctionResult(
    functionFragment: "countReferrals",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "getReferrer",
    data: BytesLike
  ): Result;
  decodeFunctionResult(functionFragment: "owner", data: BytesLike): Result;
  decodeFunctionResult(
    functionFragment: "recordReferral",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "recordReferralCommission",
    data: BytesLike
  ): Result;
  decodeFunctionResult(functionFragment: "referrers", data: BytesLike): Result;
  decodeFunctionResult(
    functionFragment: "renounceOwnership",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "totalReferralCommissions",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "transferOwnership",
    data: BytesLike
  ): Result;

  events: {
    "OperatorUpdated(address,bool)": EventFragment;
    "OwnershipTransferred(address,address)": EventFragment;
    "ReferralCommissionRecorded(address,uint256)": EventFragment;
    "ReferralRecorded(address,address)": EventFragment;
  };

  getEvent(nameOrSignatureOrTopic: "OperatorUpdated"): EventFragment;
  getEvent(nameOrSignatureOrTopic: "OwnershipTransferred"): EventFragment;
  getEvent(nameOrSignatureOrTopic: "ReferralCommissionRecorded"): EventFragment;
  getEvent(nameOrSignatureOrTopic: "ReferralRecorded"): EventFragment;
}

export type OperatorUpdatedEvent = TypedEvent<
  [string, boolean] & { operator: string; status: boolean }
>;

export type OwnershipTransferredEvent = TypedEvent<
  [string, string] & { previousOwner: string; newOwner: string }
>;

export type ReferralCommissionRecordedEvent = TypedEvent<
  [string, BigNumber] & { referrer: string; commission: BigNumber }
>;

export type ReferralRecordedEvent = TypedEvent<
  [string, string] & { user: string; referrer: string }
>;

export class TGRReferral extends BaseContract {
  connect(signerOrProvider: Signer | Provider | string): this;
  attach(addressOrName: string): this;
  deployed(): Promise<this>;

  listeners<EventArgsArray extends Array<any>, EventArgsObject>(
    eventFilter?: TypedEventFilter<EventArgsArray, EventArgsObject>
  ): Array<TypedListener<EventArgsArray, EventArgsObject>>;
  off<EventArgsArray extends Array<any>, EventArgsObject>(
    eventFilter: TypedEventFilter<EventArgsArray, EventArgsObject>,
    listener: TypedListener<EventArgsArray, EventArgsObject>
  ): this;
  on<EventArgsArray extends Array<any>, EventArgsObject>(
    eventFilter: TypedEventFilter<EventArgsArray, EventArgsObject>,
    listener: TypedListener<EventArgsArray, EventArgsObject>
  ): this;
  once<EventArgsArray extends Array<any>, EventArgsObject>(
    eventFilter: TypedEventFilter<EventArgsArray, EventArgsObject>,
    listener: TypedListener<EventArgsArray, EventArgsObject>
  ): this;
  removeListener<EventArgsArray extends Array<any>, EventArgsObject>(
    eventFilter: TypedEventFilter<EventArgsArray, EventArgsObject>,
    listener: TypedListener<EventArgsArray, EventArgsObject>
  ): this;
  removeAllListeners<EventArgsArray extends Array<any>, EventArgsObject>(
    eventFilter: TypedEventFilter<EventArgsArray, EventArgsObject>
  ): this;

  listeners(eventName?: string): Array<Listener>;
  off(eventName: string, listener: Listener): this;
  on(eventName: string, listener: Listener): this;
  once(eventName: string, listener: Listener): this;
  removeListener(eventName: string, listener: Listener): this;
  removeAllListeners(eventName?: string): this;

  queryFilter<EventArgsArray extends Array<any>, EventArgsObject>(
    event: TypedEventFilter<EventArgsArray, EventArgsObject>,
    fromBlockOrBlockhash?: string | number | undefined,
    toBlock?: string | number | undefined
  ): Promise<Array<TypedEvent<EventArgsArray & EventArgsObject>>>;

  interface: TGRReferralInterface;

  functions: {
    countReferrals(
      arg0: string,
      overrides?: CallOverrides
    ): Promise<[BigNumber]>;

    getReferrer(_user: string, overrides?: CallOverrides): Promise<[string]>;

    owner(overrides?: CallOverrides): Promise<[string]>;

    recordReferral(
      _user: string,
      _referrer: string,
      overrides?: Overrides & { from?: string | Promise<string> }
    ): Promise<ContractTransaction>;

    recordReferralCommission(
      _referrer: string,
      _commission: BigNumberish,
      overrides?: Overrides & { from?: string | Promise<string> }
    ): Promise<ContractTransaction>;

    referrers(arg0: string, overrides?: CallOverrides): Promise<[string]>;

    renounceOwnership(
      overrides?: Overrides & { from?: string | Promise<string> }
    ): Promise<ContractTransaction>;

    totalReferralCommissions(
      arg0: string,
      overrides?: CallOverrides
    ): Promise<[BigNumber]>;

    transferOwnership(
      newOwner: string,
      overrides?: Overrides & { from?: string | Promise<string> }
    ): Promise<ContractTransaction>;
  };

  countReferrals(arg0: string, overrides?: CallOverrides): Promise<BigNumber>;

  getReferrer(_user: string, overrides?: CallOverrides): Promise<string>;

  owner(overrides?: CallOverrides): Promise<string>;

  recordReferral(
    _user: string,
    _referrer: string,
    overrides?: Overrides & { from?: string | Promise<string> }
  ): Promise<ContractTransaction>;

  recordReferralCommission(
    _referrer: string,
    _commission: BigNumberish,
    overrides?: Overrides & { from?: string | Promise<string> }
  ): Promise<ContractTransaction>;

  referrers(arg0: string, overrides?: CallOverrides): Promise<string>;

  renounceOwnership(
    overrides?: Overrides & { from?: string | Promise<string> }
  ): Promise<ContractTransaction>;

  totalReferralCommissions(
    arg0: string,
    overrides?: CallOverrides
  ): Promise<BigNumber>;

  transferOwnership(
    newOwner: string,
    overrides?: Overrides & { from?: string | Promise<string> }
  ): Promise<ContractTransaction>;

  callStatic: {
    countReferrals(arg0: string, overrides?: CallOverrides): Promise<BigNumber>;

    getReferrer(_user: string, overrides?: CallOverrides): Promise<string>;

    owner(overrides?: CallOverrides): Promise<string>;

    recordReferral(
      _user: string,
      _referrer: string,
      overrides?: CallOverrides
    ): Promise<void>;

    recordReferralCommission(
      _referrer: string,
      _commission: BigNumberish,
      overrides?: CallOverrides
    ): Promise<void>;

    referrers(arg0: string, overrides?: CallOverrides): Promise<string>;

    renounceOwnership(overrides?: CallOverrides): Promise<void>;

    totalReferralCommissions(
      arg0: string,
      overrides?: CallOverrides
    ): Promise<BigNumber>;

    transferOwnership(
      newOwner: string,
      overrides?: CallOverrides
    ): Promise<void>;
  };

  filters: {
    "OperatorUpdated(address,bool)"(
      operator?: string | null,
      status?: boolean | null
    ): TypedEventFilter<
      [string, boolean],
      { operator: string; status: boolean }
    >;

    OperatorUpdated(
      operator?: string | null,
      status?: boolean | null
    ): TypedEventFilter<
      [string, boolean],
      { operator: string; status: boolean }
    >;

    "OwnershipTransferred(address,address)"(
      previousOwner?: string | null,
      newOwner?: string | null
    ): TypedEventFilter<
      [string, string],
      { previousOwner: string; newOwner: string }
    >;

    OwnershipTransferred(
      previousOwner?: string | null,
      newOwner?: string | null
    ): TypedEventFilter<
      [string, string],
      { previousOwner: string; newOwner: string }
    >;

    "ReferralCommissionRecorded(address,uint256)"(
      referrer?: string | null,
      commission?: null
    ): TypedEventFilter<
      [string, BigNumber],
      { referrer: string; commission: BigNumber }
    >;

    ReferralCommissionRecorded(
      referrer?: string | null,
      commission?: null
    ): TypedEventFilter<
      [string, BigNumber],
      { referrer: string; commission: BigNumber }
    >;

    "ReferralRecorded(address,address)"(
      user?: string | null,
      referrer?: string | null
    ): TypedEventFilter<[string, string], { user: string; referrer: string }>;

    ReferralRecorded(
      user?: string | null,
      referrer?: string | null
    ): TypedEventFilter<[string, string], { user: string; referrer: string }>;
  };

  estimateGas: {
    countReferrals(arg0: string, overrides?: CallOverrides): Promise<BigNumber>;

    getReferrer(_user: string, overrides?: CallOverrides): Promise<BigNumber>;

    owner(overrides?: CallOverrides): Promise<BigNumber>;

    recordReferral(
      _user: string,
      _referrer: string,
      overrides?: Overrides & { from?: string | Promise<string> }
    ): Promise<BigNumber>;

    recordReferralCommission(
      _referrer: string,
      _commission: BigNumberish,
      overrides?: Overrides & { from?: string | Promise<string> }
    ): Promise<BigNumber>;

    referrers(arg0: string, overrides?: CallOverrides): Promise<BigNumber>;

    renounceOwnership(
      overrides?: Overrides & { from?: string | Promise<string> }
    ): Promise<BigNumber>;

    totalReferralCommissions(
      arg0: string,
      overrides?: CallOverrides
    ): Promise<BigNumber>;

    transferOwnership(
      newOwner: string,
      overrides?: Overrides & { from?: string | Promise<string> }
    ): Promise<BigNumber>;
  };

  populateTransaction: {
    countReferrals(
      arg0: string,
      overrides?: CallOverrides
    ): Promise<PopulatedTransaction>;

    getReferrer(
      _user: string,
      overrides?: CallOverrides
    ): Promise<PopulatedTransaction>;

    owner(overrides?: CallOverrides): Promise<PopulatedTransaction>;

    recordReferral(
      _user: string,
      _referrer: string,
      overrides?: Overrides & { from?: string | Promise<string> }
    ): Promise<PopulatedTransaction>;

    recordReferralCommission(
      _referrer: string,
      _commission: BigNumberish,
      overrides?: Overrides & { from?: string | Promise<string> }
    ): Promise<PopulatedTransaction>;

    referrers(
      arg0: string,
      overrides?: CallOverrides
    ): Promise<PopulatedTransaction>;

    renounceOwnership(
      overrides?: Overrides & { from?: string | Promise<string> }
    ): Promise<PopulatedTransaction>;

    totalReferralCommissions(
      arg0: string,
      overrides?: CallOverrides
    ): Promise<PopulatedTransaction>;

    transferOwnership(
      newOwner: string,
      overrides?: Overrides & { from?: string | Promise<string> }
    ): Promise<PopulatedTransaction>;
  };
}
