// Core imports

use core::debug::PrintTrait;

// Starknet imports

use starknet::testing::{set_contract_address, set_block_timestamp};

// Dojo imports

use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

// Internal imports

use zkrown::store::{Store, StoreTrait};
use zkrown::models::game::{Game, GameTrait, Turn};
use zkrown::models::player::Player;
use zkrown::models::tile::Tile;
use zkrown::systems::play::{IHostDispatcherTrait, IPlayDispatcherTrait};
use zkrown::tests::setup::{setup, setup::{Systems, HOST, PLAYER, ANYONE}};

// Constants

const HOST_NAME: felt252 = 'HOST';
const PLAYER_NAME: felt252 = 'PLAYER';
const PRICE: felt252 = 1_000_000_000_000_000_000;
const PENALTY: u64 = 60;
const PLAYER_COUNT: u8 = 2;
const PLAYER_INDEX: u32 = 0;
const ROUND_COUNT: u32 = 10;

#[test]
#[available_gas(1_000_000_000)]
fn test_finish_next_player() {
    // [Setup]
    let (world, systems, _) = setup::spawn_game();
    let mut store = StoreTrait::new(world);

    // [Create]
    let game_id = systems.host.create(HOST_NAME, PRICE, PENALTY);
    set_contract_address(PLAYER());
    systems.host.join(game_id, PLAYER_NAME);
    set_contract_address(HOST());
    systems.host.start(game_id, ROUND_COUNT);

    // [Assert] Game
    let game: Game = store.game(game_id);
    assert(game.player() == PLAYER_INDEX, 'Game: wrong player index 0');
    assert(game.turn() == Turn::Supply, 'Game: wrong turn 0');

    // [Compute] Tile army and player available supply
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

    // [Assert] Game
    let game: Game = store.game(game_id);
    assert(game.player() == PLAYER_INDEX, 'Game: wrong player index 1');
    assert(game.turn() == Turn::Attack, 'Game: wrong turn 1');

    // [Finish]
    systems.play.finish(game_id);

    // [Assert] Game
    let game: Game = store.game(game_id);
    assert(game.player() == PLAYER_INDEX, 'Game: wrong player index 2');
    assert(game.turn() == Turn::Transfer, 'Game: wrong turn 2');

    // [Finish]
    systems.play.finish(game_id);

    // [Assert] Game
    let game: Game = store.game(game_id);
    let player_index = 1 - PLAYER_INDEX;
    assert(game.player() == player_index, 'Game: wrong player index 3');
    assert(game.turn() == Turn::Supply, 'Game: wrong turn 3');

    // [Assert] Player
    let player: Player = store.player(game, game.player());
    assert(player.supply > 0, 'Player: wrong supply');
}

#[test]
#[available_gas(1_000_000_000)]
#[should_panic(expected: ('Finish: invalid supply', 'ENTRYPOINT_FAILED',))]
fn test_finish_revert_invalid_supply() {
    // [Setup]
    let (world, systems, _) = setup::spawn_game();
    let mut store = StoreTrait::new(world);

    // [Create]
    let game_id = systems.host.create(HOST_NAME, PRICE, PENALTY);
    set_contract_address(PLAYER());
    systems.host.join(game_id, PLAYER_NAME);
    set_contract_address(HOST());
    systems.host.start(game_id, ROUND_COUNT);

    // [Finish]
    let game: Game = store.game(game_id);
    let player: Player = store.player(game, PLAYER_INDEX);
    let contract_address = starknet::contract_address_try_from_felt252(player.address);
    set_contract_address(contract_address.unwrap());
    systems.play.finish(game_id);
}

#[test]
#[available_gas(1_000_000_000)]
#[should_panic(expected: ('Finish: invalid player', 'ENTRYPOINT_FAILED',))]
fn test_finish_revert_invalid_player() {
    // [Setup]
    let (world, systems, _) = setup::spawn_game();
    let mut store = StoreTrait::new(world);

    // [Create]
    let game_id = systems.host.create(HOST_NAME, PRICE, PENALTY);
    set_contract_address(PLAYER());
    systems.host.join(game_id, PLAYER_NAME);
    set_contract_address(HOST());
    systems.host.start(game_id, ROUND_COUNT);

    // [Assert] Game
    let game: Game = store.game(game_id);
    assert(game.player() == 0, 'Game: wrong player index 0');
    assert(game.turn() == Turn::Supply, 'Game: wrong turn 0');

    // [Finish]
    let player_index = 1 - PLAYER_INDEX;
    let player: Player = store.player(game, player_index);
    let contract_address = starknet::contract_address_try_from_felt252(player.address);
    set_contract_address(contract_address.unwrap());
    systems.play.finish(game_id);
}
