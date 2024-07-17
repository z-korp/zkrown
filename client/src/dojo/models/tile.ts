import { ComponentValue } from "@dojoengine/recs";

export class Tile {
  public game_id: number;
  public id: number;
  public army: number;
  public owner: number;
  public dispatched: number;
  public to: number;
  public from: number;
  public order: bigint;

  constructor(tile: ComponentValue) {
    this.game_id = tile.game_id;
    this.id = tile.id;
    this.army = tile.army;
    this.owner = tile.owner;
    this.dispatched = tile.dispatched;
    this.to = tile.to;
    this.from = tile.from;
    this.order = BigInt(tile.order);
  }
}
