/* Autogenerated file. Do not edit manually. */

import { DojoProvider } from "@dojoengine/core";
import { Config } from "../../../dojo.config.ts";
import { Account, UniversalDetails, shortString } from "starknet";

export interface Signer {
  account: Account;
}

export interface Create extends Signer {
  name: string;
  price: bigint;
  penalty: number;
}

export interface Join extends Signer {
  gameId: number;
  name: string;
}

export interface Leave extends Signer {
  gameId: number;
}

export interface Start extends Signer {
  gameId: number;
  roundLimit: number;
}

export interface Kick extends Signer {
  gameId: number;
  playerIndex: number;
}

export interface Promote extends Signer {
  gameId: number;
  playerIndex: number;
}

export interface Remove extends Signer {
  gameId: number;
}

export interface Claim extends Signer {
  gameId: number;
}

export interface Surrender extends Signer {
  gameId: number;
}

export interface Banish extends Signer {
  gameId: number;
}

export interface Attack extends Signer {
  gameId: number;
  attackerIndex: number;
  defenderIndex: number;
  dispatched: number;
  x: bigint;
  y: bigint;
  c: bigint;
  s: bigint;
  sqrt_ratio_hint: bigint;
  seed: bigint;
  beta: bigint;
}

export interface Defend extends Signer {
  gameId: number;
  attackerIndex: number;
  defenderIndex: number;
}

export interface Discard extends Signer {
  gameId: number;
  cardOne: number;
  cardTwo: number;
  cardThree: number;
}

export interface Finish extends Signer {
  gameId: number;
}

export interface Transfer extends Signer {
  gameId: number;
  sourceIndex: number;
  targetIndex: number;
  army: number;
}

export interface Supply extends Signer {
  gameId: number;
  tileIndex: number;
  supply: number;
}

export interface Emote extends Signer {
  gameId: number;
  playerIndex: number;
  emote: number;
}

export type IWorld = Awaited<ReturnType<typeof setupWorld>>;

export const getContractByName = (manifest: any, name: string) => {
  const contract = manifest.contracts.find((contract: any) =>
    contract.name.includes("::" + name),
  );
  if (contract) {
    return contract.address;
  } else {
    return "";
  }
};

export async function setupWorld(provider: DojoProvider, config: Config) {
  const details: UniversalDetails | undefined = undefined; // { maxFee: 1e15 };

  function play() {
    const contract_name = "play";
    const contract = config.manifest.contracts.find((c: any) =>
      c.name.includes(contract_name),
    );
    if (!contract) {
      throw new Error(`Contract ${contract_name} not found in manifest`);
    }

    const create = async ({ account, name, price, penalty }: Create) => {
      try {
        const encoded_name = shortString.encodeShortString(name);
        return await provider.execute(
          account,
          {
            contractName: contract_name,
            entrypoint: "create",
            calldata: [encoded_name, price, penalty],
          },
          details,
        );
      } catch (error) {
        console.error("Error executing create:", error);
        throw error;
      }
    };

    const join = async ({ account, gameId, name }: Join) => {
      try {
        const encoded_name = shortString.encodeShortString(name);
        return await provider.execute(
          account,
          {
            contractName: contract_name,
            entrypoint: "join",
            calldata: [gameId, encoded_name],
          },
          details,
        );
      } catch (error) {
        console.error("Error executing join:", error);
        throw error;
      }
    };

    const leave = async ({ account, gameId }: Leave) => {
      try {
        return await provider.execute(
          account,
          {
            contractName: contract_name,
            entrypoint: "leave",
            calldata: [gameId],
          },
          details,
        );
      } catch (error) {
        console.error("Error executing leave:", error);
        throw error;
      }
    };

    const start = async ({ account, gameId, roundLimit }: Start) => {
      try {
        return await provider.execute(
          account,
          {
            contractName: contract_name,
            entrypoint: "start",
            calldata: [gameId, roundLimit],
          },
          details,
        );
      } catch (error) {
        console.error("Error executing start:", error);
        throw error;
      }
    };

    const kick = async ({ account, gameId, playerIndex }: Kick) => {
      try {
        return await provider.execute(
          account,
          {
            contractName: contract_name,
            entrypoint: "kick",
            calldata: [gameId, playerIndex],
          },
          details,
        );
      } catch (error) {
        console.error("Error executing kick:", error);
        throw error;
      }
    };

    const promote = async ({ account, gameId, playerIndex }: Promote) => {
      try {
        return await provider.execute(
          account,
          {
            contractName: contract_name,
            entrypoint: "promote",
            calldata: [gameId, playerIndex],
          },
          details,
        );
      } catch (error) {
        console.error("Error executing promote:", error);
        throw error;
      }
    };

    const remove = async ({ account, gameId }: Remove) => {
      try {
        return await provider.execute(
          account,
          {
            contractName: contract_name,
            entrypoint: "delete", // delete is not allowed as variable in ts
            calldata: [gameId],
          },
          details,
        );
      } catch (error) {
        console.error("Error executing remove:", error);
        throw error;
      }
    };

    const claim = async ({ account, gameId }: Claim) => {
      try {
        return await provider.execute(
          account,
          {
            contractName: contract_name,
            entrypoint: "claim",
            calldata: [gameId],
          },
          details,
        );
      } catch (error) {
        console.error("Error executing claim:", error);
        throw error;
      }
    };

    const surrender = async ({ account, gameId }: Surrender) => {
      try {
        return await provider.execute(
          account,
          {
            contractName: contract_name,
            entrypoint: "surrender",
            calldata: [gameId],
          },
          details,
        );
      } catch (error) {
        console.error("Error executing surrender:", error);
        throw error;
      }
    };

    const banish = async ({ account, gameId }: Banish) => {
      try {
        return await provider.execute(
          account,
          {
            contractName: contract_name,
            entrypoint: "banish",
            calldata: [gameId],
          },
          details,
        );
      } catch (error) {
        console.error("Error executing banish:", error);
        throw error;
      }
    };

    const attack = async ({
      account,
      gameId,
      attackerIndex,
      defenderIndex,
      dispatched,
      x,
      y,
      c,
      s,
      sqrt_ratio_hint,
      seed,
      beta,
    }: Attack) => {
      try {
        return await provider.execute(
          account,
          {
            contractName: contract_name,
            entrypoint: "attack",
            calldata: [
              gameId,
              attackerIndex,
              defenderIndex,
              dispatched,
              x,
              y,
              c,
              s,
              sqrt_ratio_hint,
              seed,
              beta,
            ],
          },
          details,
        );
      } catch (error) {
        console.error("Error executing attack:", error);
        throw error;
      }
    };

    const defend = async ({
      account,
      gameId,
      attackerIndex,
      defenderIndex,
    }: Defend) => {
      try {
        return await provider.execute(
          account,
          {
            contractName: contract_name,
            entrypoint: "defend",
            calldata: [gameId, attackerIndex, defenderIndex],
          },
          details,
        );
      } catch (error) {
        console.error("Error executing defend:", error);
        throw error;
      }
    };

    const discard = async ({
      account,
      gameId,
      cardOne,
      cardTwo,
      cardThree,
    }: Discard) => {
      try {
        return await provider.execute(
          account,
          {
            contractName: contract_name,
            entrypoint: "discard",
            calldata: [gameId, cardOne, cardTwo, cardThree],
          },
          details,
        );
      } catch (error) {
        console.error("Error executing discard:", error);
        throw error;
      }
    };

    const finish = async ({ account, gameId }: Finish) => {
      try {
        return await provider.execute(
          account,
          {
            contractName: contract_name,
            entrypoint: "finish",
            calldata: [gameId],
          },
          details,
        );
      } catch (error) {
        console.error("Error executing finish:", error);
        throw error;
      }
    };

    const transfer = async ({
      account,
      gameId,
      sourceIndex,
      targetIndex,
      army,
    }: Transfer) => {
      try {
        return await provider.execute(
          account,
          {
            contractName: contract_name,
            entrypoint: "transfer",
            calldata: [gameId, sourceIndex, targetIndex, army],
          },
          details,
        );
      } catch (error) {
        console.error("Error executing transfer:", error);
        throw error;
      }
    };

    const supply = async ({ account, gameId, tileIndex, supply }: Supply) => {
      try {
        return await provider.execute(
          account,
          {
            contractName: contract_name,
            entrypoint: "supply",
            calldata: [gameId, tileIndex, supply],
          },
          details,
        );
      } catch (error) {
        console.error("Error executing supply:", error);
        throw error;
      }
    };

    const emote = async ({ account, gameId, playerIndex, emote }: Emote) => {
      try {
        return await provider.execute(
          account,
          {
            contractName: contract_name,
            entrypoint: "emote",
            calldata: [gameId, playerIndex, emote],
          },
          details,
        );
      } catch (error) {
        console.error("Error executing emote:", error);
        throw error;
      }
    };

    return {
      address: contract.address,
      create,
      join,
      leave,
      start,
      kick,
      promote,
      remove,
      claim,
      surrender,
      banish,
      attack,
      defend,
      discard,
      finish,
      transfer,
      supply,
      emote,
    };
  }

  return {
    play: play(),
  };
}
