// Core imports

use core::debug::PrintTrait;

// Starknet imports

use starknet::testing::set_contract_address;

// Dojo imports

use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

// Internal imports

use zkrown::store::{Store, StoreTrait};
use zkrown::models::game::{Game, GameTrait};
use zkrown::models::player::Player;
use zkrown::models::tile::Tile;
use zkrown::systems::play::{IHostDispatcherTrait, IPlayDispatcherTrait};
use zkrown::tests::setup::{setup, setup::{Systems, HOST, PLAYER, ANYONE}};

// Constants

const HOST_NAME: felt252 = 'HOST';
const PLAYER_NAME: felt252 = 'PLAYER';
const ANYONE_NAME: felt252 = 'ANYONE';
const PRICE: felt252 = 1_000_000_000_000_000_000;
const PENALTY: u64 = 60;
const PLAYER_COUNT: u8 = 2;
const PLAYER_INDEX: u32 = 0;
const ROUND_COUNT: u32 = 10;

#[test]
#[available_gas(1_000_000_000)]
fn test_surrender_player_quits() {
    // [Setup]
    let (world, systems, _) = setup::spawn_game();
    let mut store = StoreTrait::new(world);

    // [Create]
    let game_id = systems.host.create(HOST_NAME, PRICE, PENALTY);
    set_contract_address(PLAYER());
    systems.host.join(game_id, PLAYER_NAME);
    set_contract_address(HOST());
    systems.host.start(game_id, ROUND_COUNT);

    // [Banish]
    set_contract_address(PLAYER());
    systems.play.surrender(game_id);

    // [Assert] Game
    let game: Game = store.game(game_id);
    assert(game.over, 'Game: wrong over status');
}

#[test]
#[available_gas(1_000_000_000)]
fn test_surrender_host_quits() {
    // [Setup]
    let (world, systems, _) = setup::spawn_game();
    let mut store = StoreTrait::new(world);

    // [Create]
    let game_id = systems.host.create(HOST_NAME, PRICE, PENALTY);
    set_contract_address(PLAYER());
    systems.host.join(game_id, PLAYER_NAME);
    set_contract_address(HOST());
    systems.host.start(game_id, ROUND_COUNT);

    // [Banish]
    set_contract_address(HOST());
    systems.play.surrender(game_id);

    // [Assert] Game
    let game: Game = store.game(game_id);
    assert(game.over, 'Game: wrong over status');
}

#[test]
#[available_gas(1_000_000_000)]
fn test_surrender_3_players_player_quits() {
    // [Setup]
    let (world, systems, _) = setup::spawn_game();
    let mut store = StoreTrait::new(world);

    // [Create]
    let game_id = systems.host.create(HOST_NAME, PRICE, PENALTY);
    set_contract_address(PLAYER());
    systems.host.join(game_id, PLAYER_NAME);
    set_contract_address(ANYONE());
    systems.host.join(game_id, ANYONE_NAME);
    set_contract_address(HOST());
    systems.host.start(game_id, ROUND_COUNT);

    // [Banish]
    set_contract_address(PLAYER());
    systems.play.surrender(game_id);

    // [Assert] Game
    let game: Game = store.game(game_id);
    assert(!game.over, 'Game: wrong over status');
}

#[test]
#[available_gas(1_000_000_000)]
fn test_surrender_3_players_host_quits() {
    // [Setup]
    let (world, systems, _) = setup::spawn_game();
    let mut store = StoreTrait::new(world);

    // [Create]
    let game_id = systems.host.create(HOST_NAME, PRICE, PENALTY);
    set_contract_address(PLAYER());
    systems.host.join(game_id, PLAYER_NAME);
    set_contract_address(ANYONE());
    systems.host.join(game_id, ANYONE_NAME);
    set_contract_address(HOST());
    systems.host.start(game_id, ROUND_COUNT);

    // [Banish]
    set_contract_address(HOST());
    systems.play.surrender(game_id);

    // [Assert] Game
    let game: Game = store.game(game_id);
    assert(!game.over, 'Game: wrong over status');
}

#[test]
#[available_gas(1_000_000_000)]
fn test_surrender_3_players_anyone_quits() {
    // [Setup]
    let (world, systems, _) = setup::spawn_game();
    let mut store = StoreTrait::new(world);

    // [Create]
    let game_id = systems.host.create(HOST_NAME, PRICE, PENALTY);
    set_contract_address(PLAYER());
    systems.host.join(game_id, PLAYER_NAME);
    set_contract_address(ANYONE());
    systems.host.join(game_id, ANYONE_NAME);
    set_contract_address(HOST());
    systems.host.start(game_id, ROUND_COUNT);

    // [Banish]
    set_contract_address(ANYONE());
    systems.play.surrender(game_id);

    // [Assert] Game
    let game: Game = store.game(game_id);
    assert(!game.over, 'Game: wrong over status');
}

#[test]
#[available_gas(1_000_000_000)]
#[should_panic(expected: ('Game: not started', 'ENTRYPOINT_FAILED',))]
fn test_surrender_revert_game_not_started() {
    // [Setup]
    let (_, systems, _) = setup::spawn_game();

    // [Create]
    let game_id = systems.host.create(HOST_NAME, PRICE, PENALTY);
    set_contract_address(PLAYER());
    systems.host.join(game_id, PLAYER_NAME);

    // [Banish]
    set_contract_address(PLAYER());
    systems.play.surrender(game_id);
}

#[test]
#[available_gas(1_000_000_000)]
#[should_panic(expected: ('Game: is over', 'ENTRYPOINT_FAILED',))]
fn test_banish_revert_game_is_over() {
    // [Setup]
    let (_, systems, _) = setup::spawn_game();

    // [Create]
    let game_id = systems.host.create(HOST_NAME, PRICE, PENALTY);
    set_contract_address(PLAYER());
    systems.host.join(game_id, PLAYER_NAME);
    set_contract_address(HOST());
    systems.host.start(game_id, ROUND_COUNT);

    // [Banish]
    set_contract_address(PLAYER());
    systems.play.surrender(game_id);
    systems.play.surrender(game_id);
}
