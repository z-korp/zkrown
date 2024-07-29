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
const PRICE: felt252 = 1_000_000_000_000_000_000;
const PENALTY: u64 = 60;
const PLAYER_COUNT: u8 = 2;
const PLAYER_INDEX: u32 = 0;
const EMOTE_INDEX: u8 = 12;
const ROUND_COUNT: u32 = 10;


#[test]
#[available_gas(1_000_000_000)]
fn test_emote_valid_player() {
    // [Setup]
    let (world, systems, _, _, _, _) = setup::spawn_game();
    let mut store = StoreTrait::new(world);

    // [Create]
    let game_id = systems.host.create(HOST_NAME, PRICE, PENALTY);
    set_contract_address(PLAYER());
    systems.host.join(game_id, PLAYER_NAME);
    set_contract_address(HOST());
    systems.host.start(game_id, ROUND_COUNT);

    // [Emote]
    let game: Game = store.game(game_id);
    let current_player: Player = store.current_player(game);

    let contract_address = starknet::contract_address_try_from_felt252(current_player.address);
    set_contract_address(contract_address.unwrap());
    // Execute the emote function
    systems.play.emote(game_id, current_player.index, EMOTE_INDEX);
}

#[test]
#[available_gas(1_000_000_000)]
#[should_panic(expected: ('Emote: invalid player', 'ENTRYPOINT_FAILED',))]
fn test_emote_revert_invalid_player() {
    // [Setup]
    let (world, systems, _, _, _, _) = setup::spawn_game();
    let mut store = StoreTrait::new(world);

    // [Create]
    let game_id = systems.host.create(HOST_NAME, PRICE, PENALTY);
    set_contract_address(PLAYER());
    systems.host.join(game_id, PLAYER_NAME);
    set_contract_address(HOST());
    systems.host.start(game_id, ROUND_COUNT);

    // [Emote]
    let game: Game = store.game(game_id);
    let current_player: Player = store.current_player(game);
    let player: Player = store.next_player(game);

    let contract_address = starknet::contract_address_try_from_felt252(player.address);
    set_contract_address(contract_address.unwrap());
    // Execute the emote function
    systems.play.emote(game_id, current_player.index, EMOTE_INDEX);
}
