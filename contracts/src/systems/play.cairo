// Starknet imports

use starknet::ContractAddress;

// Dojo imports

use dojo::world::IWorldDispatcher;

// External imports

use stark_vrf::ecvrf::Proof;

// Interfaces

#[dojo::interface]
trait IHost {
    fn create(
        ref world: IWorldDispatcher, player_name: felt252, price: felt252, penalty: u64
    ) -> u32;
    fn join(ref world: IWorldDispatcher, game_id: u32, player_name: felt252);
    fn leave(ref world: IWorldDispatcher, game_id: u32);
    fn delete(ref world: IWorldDispatcher, game_id: u32);
    fn kick(ref world: IWorldDispatcher, game_id: u32, index: u32);
    fn grant(ref world: IWorldDispatcher, game_id: u32, index: u32);
    fn start(ref world: IWorldDispatcher, game_id: u32, round_count: u32);
    fn claim(ref world: IWorldDispatcher, game_id: u32);
}

#[dojo::interface]
trait IPlay<TContractState> {
    fn emote(ref world: IWorldDispatcher, game_id: u32, player_index: u32, emote_index: u8);
    fn attack(
        ref world: IWorldDispatcher,
        game_id: u32,
        attacker_index: u8,
        defender_index: u8,
        dispatched: u32,
        proof: Proof,
        seed: felt252,
        beta: felt252
    );
    fn discard(
        ref world: IWorldDispatcher, game_id: u32, card_one: u8, card_two: u8, card_three: u8
    );
    fn finish(ref world: IWorldDispatcher, game_id: u32);
    fn supply(ref world: IWorldDispatcher, game_id: u32, tile_index: u8, supply: u32);
    fn transfer(ref world: IWorldDispatcher, game_id: u32, from_index: u8, to_index: u8, army: u32);
    fn surrender(ref world: IWorldDispatcher, game_id: u32);
    fn banish(ref world: IWorldDispatcher, game_id: u32);
}

#[dojo::contract]
mod play {
    // Starknet imports

    use starknet::{ContractAddress, get_caller_address};

    // Component imports

    use zkrown::components::emitter::EmitterComponent;
    use zkrown::components::hostable::HostableComponent;
    use zkrown::components::payable::PayableComponent;
    use zkrown::components::playable::PlayableComponent;

    // External imports

    // Internal imports

    use zkrown::types::config::Config;
    use zkrown::types::reward::Reward;

    // Local imports

    use super::{IHost, IPlay, Proof};

    // Components

    component!(path: EmitterComponent, storage: emitter, event: EmitterEvent);
    impl EmitterImpl = EmitterComponent::EmitterImpl<ContractState>;
    component!(path: HostableComponent, storage: hostable, event: HostableEvent);
    impl HostableInternalImpl = HostableComponent::InternalImpl<ContractState>;
    component!(path: PayableComponent, storage: payable, event: PayableEvent);
    impl PayableInternalImpl = PayableComponent::InternalImpl<ContractState>;
    component!(path: PlayableComponent, storage: playable, event: PlayableEvent);
    impl PlayableInternalImpl = PlayableComponent::InternalImpl<ContractState>;

    // Storage

    #[storage]
    struct Storage {
        #[substorage(v0)]
        emitter: EmitterComponent::Storage,
        #[substorage(v0)]
        hostable: HostableComponent::Storage,
        #[substorage(v0)]
        payable: PayableComponent::Storage,
        #[substorage(v0)]
        playable: PlayableComponent::Storage,
    }

    // Events

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        EmitterEvent: EmitterComponent::Event,
        #[flat]
        HostableEvent: HostableComponent::Event,
        #[flat]
        PayableEvent: PayableComponent::Event,
        #[flat]
        PlayableEvent: PlayableComponent::Event,
    }

    // Constructor

    fn dojo_init(ref world: IWorldDispatcher, token_address: starknet::ContractAddress,) {
        // [Effect] Initialize components
        self.payable.initialize(token_address);
    }

    #[abi(embed_v0)]
    impl Host of IHost<ContractState> {
        fn create(
            ref world: IWorldDispatcher, player_name: felt252, price: felt252, penalty: u64
        ) -> u32 {
            // [Interaction] Pay
            let caller = get_caller_address();
            self.payable.pay(caller, price.into());
            // [Effect] Create game
            self.hostable.create(world, player_name, price.into(), penalty, Config::Test)
        }

        fn join(ref world: IWorldDispatcher, game_id: u32, player_name: felt252) {
            // [Effect] Join game
            let price = self.hostable.join(world, game_id, player_name);
            // [Interaction] Pay
            let caller = get_caller_address();
            self.payable.pay(caller, price);
        }

        fn leave(ref world: IWorldDispatcher, game_id: u32) {
            // [Effect] Leave game
            let (recipient, price) = self.hostable.leave(world, game_id);
            // [Interaction] Refund
            self.payable.refund(recipient, price);
        }

        fn delete(ref world: IWorldDispatcher, game_id: u32) {
            // [Effect] Delete game
            let price = self.hostable.delete(world, game_id);
            // [Interaction] Refund
            let caller = get_caller_address();
            self.payable.refund(caller, price);
        }

        fn kick(ref world: IWorldDispatcher, game_id: u32, index: u32) {
            // [Effect] Kick player
            let (recipient, price) = self.hostable.kick(world, game_id, index);
            // [Interaction] Refund
            self.payable.refund(recipient, price);
        }

        fn grant(ref world: IWorldDispatcher, game_id: u32, index: u32) {
            // [Effect] Transfer host
            self.hostable.transfer(world, game_id, index);
        }

        fn start(ref world: IWorldDispatcher, game_id: u32, round_count: u32) {
            // [Effect] Start game
            self.hostable.start(world, game_id, round_count);
        }

        fn claim(ref world: IWorldDispatcher, game_id: u32) {
            // [Effect] Claim reward
            let mut rewards: Span<Reward> = self.hostable.claim(world, game_id);
            // [Interaction] Pay
            let caller = get_caller_address();
            self.payable.reward(ref rewards);
        }
    }

    #[abi(embed_v0)]
    impl Play of IPlay<ContractState> {
        fn emote(ref world: IWorldDispatcher, game_id: u32, player_index: u32, emote_index: u8) {
            self.playable.emote(world, game_id, player_index, emote_index);
        }

        fn attack(
            ref world: IWorldDispatcher,
            game_id: u32,
            attacker_index: u8,
            defender_index: u8,
            dispatched: u32,
            proof: Proof,
            seed: felt252,
            beta: felt252
        ) {
            self
                .playable
                .attack(
                    world, game_id, attacker_index, defender_index, dispatched, proof, seed, beta
                );
        }

        fn discard(
            ref world: IWorldDispatcher, game_id: u32, card_one: u8, card_two: u8, card_three: u8
        ) {
            self.playable.discard(world, game_id, card_one, card_two, card_three);
        }

        fn finish(ref world: IWorldDispatcher, game_id: u32) {
            self.playable.finish(world, game_id);
        }

        fn supply(ref world: IWorldDispatcher, game_id: u32, tile_index: u8, supply: u32) {
            self.playable.supply(world, game_id, tile_index, supply);
        }

        fn transfer(
            ref world: IWorldDispatcher, game_id: u32, from_index: u8, to_index: u8, army: u32
        ) {
            self.playable.transfer(world, game_id, from_index, to_index, army);
        }

        fn surrender(ref world: IWorldDispatcher, game_id: u32) {
            self.playable.surrender(world, game_id);
        }

        fn banish(ref world: IWorldDispatcher, game_id: u32) {
            self.playable.banish(world, game_id);
        }
    }
}
