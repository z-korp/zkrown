import { Game } from ".//models/game";
import { Player } from "./models/player";
import { Tile } from "./models/tile";
import { ContractComponents } from "./generated/contractModels";

export type ClientModels = ReturnType<typeof models>;

export function models({
  contractModels,
}: {
  contractModels: ContractComponents;
}) {
  return {
    models: {
      ...contractModels,
    },
    classes: {
      Game,
      Tile,
      Player,
    },
  };
}
