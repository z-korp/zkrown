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
const ANYONE_NAME: felt252 = 'ANYONE';
const PRICE: felt252 = 1_000_000_000_000_000_000;
const PENALTY: u64 = 60;
const PLAYER_COUNT: u8 = 2;
const ROUND_COUNT: u32 = 10;

#[test]
#[available_gas(1_000_000_000)]
fn test_host_create_and_join() {
    // [Setup]
    let (world, systems, context, _, _, _) = setup::spawn_game();
    let mut store = StoreTrait::new(world);

    // [Create]
    let game_id = systems.host.create(HOST_NAME, PRICE, PENALTY);
    set_contract_address(PLAYER());
    systems.host.join(game_id, PLAYER_NAME);
    set_contract_address(HOST());
    systems.host.start(game_id, ROUND_COUNT);

    // [Assert] Game
    let game: Game = store.game(game_id);
    assert(game.id == 0, 'Game: wrong id');
    assert(game.seed != 0, 'Game: wrong seed');
    assert(game.over == false, 'Game: wrong status');
    assert(game.player_count == PLAYER_COUNT, 'Game: wrong player count');
    assert(game.player() >= 0, 'Game: wrong player index');
    assert(game.turn().into() == 0_u32, 'Game: wrong player index');

    // [Assert] Players
    let mut player_index: u8 = 0;
    let mut supply = 0;
    loop {
        if player_index == PLAYER_COUNT {
            break;
        }
        let player: Player = store.player(game, player_index.into());
        assert(player.game_id == game.id, 'Player: wrong game id');
        assert(player.index == player_index.into(), 'Player: wrong order');
        assert(
            player.address == HOST().into() || player.address == PLAYER().into(),
            'Player: wrong address'
        );
        assert(player.name == HOST_NAME || player.name == PLAYER_NAME, 'Player: wrong name');
        assert(
            player.supply == 0 || (game.player().into() == player.index && player.supply > 0),
            'Player: wrong supply'
        );
        supply += player.supply;
        player_index += 1;
    };
    assert(supply > 0, 'Player: wrong total supply');

    // [Assert] Tiles
    let mut tile_id: u8 = 1;
    loop {
        if context.config.tile_number() == tile_id.into() {
            break;
        }
        let tile: Tile = store.tile(game, tile_id.into());
        assert(tile.game_id == game.id, 'Tile: wrong game id');
        assert(tile.id == tile_id, 'Tile: wrong tile id');
        assert(tile.army > 0, 'Tile: wrong army');
        assert(tile.owner < PLAYER_COUNT.into(), 'Tile: wrong owner');
        assert(tile.dispatched == 0, 'Tile: wrong dispatched');
        tile_id += 1;
    };
}

#[test]
#[available_gas(1_000_000_000)]
fn test_host_create_and_host_deletes() {
    // [Setup]
    let (world, systems, _, _, _, _) = setup::spawn_game();
    let mut store = StoreTrait::new(world);

    // [Create]
    let game_id = systems.host.create(HOST_NAME, PRICE, PENALTY);
    systems.host.delete(game_id);

    // [Assert] Game
    let game: Game = store.game(game_id);
    assert(game.player_count == 0, 'Game: wrong player count');
}

#[test]
#[available_gas(1_000_000_000)]
fn test_host_create_and_player_leaves() {
    // [Setup]
    let (world, systems, _, _, _, _) = setup::spawn_game();
    let mut store = StoreTrait::new(world);

    // [Create]
    let game_id = systems.host.create(HOST_NAME, PRICE, PENALTY);
    set_contract_address(PLAYER());
    systems.host.join(game_id, PLAYER_NAME);
    systems.host.leave(game_id);

    // [Assert] Game
    let game: Game = store.game(game_id);
    assert(game.player_count == 1, 'Game: wrong player count');
}

#[test]
#[available_gas(1_000_000_000)]
fn test_host_create_and_grant_and_host_leaves() {
    // [Setup]
    let (world, systems, _, _, _, _) = setup::spawn_game();
    let mut store = StoreTrait::new(world);

    // [Create]
    let game_id = systems.host.create(HOST_NAME, PRICE, PENALTY);
    set_contract_address(PLAYER());
    systems.host.join(game_id, PLAYER_NAME);
    set_contract_address(HOST());
    let game = store.game(game_id);
    let player = store.find_player(game, PLAYER()).unwrap();
    systems.host.grant(game_id, player.index);
    systems.host.leave(game_id);

    // [Assert] Game
    let game: Game = store.game(game_id);
    assert(game.player_count == 1, 'Game: wrong player count');
}

#[test]
#[available_gas(1_000_000_000)]
fn test_host_create_and_tranfer_and_kick_host() {
    // [Setup]
    let (world, systems, _, _, _, _) = setup::spawn_game();
    let mut store = StoreTrait::new(world);

    // [Create]
    let game_id = systems.host.create(HOST_NAME, PRICE, PENALTY);
    set_contract_address(PLAYER());
    systems.host.join(game_id, PLAYER_NAME);
    set_contract_address(HOST());
    let game = store.game(game_id);
    let player = store.find_player(game, PLAYER()).unwrap();
    systems.host.grant(game_id, player.index);
    set_contract_address(PLAYER());
    let player = store.find_player(game, HOST()).unwrap();
    systems.host.kick(game_id, player.index);

    // [Assert] Game
    let game: Game = store.game(game_id);
    assert(game.player_count == 1, 'Game: wrong player count');
}

#[test]
#[available_gas(1_000_000_000)]
#[should_panic(expected: ('Game: has started', 'ENTRYPOINT_FAILED',))]
fn test_host_start_then_join_revert_started() {
    // [Setup]
    let (_, systems, _, _, _, _) = setup::spawn_game();

    // [Create]
    let game_id = systems.host.create(HOST_NAME, PRICE, PENALTY);
    set_contract_address(PLAYER());
    systems.host.join(game_id, PLAYER_NAME);
    set_contract_address(HOST());
    systems.host.start(game_id, ROUND_COUNT);

    // [Join]
    set_contract_address(ANYONE());
    systems.host.join(game_id, ANYONE_NAME);
}

#[test]
#[available_gas(1_000_000_000)]
#[should_panic(expected: ('Game: has started', 'ENTRYPOINT_FAILED',))]
fn test_host_start_then_leave_revert_started() {
    // [Setup]
    let (_, systems, _, _, _, _) = setup::spawn_game();

    // [Create]
    let game_id = systems.host.create(HOST_NAME, PRICE, PENALTY);
    set_contract_address(PLAYER());
    systems.host.join(game_id, PLAYER_NAME);
    set_contract_address(HOST());
    systems.host.start(game_id, ROUND_COUNT);

    // [Join]
    set_contract_address(PLAYER());
    systems.host.leave(game_id);
}
