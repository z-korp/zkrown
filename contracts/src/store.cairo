//! Store struct and component management methods.

// Straknet imports

use starknet::ContractAddress;

// Dojo imports

use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

// Components imports

use zkrown::models::game::{Game, GameTrait};
use zkrown::models::player::{Player, PlayerTrait, ZeroablePlayer};
use zkrown::models::tile::Tile;
use zkrown::types::map::{Map, MapTrait};
use zkrown::types::config::{Config, ConfigTrait};

/// Store struct.
#[derive(Drop)]
struct Store {
    world: IWorldDispatcher
}

/// Implementation of the `StoreTrait` trait for the `Store` struct.
#[generate_trait]
impl StoreImpl of StoreTrait {
    #[inline(always)]
    fn new(world: IWorldDispatcher) -> Store {
        Store { world: world }
    }

    #[inline(always)]
    fn game(ref self: Store, id: u32) -> Game {
        get!(self.world, id, (Game))
    }

    #[inline(always)]
    fn player(ref self: Store, game: Game, index: u32) -> Player {
        get!(self.world, (game.id, index), (Player))
    }

    fn players(ref self: Store, game: Game) -> Array<Player> {
        let mut index = game.player_count;
        let mut players: Array<Player> = array![];
        loop {
            if index == 0 {
                break;
            };
            index -= 1;
            players.append(self.player(game, index.into()));
        };
        players
    }

    #[inline(always)]
    fn current_player(ref self: Store, game: Game) -> Player {
        let _player_key = (game.id, game.player());
        get!(self.world, _player_key.into(), (Player))
    }

    #[inline(always)]
    fn next_player(ref self: Store, game: Game) -> Player {
        let _player_key = (game.id, game.next_player());
        get!(self.world, _player_key.into(), (Player))
    }

    fn find_player(ref self: Store, game: Game, account: ContractAddress) -> Option<Player> {
        let mut index: u32 = game.player_count.into();
        loop {
            index -= 1;
            let player: Player = self.player(game, index.into());
            if player.address == account.into() {
                break Option::Some(player);
            }
            if index == 0 {
                break Option::None;
            };
        }
    }

    fn find_ranked_player(ref self: Store, game: Game, rank: u8) -> Option<Player> {
        let mut index: u32 = game.player_count.into();
        loop {
            index -= 1;
            let player: Player = self.player(game, index.into());
            if player.rank == rank {
                break Option::Some(player);
            }
            if index == 0 {
                break Option::None;
            };
        }
    }

    fn get_next_rank(ref self: Store, game: Game) -> u8 {
        let mut index = game.player_count;
        let mut rank: u8 = game.player_count + 1;
        loop {
            if index == 0 {
                break;
            };
            index -= 1;
            let player = self.player(game, index.into());
            if player.rank > 0 && player.rank < rank {
                rank = player.rank;
            };
        };
        rank - 1
    }

    fn get_last_unranked_player(ref self: Store, game: Game, ref map: Map) -> Option<Player> {
        let mut index = game.player_count;
        let mut score = 0;
        let mut last: Player = ZeroablePlayer::zero();
        loop {
            if index == 0 {
                break;
            };
            index -= 1;
            let player = self.player(game, index.into());
            let player_score = map.player_score(player.index);
            if player.rank == 0 && (player_score < score || score == 0) {
                last = player;
            };
        };
        if last.is_zero() {
            Option::None
        } else {
            Option::Some(last)
        }
    }

    #[inline(always)]
    fn tile(ref self: Store, game: Game, id: u8) -> Tile {
        let _tile_key = (game.id, id);
        get!(self.world, _tile_key.into(), (Tile))
    }

    fn tiles(ref self: Store, game: Game) -> Array<Tile> {
        let config: Config = game.config.into();
        let mut id: u8 = config.tile_number().try_into().unwrap();
        let mut tiles: Array<Tile> = array![];
        loop {
            if id == 0 {
                break;
            };
            tiles.append(self.tile(game, id));
            id -= 1;
        };
        tiles
    }

    #[inline(always)]
    fn set_game(ref self: Store, game: Game) {
        set!(self.world, (game));
    }

    #[inline(always)]
    fn set_player(ref self: Store, player: Player) {
        set!(self.world, (player));
    }

    fn set_players(ref self: Store, mut players: Span<Player>) {
        loop {
            match players.pop_front() {
                Option::Some(player) => self.set_player(*player),
                Option::None => { break; },
            };
        };
    }

    #[inline(always)]
    fn set_tile(ref self: Store, tile: Tile) {
        set!(self.world, (tile));
    }

    fn set_tiles(ref self: Store, mut tiles: Span<Tile>) {
        loop {
            match tiles.pop_front() {
                Option::Some(tile) => self.set_tile(*tile),
                Option::None => { break; },
            };
        };
    }
}
