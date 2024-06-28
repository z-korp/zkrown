// Dojo imports

use dojo::world::IWorldDispatcher;
use dojo::world::IWorldDispatcherTrait;

// Internal imports

use zkrown::events::{Emote, Supply, Defend, Fortify, Battle};

// Interface

#[starknet::interface]
trait EmitterTrait<TContractState> {
    fn emit_emote(self: @TContractState, world: IWorldDispatcher, event: Emote);
    fn emit_supply(self: @TContractState, world: IWorldDispatcher, event: Supply);
    fn emit_defend(self: @TContractState, world: IWorldDispatcher, event: Defend);
    fn emit_fortify(self: @TContractState, world: IWorldDispatcher, event: Fortify);
    fn emit_battle(self: @TContractState, world: IWorldDispatcher, event: Battle);
}

// Component

#[starknet::component]
mod EmitterComponent {
    // Dojo imports

    use dojo::world;
    use dojo::world::IWorldDispatcher;
    use dojo::world::IWorldDispatcherTrait;
    use dojo::world::IWorldProvider;

    // Local imports

    use super::{EmitterTrait, Emote, Supply, Defend, Fortify, Battle};

    // Storage

    #[storage]
    struct Storage {}

    // Events

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        Emote: Emote,
        Supply: Supply,
        Defend: Defend,
        Fortify: Fortify,
        Battle: Battle,
    }

    #[embeddable_as(EmitterImpl)]
    impl Emitter<
        TContractState, +HasComponent<TContractState>
    > of EmitterTrait<ComponentState<TContractState>> {
        #[inline(always)]
        fn emit_emote(
            self: @ComponentState<TContractState>, world: IWorldDispatcher, event: Emote
        ) {
            emit!(world, (Event::Emote(event)));
        }

        #[inline(always)]
        fn emit_supply(
            self: @ComponentState<TContractState>, world: IWorldDispatcher, event: Supply
        ) {
            emit!(world, (Event::Supply(event)));
        }

        #[inline(always)]
        fn emit_defend(
            self: @ComponentState<TContractState>, world: IWorldDispatcher, event: Defend
        ) {
            emit!(world, (Event::Defend(event)));
        }

        #[inline(always)]
        fn emit_fortify(
            self: @ComponentState<TContractState>, world: IWorldDispatcher, event: Fortify
        ) {
            emit!(world, (Event::Fortify(event)));
        }

        #[inline(always)]
        fn emit_battle(
            self: @ComponentState<TContractState>, world: IWorldDispatcher, event: Battle
        ) {
            emit!(world, (Event::Battle(event)));
        }
    }
}
