// Starknet imports

use starknet::ContractAddress;

// Component

#[starknet::component]
mod PlayableComponent {
    // Starknet imports

    use core::traits::Into;
    use starknet::ContractAddress;
    use starknet::info::{get_caller_address, get_block_timestamp, get_tx_info};

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
    use zkrown::events::{Emote, Supply, Defend, Fortify, Battle};
    use zkrown::store::{Store, StoreTrait};
    use zkrown::models::game::{Game, GameTrait, GameAssert, Turn};
    use zkrown::models::player::{Player, PlayerTrait, PlayerAssert};
    use zkrown::models::tile::{Tile, TileTrait};
    use zkrown::types::map::{Map, MapTrait};
    use zkrown::types::reward::{Reward, RewardTrait};
    use zkrown::types::config::{Config, ConfigTrait};
    use zkrown::components::emitter::EmitterTrait;
    use zkrown::types::hand::HandTrait;
    use zkrown::types::set::SetTrait;

    // Errors

    mod errors {
        const ATTACK_INVALID_TURN: felt252 = 'Attack: invalid turn';
        const ATTACK_INVALID_PLAYER: felt252 = 'Attack: invalid player';
        const ATTACK_INVALID_OWNER: felt252 = 'Attack: invalid owner';
        const DEFEND_INVALID_TURN: felt252 = 'Defend: invalid turn';
        const DEFEND_INVALID_PLAYER: felt252 = 'Defend: invalid player';
        const DEFEND_INVALID_OWNER: felt252 = 'Defend: invalid owner';
        const DISCARD_INVALID_TURN: felt252 = 'Discard: invalid turn';
        const DISCARD_INVALID_PLAYER: felt252 = 'Discard: invalid player';
        const FINISH_INVALID_PLAYER: felt252 = 'Finish: invalid player';
        const FINISH_INVALID_SUPPLY: felt252 = 'Finish: invalid supply';
        const SUPPLY_INVALID_TURN: felt252 = 'Supply: invalid turn';
        const SUPPLY_INVALID_PLAYER: felt252 = 'Supply: invalid player';
        const SUPPLY_INVALID_OWNER: felt252 = 'Supply: invalid owner';
        const TRANSFER_INVALID_TURN: felt252 = 'Transfer: invalid turn';
        const TRANSFER_INVALID_PLAYER: felt252 = 'Transfer: invalid player';
        const TRANSFER_INVALID_OWNER: felt252 = 'Transfer: invalid owner';
        const BANISH_NO_PENALTY_SET: felt252 = 'Banish: no penalty set';
        const BANISH_INVALID_PLAYER: felt252 = 'Banish: invalid player';
        const BANISH_INVALID_CONDITION: felt252 = 'Banish: invalid condition';
        const SURRENDER_INVALID_PLAYER: felt252 = 'Surrender: invalid player';
        const EMOTE_INVALID_PLAYER: felt252 = 'Emote: invalid player';
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
        TContractState, +HasComponent<TContractState>, +EmitterTrait<TContractState>
    > of InternalTrait<TContractState> {
        fn emote(
            self: @ComponentState<TContractState>,
            world: IWorldDispatcher,
            game_id: u32,
            player_index: u32,
            emote_index: u8
        ) {
            // Init datastore
            let mut store: Store = StoreTrait::new(world);

            let game: Game = store.game(game_id);

            // [Check] Caller is player
            let caller = get_caller_address();
            let player = store.player(game, player_index);
            assert(player.address == caller.into(), errors::EMOTE_INVALID_PLAYER);

            // [Event] Emote
            let event = Emote {
                game_id: game_id, player_index: player_index, emote_index: emote_index,
            };
            self.get_contract().emit_emote(world, event);
        }

        fn attack(
            self: @ComponentState<TContractState>,
            world: IWorldDispatcher,
            game_id: u32,
            attacker_index: u8,
            defender_index: u8,
            dispatched: u32
        ) {
            // [Setup] Datastore
            let mut store: Store = StoreTrait::new(world);

            // [Check] Turn
            let mut game: Game = store.game(game_id);
            assert(game.turn() == Turn::Attack, errors::ATTACK_INVALID_TURN);

            // [Check] Caller is player
            let caller = get_caller_address();
            let mut player = store.current_player(game);
            assert(player.address == caller.into(), errors::ATTACK_INVALID_PLAYER);

            // [Check] Tiles owner
            let mut attacker = store.tile(game, attacker_index);
            let mut defender = store.tile(game, defender_index);
            assert(attacker.owner == player.index.into(), errors::ATTACK_INVALID_OWNER);

            // [Compute] Attack
            let order = get_tx_info().unbox().transaction_hash;
            attacker.attack(dispatched, ref defender, order, game.config.into());

            // [Effect] Update tiles
            store.set_tiles(array![attacker, defender].span());
        }

        fn defend(
            self: @ComponentState<TContractState>,
            world: IWorldDispatcher,
            game_id: u32,
            attacker_index: u8,
            defender_index: u8
        ) {
            // [Setup] Datastore
            let mut store: Store = StoreTrait::new(world);

            // [Check] Turn
            let mut game: Game = store.game(game_id);
            assert(game.turn() == Turn::Attack, errors::DEFEND_INVALID_TURN);

            // [Check] Caller is player
            let caller = get_caller_address();
            let mut player = store.current_player(game);
            assert(player.address == caller.into(), errors::DEFEND_INVALID_PLAYER);

            // [Check] Tiles owner
            let mut attacker = store.tile(game, attacker_index);
            let attacker_troops = attacker.dispatched;
            let mut defender = store.tile(game, defender_index);
            let defender_troops = defender.army;
            assert(attacker.owner == player.index.into(), errors::DEFEND_INVALID_OWNER);

            // [Compute] Defend
            let defender_player = store.player(game, defender.owner.try_into().unwrap());
            let order = get_tx_info().unbox().transaction_hash;
            let mut battles: Array<Battle> = array![];
            let status = defender
                .defend(ref attacker, game.seed, order, ref battles, game.config.into());
            player.conqueror = player.conqueror || status;

            // [Effect] Update tiles
            store.set_tiles(array![attacker, defender].span());

            // [Effect] Update player
            store.set_player(player);

            // [Event] Defend
            let event = Defend {
                game_id: game_id,
                attacker_index: player.index,
                defender_index: defender_player.index,
                target_tile: defender_index,
                result: status,
            };
            self.get_contract().emit_defend(world, event);

            // [Event] Battles
            loop {
                match battles.pop_front() {
                    Option::Some(battle) => {
                        let mut battle = battle;
                        battle.game_id = game_id;
                        battle.attacker_index = player.index;
                        battle.defender_index = defender_player.index;
                        battle.attacker_troops = attacker_troops;
                        battle.defender_troops = defender_troops;
                        battle.tx_hash = get_tx_info().unbox().transaction_hash;
                        self.get_contract().emit_battle(world, battle);
                    },
                    Option::None => { break; },
                };
            };
        }

        fn discard(
            self: @ComponentState<TContractState>,
            world: IWorldDispatcher,
            game_id: u32,
            card_one: u8,
            card_two: u8,
            card_three: u8
        ) {
            // [Setup] Datastore
            let mut store: Store = StoreTrait::new(world);

            // [Check] Turn
            let mut game: Game = store.game(game_id);
            assert(game.turn() == Turn::Supply, errors::DISCARD_INVALID_TURN);

            // [Check] Caller is player
            let caller = get_caller_address();
            let mut player = store.current_player(game);
            assert(player.address == caller.into(), errors::DISCARD_INVALID_PLAYER);

            // [Compute] Discard
            let tiles = store.tiles(game).span();
            let tiles = self._discard(game, ref player, tiles, card_one, card_two, card_three);

            // [Effect] Update tiles
            store.set_tiles(tiles);

            // [Effect] Update player
            store.set_player(player);
        }

        fn finish(self: @ComponentState<TContractState>, world: IWorldDispatcher, game_id: u32) {
            // [Setup] Datastore
            let mut store: Store = StoreTrait::new(world);

            // [Check] Caller is player or player is dead
            let caller = get_caller_address();
            let mut game: Game = store.game(game_id);
            let mut player = store.current_player(game);
            assert(player.address == caller.into(), errors::FINISH_INVALID_PLAYER);

            // [Check] Player supply is empty
            assert(player.supply == 0, errors::FINISH_INVALID_SUPPLY);

            // [Command] Update game turn and process next player
            game.increment();
            // [Effect] Update next player supply if next turn is supply
            if game.turn() == Turn::Supply {
                // [Compute] Draw card if conqueror
                if player.conqueror {
                    let mut players = store.players(game).span();
                    self._draw(game, ref player, ref players);
                    player.conqueror = false;
                    store.set_player(player);
                };
                self._finish(world, player, ref game, ref store);
            }

            // [Effect] Update game
            store.set_game(game);
        }

        fn supply(
            self: @ComponentState<TContractState>,
            world: IWorldDispatcher,
            game_id: u32,
            tile_index: u8,
            supply: u32
        ) {
            // [Setup] Datastore
            let mut store: Store = StoreTrait::new(world);

            // [Check] Turn
            let mut game: Game = store.game(game_id);
            assert(game.turn() == Turn::Supply, errors::SUPPLY_INVALID_TURN);

            // [Check] Caller is player
            let caller = get_caller_address();
            let mut player = store.current_player(game);
            assert(player.address == caller.into(), errors::SUPPLY_INVALID_PLAYER);

            // [Check] Tile owner
            let mut tile = store.tile(game, tile_index.into());
            assert(tile.owner == player.index.into(), errors::SUPPLY_INVALID_OWNER);

            // [Compute] Supply
            tile.supply(ref player, supply, game.config.into());

            // [Effect] Update tile
            store.set_tile(tile);

            // [Effect] Update player
            store.set_player(player);

            // [Event] Supply
            let event = Supply {
                game_id: game_id, player_index: player.index, troops: supply, region: tile_index,
            };
            self.get_contract().emit_supply(world, event);
        }

        fn transfer(
            self: @ComponentState<TContractState>,
            world: IWorldDispatcher,
            game_id: u32,
            from_index: u8,
            to_index: u8,
            army: u32
        ) {
            // [Setup] Datastore
            let mut store: Store = StoreTrait::new(world);

            // [Check] Turn
            let mut game: Game = store.game(game_id);
            assert(game.turn() == Turn::Transfer, errors::TRANSFER_INVALID_TURN);

            // [Check] Caller is player
            let caller = get_caller_address();
            let mut player = store.current_player(game);
            assert(player.address == caller.into(), errors::TRANSFER_INVALID_PLAYER);

            // [Check] Tiles owner
            let mut from = store.tile(game, from_index);
            let mut to = store.tile(game, to_index);
            assert(from.owner == player.index.into(), errors::TRANSFER_INVALID_OWNER);

            // [Compute] Transfer
            let mut tiles = store.tiles(game);
            from.transfer(ref to, army, ref tiles, game.config.into());

            // [Effect] Update tiles
            store.set_tile(from);
            store.set_tile(to);

            // [Event] Fortify
            let event = Fortify {
                game_id: game_id,
                player_index: player.index,
                from_tile: from_index,
                to_tile: to_index,
                troops: army,
            };
            self.get_contract().emit_fortify(world, event);
        }

        fn surrender(self: @ComponentState<TContractState>, world: IWorldDispatcher, game_id: u32) {
            // [Setup] Datastore
            let mut store: Store = StoreTrait::new(world);

            // [Check] Game has started
            let mut game: Game = store.game(game_id);
            game.assert_has_started();
            game.assert_not_over();

            // [Effect] Update player
            let caller = get_caller_address();
            let mut player = store
                .find_player(game, caller)
                .expect(errors::SURRENDER_INVALID_PLAYER);
            player.rank(store.get_next_rank(game));
            store.set_player(player);

            // [Command] If current player, then update game turn and process next player
            let current_player = store.current_player(game);
            if (current_player.address == player.address) {
                // [Effect] Update game
                game.pass();
                self._finish(world, player, ref game, ref store);
                store.set_game(game);
            } else if (store.get_next_rank(game) == 1) {
                // [Effect] Update game
                self._finish(world, player, ref game, ref store);
                store.set_game(game);
            };
        }

        fn banish(self: @ComponentState<TContractState>, world: IWorldDispatcher, game_id: u32) {
            // [Setup] Datastore
            let mut store: Store = StoreTrait::new(world);

            // [Check] Game has started and not over
            let mut game: Game = store.game(game_id);
            game.assert_has_started();
            game.assert_not_over();

            // [Check] Game penamity is valid
            assert(game.penalty != 0, errors::BANISH_NO_PENALTY_SET);

            // [Check] Player is banishable
            let mut game: Game = store.game(game_id);
            let mut player = store.current_player(game);
            let time = get_block_timestamp();
            assert(time > game.clock + game.penalty, errors::BANISH_INVALID_CONDITION);

            // [Effect] Update player
            player.rank(store.get_next_rank(game));
            store.set_player(player);

            // [Command] Update game turn and process next player
            game.pass();
            self._finish(world, player, ref game, ref store);

            // [Effect] Update game
            store.set_game(game);
        }
    }

    #[generate_trait]
    impl Private<TContractState, +HasComponent<TContractState>> of PrivateTrait<TContractState> {
        fn _draw(
            self: @ComponentState<TContractState>,
            game: Game,
            ref player: Player,
            ref players: Span<Player>,
        ) {
            // [Setup] Deck
            let config: Config = game.config.into();
            let mut deck = DeckTrait::new(game.seed, config.card_number().into());
            let nonce: u32 = (game.nonce) % core::integer::BoundedU32::max();
            deck.nonce = nonce.try_into().unwrap();
            loop {
                match players.pop_front() {
                    Option::Some(player) => {
                        let hand = HandTrait::load(player);
                        deck.remove(hand.cards.span());
                    },
                    Option::None => { break; },
                };
            };

            // [Compute] Set supply
            let mut hand = HandTrait::load(@player);
            hand.add(deck.draw());

            // [Effect] Player
            player.cards = hand.dump();
        }

        fn _discard(
            self: @ComponentState<TContractState>,
            game: Game,
            ref player: Player,
            mut tiles: Span<Tile>,
            card_one: u8,
            card_two: u8,
            card_three: u8
        ) -> Span<Tile> {
            // [Compute] Set supply
            let mut hand = HandTrait::load(@player);
            let set = SetTrait::new(card_one, card_two, card_three);
            let supply = hand.deploy(@set, game.config.into());

            // [Effect] Update player cards and supply
            player.cards = hand.dump();
            player.supply += supply.into();

            // [Compute] Additional supplies for owned tiles
            let player_count = game.player_count;
            let mut map = MapTrait::from_tiles(player_count.into(), tiles);
            let mut player_tiles = map.deploy(player.index, @set, game.config.into());

            // [Return] Player tiles
            let mut tiles: Array<Tile> = array![];
            loop {
                match player_tiles.pop_front() {
                    Option::Some(tile) => { tiles.append(*tile); },
                    Option::None => { break; },
                };
            };
            tiles.span()
        }

        fn _finish(
            self: @ComponentState<TContractState>,
            world: IWorldDispatcher,
            player: Player,
            ref game: Game,
            ref store: Store
        ) {
            // [Compute] Update next player to not dead player
            let tiles = store.tiles(game).span();
            let mut map: Map = MapTrait::from_tiles(game.player_count.into(), tiles);

            // [Check] Game reached the last round
            if game.limit == game.nonce {
                // [Effect] Rank every remaining players
                loop {
                    let last_unranked = store.get_last_unranked_player(game, ref map);
                    match last_unranked {
                        Option::Some(mut player) => {
                            let rank = store.get_next_rank(game);
                            player.rank(rank);
                            store.set_player(player);
                        },
                        Option::None => { break; },
                    };
                };
                return;
            };

            let rank = store.get_next_rank(game);
            loop {
                let mut next_player = store.current_player(game);
                // [Check] Next player is the current player or next rank is 1, means game is over
                if next_player.address == player.address || rank == 1 {
                    // [Effect] Update player
                    next_player.rank(rank);
                    store.set_player(next_player);
                    // [Effect] Update game
                    game.over = true;
                    break;
                };

                // [Check] Player rank is not 0 means the player is dead, move to next player
                if next_player.is_dead() {
                    // [Effect] Move to next player
                    game.pass();
                    continue;
                }

                // [Check] Player score is 0 means the player is dead but not yet ranked, rank then
                // move to next player
                let player_score = map.player_score(next_player.index);
                if 0 == player_score.into() {
                    // [Effect] Update player
                    next_player.rank(rank);
                    store.set_player(next_player);
                    // [Effect] Move to next player
                    game.pass();
                    continue;
                } else {
                    // [Effect] Update next player supply and leave the loop
                    next_player.supply = if player_score < 12 {
                        3
                    } else {
                        player_score / 3
                    };
                    next_player.supply += map.faction_score(next_player.index, game.config.into());
                    store.set_player(next_player);
                    // [Effect] Update game clock
                    game.clock = get_block_timestamp();
                    break;
                };
            };
        }
    }
}
