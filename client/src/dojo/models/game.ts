import { ComponentValue } from "@dojoengine/recs";

export class Game {
  public id: number;
  public host: bigint;
  public over: boolean;
  public seed: bigint;
  public player_count: number;
  public nonce: number;
  public price: bigint;
  public clock: bigint;
  public penalty: bigint;
  public limit: number;
  public config: number;

  constructor(game: ComponentValue) {
    this.id = game.id;
    this.host = BigInt(game.host);
    this.over = game.over;
    this.seed = BigInt(game.seed);
    this.player_count = game.player_count;
    this.nonce = game.nonce;
    this.price = BigInt(game.price);
    this.clock = BigInt(game.clock);
    this.penalty = BigInt(game.penalty);
    this.limit = game.limit;
    this.config = game.config;
  }

  public isOver(): boolean {
    return this.over;
  }
}
