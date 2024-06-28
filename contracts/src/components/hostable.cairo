// Starknet imports

use starknet::ContractAddress;

// Component

#[starknet::component]
mod HostableComponent {
    // Starknet imports

    use starknet::{ContractAddress, contract_address_try_from_felt252};
    use starknet::info::{get_caller_address, get_block_timestamp};

    // Dojo imports

    use dojo::world;
    use dojo::world::IWorldDispatcher;
    use dojo::world::IWorldDispatcherTrait;
    use dojo::world::IWorldProvider;
    use dojo::world::IDojoResourceProvider;

    // External imports

    use origami::random::deck::{Deck, DeckTrait};

    // Internal imports

    use zkrown::constants;
    use zkrown::store::{Store, StoreTrait};
    use zkrown::models::game::{Game, GameTrait, GameAssert};
    use zkrown::models::player::{Player, PlayerTrait, PlayerAssert};
    use zkrown::models::tile::{Tile, TileTrait};
    use zkrown::types::map::{Map, MapTrait};
    use zkrown::types::reward::{Reward, RewardTrait};
    use zkrown::types::config::{Config, ConfigTrait};

    // Errors

    mod errors {
        const HOST_PLAYER_ALREADY_IN_LOBBY: felt252 = 'Host: player already in lobby';
        const HOST_PLAYER_NOT_IN_LOBBY: felt252 = 'Host: player not in lobby';
        const HOST_CALLER_IS_NOT_THE_HOST: felt252 = 'Host: caller is not the host';
        const HOST_MAX_NB_PLAYERS_IS_TOO_LOW: felt252 = 'Host: max player numbers is < 2';
        const HOST_GAME_NOT_OVER: felt252 = 'Host: game not over';
    }

    // Storage

    #[storage]
    struct Storage {}

    // Events

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {}

    #[generate_trait]
    impl InternalImpl<
        TContractState, +HasComponent<TContractState>
    > of InternalTrait<TContractState> {
        fn create(
            self: @ComponentState<TContractState>,
            world: IWorldDispatcher,
            player_name: felt252,
            price: u256,
            penalty: u64,
            config: Config,
        ) -> u32 {
            // [Setup] Datastore
            let mut store: Store = StoreTrait::new(world);

            // [Effect] Game
            let game_id = world.uuid();
            let caller = get_caller_address();
            let mut game = GameTrait::new(game_id, caller.into(), price, penalty, config);
            let player_index: u32 = game.join().into();
            store.set_game(game);

            // [Effect] Player
            let player = PlayerTrait::new(
                game_id, index: player_index, address: caller.into(), name: player_name
            );
            store.set_player(player);

            // [Return] Game id
            game_id
        }

        fn join(
            self: @ComponentState<TContractState>,
            world: IWorldDispatcher,
            game_id: u32,
            player_name: felt252,
        ) -> u256 {
            // [Setup] Datastore
            let mut store: Store = StoreTrait::new(world);

            // [Check] Player not in lobby
            let mut game = store.game(game_id);
            let caller = get_caller_address();
            match store.find_player(game, caller) {
                Option::Some(_) => panic(array![errors::HOST_PLAYER_ALREADY_IN_LOBBY]),
                Option::None => (),
            };

            // [Effect] Game
            let player_index: u32 = game.join().into();
            store.set_game(game);

            // [Effect] Player
            let player = PlayerTrait::new(game_id, player_index, caller.into(), player_name);
            store.set_player(player);

            // [Return] Game price
            game.price
        }

        fn transfer(
            self: @ComponentState<TContractState>, world: IWorldDispatcher, game_id: u32, index: u32
        ) {
            // [Setup] Datastore
            let mut store: Store = StoreTrait::new(world);

            // [Check] Caller is the host
            let mut game = store.game(game_id);
            let caller = get_caller_address();
            game.assert_is_host(caller.into());

            // [Check] Player exists
            let mut player = store.player(game, index);
            player.assert_exists();

            // [Effect] Update Game
            game.transfer(player.address);
            store.set_game(game);
        }

        fn leave(
            self: @ComponentState<TContractState>, world: IWorldDispatcher, game_id: u32,
        ) -> (ContractAddress, u256) {
            // [Setup] Datastore
            let mut store: Store = StoreTrait::new(world);

            // [Check] Player in lobby
            let mut game = store.game(game_id);
            let caller = get_caller_address();
            let mut player = match store.find_player(game, caller) {
                Option::Some(player) => player,
                Option::None => panic(array![errors::HOST_PLAYER_NOT_IN_LOBBY]),
            };

            // [Effect] Update Game
            let last_index = game.leave(caller.into());
            store.set_game(game);

            // [Effect] Update Player
            let mut last_player = store.player(game, last_index);
            if last_player.index != player.index {
                last_player.index = player.index;
                store.set_player(last_player);
            }

            // [Compute] Recipient
            let recipient = starknet::contract_address_try_from_felt252(player.address).unwrap();

            // [Effect] Update Player
            player.nullify();
            store.set_player(player);

            // [Return] Game price
            (recipient, game.price)
        }

        fn kick(
            self: @ComponentState<TContractState>, world: IWorldDispatcher, game_id: u32, index: u32
        ) -> (ContractAddress, u256) {
            // [Setup] Datastore
            let mut store: Store = StoreTrait::new(world);

            // [Check] Caller is the host
            let mut game = store.game(game_id);
            let caller = get_caller_address();
            game.assert_is_host(caller.into());

            // [Check] Player exists
            let mut player = store.player(game, index);
            player.assert_exists();

            // [Effect] Update Game
            let last_index = game.kick(player.address);
            store.set_game(game);

            // [Effect] Update last Player
            let mut last_player = store.player(game, last_index);
            if last_player.index != player.index {
                last_player.index = player.index;
                store.set_player(last_player);
            }

            // [Compute] Recipient
            let recipient = starknet::contract_address_try_from_felt252(player.address).unwrap();

            // [Effect] Update Player
            player.nullify();
            store.set_player(player);

            // [Return] Game price
            (recipient, game.price)
        }

        fn delete(
            self: @ComponentState<TContractState>, world: IWorldDispatcher, game_id: u32
        ) -> u256 {
            // [Setup] Datastore
            let mut store: Store = StoreTrait::new(world);

            // [Check] Player exists
            let mut game = store.game(game_id);
            let caller = get_caller_address();
            let mut player = match store.find_player(game, caller) {
                Option::Some(player) => player,
                Option::None => panic(array![errors::HOST_PLAYER_NOT_IN_LOBBY]),
            };
            player.assert_exists();

            // [Effect] Update Game
            let price = game.price;
            game.delete(player.address);
            store.set_game(game);

            // [Effect] Update Player
            player.nullify();
            store.set_player(player);

            // [Return] Game price
            price
        }

        fn start(
            self: @ComponentState<TContractState>,
            world: IWorldDispatcher,
            game_id: u32,
            round_count: u32
        ) {
            // [Setup] Datastore
            let mut store: Store = StoreTrait::new(world);

            // [Check] Caller is the host
            let mut game = store.game(game_id);
            let caller = get_caller_address();
            game.assert_is_host(caller.into());

            // [Effect] Start game
            let mut addresses = array![];
            let mut players = store.players(game);
            loop {
                match players.pop_front() {
                    Option::Some(player) => { addresses.append(player.address); },
                    Option::None => { break; },
                };
            };

            // [Effect] Update Game
            let time = get_block_timestamp();
            game.start(time, round_count, addresses);
            store.set_game(game);

            // [Effect] Update Tiles
            let config: Config = game.config.into();
            let army_count = config.start_supply(game.player_count);
            let mut map: Map = MapTrait::new(
                game.id, game.seed, game.player_count.into(), army_count, config,
            );
            let mut player_index = 0;
            loop {
                if player_index == game.player_count {
                    break;
                }
                let mut player_tiles = map.player_tiles(player_index.into());
                loop {
                    match player_tiles.pop_front() {
                        Option::Some(tile) => { store.set_tile(*tile); },
                        Option::None => { break; },
                    };
                };
                player_index += 1;
            };

            // [Effect] Update Players
            // Use the deck mechanism to define the player order
            // First player got his supply set
            let mut deck = DeckTrait::new(game.seed, game.player_count.into());
            let mut player_index = 0;
            let mut ordered_players: Array<Player> = array![];
            loop {
                if deck.remaining == 0 {
                    break;
                };
                let index = deck.draw() - 1;
                let mut player = store.player(game, index.into());
                player.index = player_index;
                if player_index == 0 {
                    let player_score = map.player_score(player_index.into());
                    player.supply = if player_score < 12 {
                        3
                    } else {
                        player_score / 3
                    };
                    player.supply += map.faction_score(player_index.into(), config);
                };
                ordered_players.append(player);
                player_index += 1;
            };
            // Store ordered players
            loop {
                match ordered_players.pop_front() {
                    Option::Some(player) => { store.set_player(player); },
                    Option::None => { break; },
                };
            };
        }

        fn claim(
            self: @ComponentState<TContractState>, world: IWorldDispatcher, game_id: u32,
        ) -> Span<Reward> {
            // [Setup] Datastore
            let mut store: Store = StoreTrait::new(world);

            // [Return] Reward
            let game = store.game(game_id);
            let amount = game.reward();

            // [Setup] Top players
            let first = store.find_ranked_player(game, 1);
            let first_address: ContractAddress = match first {
                Option::Some(player) => {
                    contract_address_try_from_felt252(player.address).unwrap()
                },
                Option::None => { constants::ZERO() },
            };

            let second = store.find_ranked_player(game, 2);
            let second_address: ContractAddress = match second {
                Option::Some(player) => {
                    contract_address_try_from_felt252(player.address).unwrap()
                },
                Option::None => { constants::ZERO() },
            };

            let third = store.find_ranked_player(game, 3);
            let third_address: ContractAddress = match third {
                Option::Some(player) => {
                    contract_address_try_from_felt252(player.address).unwrap()
                },
                Option::None => { constants::ZERO() },
            };

            // [Return] Transfers
            RewardTrait::rewards(
                game.player_count, amount, first_address, second_address, third_address
            )
        }
    }
}
