// Core imports

use core::zeroable::Zeroable;

// Starknet imports

use starknet::ContractAddress;

// Internal imports

use zkrown::constants;
use zkrown::store::Store;
use zkrown::models::index::Player;

// Errors

mod errors {
    const PLAYER_INVALID_RANK: felt252 = 'Player: invalid rank';
    const PLAYER_NOT_EXISTS: felt252 = 'Player: does not exist';
    const PLAYER_DOES_EXIST: felt252 = 'Player: does exist';
    const PLAYER_IS_DEAD: felt252 = 'Player: is dead';
}

#[generate_trait]
impl PlayerImpl of PlayerTrait {
    #[inline(always)]
    fn new(game_id: u32, index: u32, address: felt252, name: felt252) -> Player {
        Player { game_id, index, address, name, supply: 0, cards: 0, conqueror: false, rank: 0 }
    }

    #[inline(always)]
    fn is_dead(self: Player) -> bool {
        self.rank > 0
    }

    #[inline(always)]
    fn rank(ref self: Player, rank: u8) {
        assert(self.rank == 0, errors::PLAYER_IS_DEAD);
        assert(rank != 0, errors::PLAYER_INVALID_RANK);
        self.rank = rank;
    }

    #[inline(always)]
    fn nullify(ref self: Player) {
        self.address = 0;
        self.name = 0;
        self.supply = 0;
        self.cards = 0;
        self.conqueror = false;
        self.rank = 0;
    }
}

#[generate_trait]
impl PlayerAssert of AssertTrait {
    #[inline(always)]
    fn assert_exists(self: Player) {
        assert(self.is_non_zero(), errors::PLAYER_NOT_EXISTS);
    }

    #[inline(always)]
    fn assert_not_exists(self: Player) {
        assert(self.is_zero(), errors::PLAYER_DOES_EXIST);
    }
}

impl ZeroablePlayer of Zeroable<Player> {
    #[inline(always)]
    fn zero() -> Player {
        Player {
            game_id: 0,
            index: 0,
            address: 0,
            name: 0,
            supply: 0,
            cards: 0,
            conqueror: false,
            rank: 0,
        }
    }

    #[inline(always)]
    fn is_zero(self: Player) -> bool {
        self.address == 0
    }

    #[inline(always)]
    fn is_non_zero(self: Player) -> bool {
        !self.is_zero()
    }
}
