// Core imports

use core::debug::PrintTrait;

// Starknet imports

use starknet::testing::set_contract_address;

// Dojo imports

use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

// Internal imports

use zkrown::types::config::{Config, ConfigTrait};
use zkrown::store::{Store, StoreTrait};
use zkrown::models::game::{Game, GameTrait};
use zkrown::models::player::Player;
use zkrown::models::tile::Tile;
use zkrown::systems::play::{IHostDispatcherTrait, IPlayDispatcherTrait};
use zkrown::tests::setup::{setup, setup::{Systems, HOST, PLAYER, ANYONE}};

// Constants

const HOST_NAME: felt252 = 'HOST';
const PLAYER_NAME: felt252 = 'PLAYER';
const PRICE: u256 = 1_000_000_000_000_000_000;
const PENALTY: u64 = 60;
const PLAYER_COUNT: u8 = 2;
const PLAYER_INDEX: u32 = 0;
const ROUND_COUNT: u32 = 10;

#[test]
#[available_gas(1_000_000_000)]
fn test_transfer_valid() {
    // [Setup]
    let (world, systems, context) = setup::spawn_game();
    let mut store = StoreTrait::new(world);

    // [Create]
    let game_id = systems.host.create(HOST_NAME, PRICE, PENALTY);
    set_contract_address(PLAYER());
    systems.host.join(game_id, PLAYER_NAME);
    set_contract_address(HOST());
    systems.host.start(game_id, ROUND_COUNT);

    // [Compute] Tile army and player available supply
    let game: Game = store.game(game_id);
    let player: Player = store.player(game, PLAYER_INDEX);
    let supply: u32 = player.supply.into();
    let mut tile_index: u8 = 1;
    loop {
        let tile: Tile = store.tile(game, tile_index);
        if tile.owner == PLAYER_INDEX.into() {
            break;
        }
        tile_index += 1;
    };

    // [Supply]
    let contract_address = starknet::contract_address_try_from_felt252(player.address);
    set_contract_address(contract_address.unwrap());
    systems.play.supply(game_id, tile_index, supply);

    // [Finish]
    systems.play.finish(game_id);

    // [Finish]
    systems.play.finish(game_id);

    // [Compute] First 2 owned tiles
    let mut tiles: Array<Tile> = array![];
    let mut tile_index: u8 = 1;
    loop {
        if tile_index.into() > context.config.tile_number() || tiles.len() == 2 {
            break;
        };
        let tile: Tile = store.tile(game, tile_index);
        if tile.owner == PLAYER_INDEX.into() {
            tiles.append(tile);
        }
        tile_index += 1;
    };

    // [Transfer]
    let from = tiles.pop_front().unwrap();
    let to = tiles.pop_front().unwrap();
    let army = from.army - 1;
    systems.play.transfer(game_id, from.id, to.id, army);

    // [Assert] Source army
    let tile: Tile = store.tile(game, from.id);
    assert(tile.army == 1, 'Tile: wrong from army');

    // [Assert] Target army
    let tile: Tile = store.tile(game, to.id);
    assert(tile.army == to.army + army, 'Tile: wrong to army');
}


#[test]
#[available_gas(1_000_000_000)]
#[should_panic(expected: ('Transfer: invalid player', 'ENTRYPOINT_FAILED',))]
fn test_transfer_revert_invalid_player() {
    // [Setup]
    let (world, systems, _) = setup::spawn_game();
    let mut store = StoreTrait::new(world);

    // [Create]
    let game_id = systems.host.create(HOST_NAME, PRICE, PENALTY);
    set_contract_address(PLAYER());
    systems.host.join(game_id, PLAYER_NAME);
    set_contract_address(HOST());
    systems.host.start(game_id, ROUND_COUNT);

    // [Compute] Tile army and player available supply
    let game: Game = store.game(game_id);
    let player: Player = store.player(game, PLAYER_INDEX);
    let supply: u32 = player.supply.into();
    let mut tile_index: u8 = 1;
    loop {
        let tile: Tile = store.tile(game, tile_index);
        if tile.owner == PLAYER_INDEX.into() {
            break;
        }
        tile_index += 1;
    };

    // [Supply]
    let contract_address = starknet::contract_address_try_from_felt252(player.address);
    set_contract_address(contract_address.unwrap());
    systems.play.supply(game_id, tile_index, supply);

    // [Finish]
    systems.play.finish(game_id);

    // [Finish]
    systems.play.finish(game_id);

    // [Transfer]
    set_contract_address(starknet::contract_address_const::<1>());
    systems.play.transfer(game_id, 0, 0, 0);
}


#[test]
#[available_gas(1_000_000_000)]
#[should_panic(expected: ('Transfer: invalid owner', 'ENTRYPOINT_FAILED',))]
fn test_transfer_revert_invalid_owner() {
    // [Setup]
    let (world, systems, _) = setup::spawn_game();
    let mut store = StoreTrait::new(world);

    // [Create]
    let game_id = systems.host.create(HOST_NAME, PRICE, PENALTY);
    set_contract_address(PLAYER());
    systems.host.join(game_id, PLAYER_NAME);
    set_contract_address(HOST());
    systems.host.start(game_id, ROUND_COUNT);

    // [Compute] Tile army and player available supply
    let game: Game = store.game(game_id);
    let player: Player = store.player(game, PLAYER_INDEX);
    let supply: u32 = player.supply.into();
    let mut tile_index: u8 = 1;
    loop {
        let tile: Tile = store.tile(game, tile_index);
        if tile.owner == PLAYER_INDEX.into() {
            break;
        }
        tile_index += 1;
    };

    // [Supply]
    let contract_address = starknet::contract_address_try_from_felt252(player.address);
    set_contract_address(contract_address.unwrap());
    systems.play.supply(game_id, tile_index, supply);

    // [Finish]
    systems.play.finish(game_id);

    // [Finish]
    systems.play.finish(game_id);

    // [Compute] Invalid owned tile
    let game: Game = store.game(game_id);
    let mut index = 1;
    loop {
        let tile: Tile = store.tile(game, index);
        if tile.owner != PLAYER_INDEX.into() {
            break;
        }
        index += 1;
    };

    // [Transfer]
    systems.play.transfer(game_id, index, 0, 0);
}
