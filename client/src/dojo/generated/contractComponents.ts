/* Autogenerated file. Do not edit manually. */

import { defineComponent, Type as RecsType, World } from "@dojoengine/recs";

export type ContractComponents = Awaited<
  ReturnType<typeof defineContractComponents>
>;

export function defineContractComponents(world: World) {
  return {
    Game: (() => {
      return defineComponent(
        world,
        {
          id: RecsType.Number,
          host: RecsType.BigInt,
          over: RecsType.Boolean,
          seed: RecsType.BigInt,
          player_count: RecsType.Number,
          nonce: RecsType.Number,
          price: RecsType.BigInt,
          clock: RecsType.BigInt,
          penalty: RecsType.BigInt,
          limit: RecsType.Number,
          config: RecsType.Number,
        },
        {
          metadata: {
            name: "Game",
            types: [
              "u32",
              "felt252",
              "bool",
              "felt252",
              "u8",
              "u32",
              "u256",
              "u64",
              "u64",
              "u32",
              "u8",
            ],
            customTypes: [],
          },
        }
      );
    })(),
    Player: (() => {
      return defineComponent(
        world,
        {
          game_id: RecsType.Number,
          index: RecsType.Number,
          address: RecsType.BigInt,
          name: RecsType.BigInt,
          supply: RecsType.Number,
          cards: RecsType.BigInt,
          conqueror: RecsType.Boolean,
          rank: RecsType.Number,
        },
        {
          metadata: {
            name: "Player",
            types: [
              "u32",
              "u32",
              "felt252",
              "felt252",
              "u32",
              "u128",
              "bool",
              "u8",
            ],
            customTypes: [],
          },
        }
      );
    })(),
    Tile: (() => {
      return defineComponent(
        world,
        {
          game_id: RecsType.Number,
          id: RecsType.Number,
          army: RecsType.Number,
          owner: RecsType.Number,
          dispatched: RecsType.Number,
          to: RecsType.Number,
          from: RecsType.Number,
          order: RecsType.BigInt,
        },
        {
          metadata: {
            name: "Tile",
            types: ["u32", "u8", "u32", "u32", "u32", "u8", "u8", "felt252"],
            customTypes: [],
          },
        }
      );
    })(),
  };
}
