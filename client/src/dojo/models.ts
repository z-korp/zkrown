import { Game } from ".//models/game";
import { Player } from "./models/player";
import { Tile } from "./models/tile";
import { ContractComponents } from "./generated/contractModels";
import { overridableComponent } from "@dojoengine/recs";

export type ClientModels = ReturnType<typeof models>;

export function models({
  contractModels,
}: {
  contractModels: ContractComponents;
}) {
  return {
    models: {
      ...contractModels,
      Tile: overridableComponent(contractModels.Tile), // we need to override the Tile component
    },
    classes: {
      Game,
      Tile,
      Player,
    },
  };
}
