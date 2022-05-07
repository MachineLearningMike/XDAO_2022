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
  CallOverrides,
} from "ethers";
import { BytesLike } from "@ethersproject/bytes";
import { Listener, Provider } from "@ethersproject/providers";
import { FunctionFragment, EventFragment, Result } from "@ethersproject/abi";
import type { TypedEventFilter, TypedEvent, TypedListener } from "./common";

interface FarmLibInterface extends ethers.utils.Interface {
  functions: {
    "buildStandardPool(address,uint256,uint256,uint256)": FunctionFragment;
    "getMultiplier(uint256,uint256,uint256)": FunctionFragment;
  };

  encodeFunctionData(
    functionFragment: "buildStandardPool",
    values: [string, BigNumberish, BigNumberish, BigNumberish]
  ): string;
  encodeFunctionData(
    functionFragment: "getMultiplier",
    values: [BigNumberish, BigNumberish, BigNumberish]
  ): string;

  decodeFunctionResult(
    functionFragment: "buildStandardPool",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "getMultiplier",
    data: BytesLike
  ): Result;

  events: {
    "SetMigrator(address)": EventFragment;
  };

  getEvent(nameOrSignatureOrTopic: "SetMigrator"): EventFragment;
}

export type SetMigratorEvent = TypedEvent<[string] & { migrator: string }>;

export class FarmLib extends BaseContract {
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

  interface: FarmLibInterface;

  functions: {
    buildStandardPool(
      lp: string,
      allocPoint: BigNumberish,
      startBlock: BigNumberish,
      depositFeeRate: BigNumberish,
      overrides?: CallOverrides
    ): Promise<
      [
        [
          string,
          BigNumber,
          BigNumber,
          BigNumber,
          BigNumber,
          BigNumber,
          [
            BigNumber,
            [BigNumber, BigNumber] & { bulk: BigNumber; accPerShare: BigNumber }
          ] & {
            sumAmount: BigNumber;
            Comp: [BigNumber, BigNumber] & {
              bulk: BigNumber;
              accPerShare: BigNumber;
            };
          },
          [
            BigNumber,
            [BigNumber, BigNumber] & {
              bulk: BigNumber;
              accPerShare: BigNumber;
            },
            [BigNumber, BigNumber] & { bulk: BigNumber; accPerShare: BigNumber }
          ] & {
            sumAmount: BigNumber;
            Comp: [BigNumber, BigNumber] & {
              bulk: BigNumber;
              accPerShare: BigNumber;
            };
            Vest: [BigNumber, BigNumber] & {
              bulk: BigNumber;
              accPerShare: BigNumber;
            };
          },
          [
            BigNumber,
            [BigNumber, BigNumber] & {
              bulk: BigNumber;
              accPerShare: BigNumber;
            },
            [BigNumber, BigNumber] & { bulk: BigNumber; accPerShare: BigNumber }
          ] & {
            sumAmount: BigNumber;
            Vest: [BigNumber, BigNumber] & {
              bulk: BigNumber;
              accPerShare: BigNumber;
            };
            Accum: [BigNumber, BigNumber] & {
              bulk: BigNumber;
              accPerShare: BigNumber;
            };
          },
          [
            BigNumber,
            [BigNumber, BigNumber] & { bulk: BigNumber; accPerShare: BigNumber }
          ] & {
            sumAmount: BigNumber;
            Accum: [BigNumber, BigNumber] & {
              bulk: BigNumber;
              accPerShare: BigNumber;
            };
          }
        ] & {
          lpToken: string;
          allocPoint: BigNumber;
          lastRewardBlock: BigNumber;
          accTGRPerShare: BigNumber;
          depositFeeRate: BigNumber;
          reward: BigNumber;
          OnOff: [
            BigNumber,
            [BigNumber, BigNumber] & { bulk: BigNumber; accPerShare: BigNumber }
          ] & {
            sumAmount: BigNumber;
            Comp: [BigNumber, BigNumber] & {
              bulk: BigNumber;
              accPerShare: BigNumber;
            };
          };
          OnOn: [
            BigNumber,
            [BigNumber, BigNumber] & {
              bulk: BigNumber;
              accPerShare: BigNumber;
            },
            [BigNumber, BigNumber] & { bulk: BigNumber; accPerShare: BigNumber }
          ] & {
            sumAmount: BigNumber;
            Comp: [BigNumber, BigNumber] & {
              bulk: BigNumber;
              accPerShare: BigNumber;
            };
            Vest: [BigNumber, BigNumber] & {
              bulk: BigNumber;
              accPerShare: BigNumber;
            };
          };
          OffOn: [
            BigNumber,
            [BigNumber, BigNumber] & {
              bulk: BigNumber;
              accPerShare: BigNumber;
            },
            [BigNumber, BigNumber] & { bulk: BigNumber; accPerShare: BigNumber }
          ] & {
            sumAmount: BigNumber;
            Vest: [BigNumber, BigNumber] & {
              bulk: BigNumber;
              accPerShare: BigNumber;
            };
            Accum: [BigNumber, BigNumber] & {
              bulk: BigNumber;
              accPerShare: BigNumber;
            };
          };
          OffOff: [
            BigNumber,
            [BigNumber, BigNumber] & { bulk: BigNumber; accPerShare: BigNumber }
          ] & {
            sumAmount: BigNumber;
            Accum: [BigNumber, BigNumber] & {
              bulk: BigNumber;
              accPerShare: BigNumber;
            };
          };
        }
      ] & {
        pool: [
          string,
          BigNumber,
          BigNumber,
          BigNumber,
          BigNumber,
          BigNumber,
          [
            BigNumber,
            [BigNumber, BigNumber] & { bulk: BigNumber; accPerShare: BigNumber }
          ] & {
            sumAmount: BigNumber;
            Comp: [BigNumber, BigNumber] & {
              bulk: BigNumber;
              accPerShare: BigNumber;
            };
          },
          [
            BigNumber,
            [BigNumber, BigNumber] & {
              bulk: BigNumber;
              accPerShare: BigNumber;
            },
            [BigNumber, BigNumber] & { bulk: BigNumber; accPerShare: BigNumber }
          ] & {
            sumAmount: BigNumber;
            Comp: [BigNumber, BigNumber] & {
              bulk: BigNumber;
              accPerShare: BigNumber;
            };
            Vest: [BigNumber, BigNumber] & {
              bulk: BigNumber;
              accPerShare: BigNumber;
            };
          },
          [
            BigNumber,
            [BigNumber, BigNumber] & {
              bulk: BigNumber;
              accPerShare: BigNumber;
            },
            [BigNumber, BigNumber] & { bulk: BigNumber; accPerShare: BigNumber }
          ] & {
            sumAmount: BigNumber;
            Vest: [BigNumber, BigNumber] & {
              bulk: BigNumber;
              accPerShare: BigNumber;
            };
            Accum: [BigNumber, BigNumber] & {
              bulk: BigNumber;
              accPerShare: BigNumber;
            };
          },
          [
            BigNumber,
            [BigNumber, BigNumber] & { bulk: BigNumber; accPerShare: BigNumber }
          ] & {
            sumAmount: BigNumber;
            Accum: [BigNumber, BigNumber] & {
              bulk: BigNumber;
              accPerShare: BigNumber;
            };
          }
        ] & {
          lpToken: string;
          allocPoint: BigNumber;
          lastRewardBlock: BigNumber;
          accTGRPerShare: BigNumber;
          depositFeeRate: BigNumber;
          reward: BigNumber;
          OnOff: [
            BigNumber,
            [BigNumber, BigNumber] & { bulk: BigNumber; accPerShare: BigNumber }
          ] & {
            sumAmount: BigNumber;
            Comp: [BigNumber, BigNumber] & {
              bulk: BigNumber;
              accPerShare: BigNumber;
            };
          };
          OnOn: [
            BigNumber,
            [BigNumber, BigNumber] & {
              bulk: BigNumber;
              accPerShare: BigNumber;
            },
            [BigNumber, BigNumber] & { bulk: BigNumber; accPerShare: BigNumber }
          ] & {
            sumAmount: BigNumber;
            Comp: [BigNumber, BigNumber] & {
              bulk: BigNumber;
              accPerShare: BigNumber;
            };
            Vest: [BigNumber, BigNumber] & {
              bulk: BigNumber;
              accPerShare: BigNumber;
            };
          };
          OffOn: [
            BigNumber,
            [BigNumber, BigNumber] & {
              bulk: BigNumber;
              accPerShare: BigNumber;
            },
            [BigNumber, BigNumber] & { bulk: BigNumber; accPerShare: BigNumber }
          ] & {
            sumAmount: BigNumber;
            Vest: [BigNumber, BigNumber] & {
              bulk: BigNumber;
              accPerShare: BigNumber;
            };
            Accum: [BigNumber, BigNumber] & {
              bulk: BigNumber;
              accPerShare: BigNumber;
            };
          };
          OffOff: [
            BigNumber,
            [BigNumber, BigNumber] & { bulk: BigNumber; accPerShare: BigNumber }
          ] & {
            sumAmount: BigNumber;
            Accum: [BigNumber, BigNumber] & {
              bulk: BigNumber;
              accPerShare: BigNumber;
            };
          };
        };
      }
    >;

    getMultiplier(
      _from: BigNumberish,
      _to: BigNumberish,
      bonusMultiplier: BigNumberish,
      overrides?: CallOverrides
    ): Promise<[BigNumber]>;
  };

  buildStandardPool(
    lp: string,
    allocPoint: BigNumberish,
    startBlock: BigNumberish,
    depositFeeRate: BigNumberish,
    overrides?: CallOverrides
  ): Promise<
    [
      string,
      BigNumber,
      BigNumber,
      BigNumber,
      BigNumber,
      BigNumber,
      [
        BigNumber,
        [BigNumber, BigNumber] & { bulk: BigNumber; accPerShare: BigNumber }
      ] & {
        sumAmount: BigNumber;
        Comp: [BigNumber, BigNumber] & {
          bulk: BigNumber;
          accPerShare: BigNumber;
        };
      },
      [
        BigNumber,
        [BigNumber, BigNumber] & { bulk: BigNumber; accPerShare: BigNumber },
        [BigNumber, BigNumber] & { bulk: BigNumber; accPerShare: BigNumber }
      ] & {
        sumAmount: BigNumber;
        Comp: [BigNumber, BigNumber] & {
          bulk: BigNumber;
          accPerShare: BigNumber;
        };
        Vest: [BigNumber, BigNumber] & {
          bulk: BigNumber;
          accPerShare: BigNumber;
        };
      },
      [
        BigNumber,
        [BigNumber, BigNumber] & { bulk: BigNumber; accPerShare: BigNumber },
        [BigNumber, BigNumber] & { bulk: BigNumber; accPerShare: BigNumber }
      ] & {
        sumAmount: BigNumber;
        Vest: [BigNumber, BigNumber] & {
          bulk: BigNumber;
          accPerShare: BigNumber;
        };
        Accum: [BigNumber, BigNumber] & {
          bulk: BigNumber;
          accPerShare: BigNumber;
        };
      },
      [
        BigNumber,
        [BigNumber, BigNumber] & { bulk: BigNumber; accPerShare: BigNumber }
      ] & {
        sumAmount: BigNumber;
        Accum: [BigNumber, BigNumber] & {
          bulk: BigNumber;
          accPerShare: BigNumber;
        };
      }
    ] & {
      lpToken: string;
      allocPoint: BigNumber;
      lastRewardBlock: BigNumber;
      accTGRPerShare: BigNumber;
      depositFeeRate: BigNumber;
      reward: BigNumber;
      OnOff: [
        BigNumber,
        [BigNumber, BigNumber] & { bulk: BigNumber; accPerShare: BigNumber }
      ] & {
        sumAmount: BigNumber;
        Comp: [BigNumber, BigNumber] & {
          bulk: BigNumber;
          accPerShare: BigNumber;
        };
      };
      OnOn: [
        BigNumber,
        [BigNumber, BigNumber] & { bulk: BigNumber; accPerShare: BigNumber },
        [BigNumber, BigNumber] & { bulk: BigNumber; accPerShare: BigNumber }
      ] & {
        sumAmount: BigNumber;
        Comp: [BigNumber, BigNumber] & {
          bulk: BigNumber;
          accPerShare: BigNumber;
        };
        Vest: [BigNumber, BigNumber] & {
          bulk: BigNumber;
          accPerShare: BigNumber;
        };
      };
      OffOn: [
        BigNumber,
        [BigNumber, BigNumber] & { bulk: BigNumber; accPerShare: BigNumber },
        [BigNumber, BigNumber] & { bulk: BigNumber; accPerShare: BigNumber }
      ] & {
        sumAmount: BigNumber;
        Vest: [BigNumber, BigNumber] & {
          bulk: BigNumber;
          accPerShare: BigNumber;
        };
        Accum: [BigNumber, BigNumber] & {
          bulk: BigNumber;
          accPerShare: BigNumber;
        };
      };
      OffOff: [
        BigNumber,
        [BigNumber, BigNumber] & { bulk: BigNumber; accPerShare: BigNumber }
      ] & {
        sumAmount: BigNumber;
        Accum: [BigNumber, BigNumber] & {
          bulk: BigNumber;
          accPerShare: BigNumber;
        };
      };
    }
  >;

  getMultiplier(
    _from: BigNumberish,
    _to: BigNumberish,
    bonusMultiplier: BigNumberish,
    overrides?: CallOverrides
  ): Promise<BigNumber>;

  callStatic: {
    buildStandardPool(
      lp: string,
      allocPoint: BigNumberish,
      startBlock: BigNumberish,
      depositFeeRate: BigNumberish,
      overrides?: CallOverrides
    ): Promise<
      [
        string,
        BigNumber,
        BigNumber,
        BigNumber,
        BigNumber,
        BigNumber,
        [
          BigNumber,
          [BigNumber, BigNumber] & { bulk: BigNumber; accPerShare: BigNumber }
        ] & {
          sumAmount: BigNumber;
          Comp: [BigNumber, BigNumber] & {
            bulk: BigNumber;
            accPerShare: BigNumber;
          };
        },
        [
          BigNumber,
          [BigNumber, BigNumber] & { bulk: BigNumber; accPerShare: BigNumber },
          [BigNumber, BigNumber] & { bulk: BigNumber; accPerShare: BigNumber }
        ] & {
          sumAmount: BigNumber;
          Comp: [BigNumber, BigNumber] & {
            bulk: BigNumber;
            accPerShare: BigNumber;
          };
          Vest: [BigNumber, BigNumber] & {
            bulk: BigNumber;
            accPerShare: BigNumber;
          };
        },
        [
          BigNumber,
          [BigNumber, BigNumber] & { bulk: BigNumber; accPerShare: BigNumber },
          [BigNumber, BigNumber] & { bulk: BigNumber; accPerShare: BigNumber }
        ] & {
          sumAmount: BigNumber;
          Vest: [BigNumber, BigNumber] & {
            bulk: BigNumber;
            accPerShare: BigNumber;
          };
          Accum: [BigNumber, BigNumber] & {
            bulk: BigNumber;
            accPerShare: BigNumber;
          };
        },
        [
          BigNumber,
          [BigNumber, BigNumber] & { bulk: BigNumber; accPerShare: BigNumber }
        ] & {
          sumAmount: BigNumber;
          Accum: [BigNumber, BigNumber] & {
            bulk: BigNumber;
            accPerShare: BigNumber;
          };
        }
      ] & {
        lpToken: string;
        allocPoint: BigNumber;
        lastRewardBlock: BigNumber;
        accTGRPerShare: BigNumber;
        depositFeeRate: BigNumber;
        reward: BigNumber;
        OnOff: [
          BigNumber,
          [BigNumber, BigNumber] & { bulk: BigNumber; accPerShare: BigNumber }
        ] & {
          sumAmount: BigNumber;
          Comp: [BigNumber, BigNumber] & {
            bulk: BigNumber;
            accPerShare: BigNumber;
          };
        };
        OnOn: [
          BigNumber,
          [BigNumber, BigNumber] & { bulk: BigNumber; accPerShare: BigNumber },
          [BigNumber, BigNumber] & { bulk: BigNumber; accPerShare: BigNumber }
        ] & {
          sumAmount: BigNumber;
          Comp: [BigNumber, BigNumber] & {
            bulk: BigNumber;
            accPerShare: BigNumber;
          };
          Vest: [BigNumber, BigNumber] & {
            bulk: BigNumber;
            accPerShare: BigNumber;
          };
        };
        OffOn: [
          BigNumber,
          [BigNumber, BigNumber] & { bulk: BigNumber; accPerShare: BigNumber },
          [BigNumber, BigNumber] & { bulk: BigNumber; accPerShare: BigNumber }
        ] & {
          sumAmount: BigNumber;
          Vest: [BigNumber, BigNumber] & {
            bulk: BigNumber;
            accPerShare: BigNumber;
          };
          Accum: [BigNumber, BigNumber] & {
            bulk: BigNumber;
            accPerShare: BigNumber;
          };
        };
        OffOff: [
          BigNumber,
          [BigNumber, BigNumber] & { bulk: BigNumber; accPerShare: BigNumber }
        ] & {
          sumAmount: BigNumber;
          Accum: [BigNumber, BigNumber] & {
            bulk: BigNumber;
            accPerShare: BigNumber;
          };
        };
      }
    >;

    getMultiplier(
      _from: BigNumberish,
      _to: BigNumberish,
      bonusMultiplier: BigNumberish,
      overrides?: CallOverrides
    ): Promise<BigNumber>;
  };

  filters: {
    "SetMigrator(address)"(
      migrator?: null
    ): TypedEventFilter<[string], { migrator: string }>;

    SetMigrator(
      migrator?: null
    ): TypedEventFilter<[string], { migrator: string }>;
  };

  estimateGas: {
    buildStandardPool(
      lp: string,
      allocPoint: BigNumberish,
      startBlock: BigNumberish,
      depositFeeRate: BigNumberish,
      overrides?: CallOverrides
    ): Promise<BigNumber>;

    getMultiplier(
      _from: BigNumberish,
      _to: BigNumberish,
      bonusMultiplier: BigNumberish,
      overrides?: CallOverrides
    ): Promise<BigNumber>;
  };

  populateTransaction: {
    buildStandardPool(
      lp: string,
      allocPoint: BigNumberish,
      startBlock: BigNumberish,
      depositFeeRate: BigNumberish,
      overrides?: CallOverrides
    ): Promise<PopulatedTransaction>;

    getMultiplier(
      _from: BigNumberish,
      _to: BigNumberish,
      bonusMultiplier: BigNumberish,
      overrides?: CallOverrides
    ): Promise<PopulatedTransaction>;
  };
}