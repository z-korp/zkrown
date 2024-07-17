import { ComponentValue } from "@dojoengine/recs";

export class Player {
  public game_id: number;
  public index: number;
  public address: bigint;
  public name: bigint;
  public supply: number;
  public cards: bigint;
  public conqueror: boolean;
  public rank: number;

  constructor(player: ComponentValue) {
    this.game_id = player.game_id;
    this.index = player.index;
    this.address = BigInt(player.address);
    this.name = BigInt(player.name);
    this.supply = player.supply;
    this.cards = BigInt(player.cards);
    this.conqueror = player.conqueror;
    this.rank = player.rank;
  }
}
