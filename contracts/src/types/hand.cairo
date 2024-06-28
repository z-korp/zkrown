//! Hand struct and card management.

// Core imports

use core::dict::{Felt252Dict, Felt252DictTrait};
use core::hash::HashStateTrait;
use core::nullable::{NullableTrait, nullable_from_box, match_nullable, FromNullableResult};
use core::poseidon::PoseidonTrait;
use core::traits::{Into, Drop};

// Internal imports

use zkrown::helpers::extension::{SpanTraitExt, ArrayTraitExt};
use zkrown::constants::HAND_MAX_SIZE;
use zkrown::models::player::Player;
use zkrown::types::set::{Set, SetTrait};
use zkrown::types::config::Config;

// Constants

const TWO_POW_8: u128 = 0x100;
const MASK_8: u128 = 0xff;

/// Hand struct.
#[derive(Drop)]
struct Hand {
    cards: Array<u8>,
}

/// Errors module.
mod errors {
    const INVALID_SET: felt252 = 'Hand: invalid set';
    const MAX_HAND_SIZE_REACHED: felt252 = 'Hand: max hand size reached';
}

/// Implementation of the `HandTrait` trait for the `Hand` struct.
#[generate_trait]
impl HandImpl of HandTrait {
    /// Returns a new `Hand` struct.
    /// # Returns
    /// * The initialized `Hand`.
    #[inline(always)]
    fn new() -> Hand {
        Hand { cards: array![] }
    }

    /// Load a `Hand` struct from a player component.
    /// # Arguments
    /// * `player` - Player component.
    /// # Returns
    /// * The loaded `Hand`.
    #[inline(always)]
    fn load(player: @Player) -> Hand {
        let cards: Array<u8> = _unpack(*player.cards);
        Hand { cards }
    }

    /// Dump a `Hand` cards into a u128.
    /// # Arguments
    /// * `self` - The Hand.
    /// # Returns
    /// * The packed cards.
    #[inline(always)]
    fn dump(self: @Hand) -> u128 {
        _pack(self.cards.span())
    }

    /// Check if the cards are owned.
    /// # Arguments
    /// * `self` - The Hand.
    /// * `set` - The Set to check.
    /// # Returns
    /// * The owned status.
    fn check(self: @Hand, set: @Set) -> bool {
        let mut cards = set.cards();
        loop {
            match cards.pop_front() {
                Option::Some(item) => { if !self.cards.contains(*item) {
                    break false;
                } },
                Option::None => { break true; },
            };
        }
    }

    /// Add a card to the Hand.
    /// # Arguments
    /// * `self` - The Hand.
    /// * `card` - The card to add.
    #[inline(always)]
    fn add(ref self: Hand, card: u8) {
        // [Check] Maximum
        assert(self.cards.len() < HAND_MAX_SIZE.into(), errors::MAX_HAND_SIZE_REACHED);
        self.cards.append(card);
    }

    /// Deploy a set of 3 cards.
    /// # Arguments
    /// * `self` - The Hand.
    /// * `set` - The Set to check.
    /// # Returns
    /// * The corresponding score.
    fn deploy(ref self: Hand, set: @Set, config: Config) -> u8 {
        // [Check] The set provides a valid score.
        let score = set.score(config);
        assert(score > 0, errors::INVALID_SET);
        // [Check] Cards are owned.
        assert(self.check(set), errors::INVALID_SET);
        // [Effect] Remove discards from hand.
        let discards = set.cards();
        let mut remaining_cards: Array<u8> = ArrayTrait::new();
        loop {
            match self.cards.pop_front() {
                Option::Some(item) => {
                    if !discards.contains(item) {
                        remaining_cards.append(item);
                    };
                },
                Option::None => { break; },
            };
        };
        self.cards = remaining_cards;
        score
    }

    /// Merge a hand.
    /// # Arguments
    /// * `self` - The Hand.
    /// * `hand` - The hand to merge.
    fn merge(ref self: Hand, hand: @Hand) {
        let mut cards = hand.cards.span();
        loop {
            match cards.pop_front() {
                Option::Some(card) => { self.cards.append(*card); },
                Option::None => { break; },
            };
        };
    }
}

/// Pack u8 items in a u128.
/// # Arguments
/// * `unpacked` - The unpacked items.
/// # Returns
/// * The packed items.
fn _pack(mut unpacked: Span<u8>) -> u128 {
    let len = unpacked.len();
    let mut packed: u128 = 0;
    let mut index = len;
    loop {
        if index == 0 {
            break;
        }
        index -= 1;
        let item = unpacked.at(index);
        packed = (packed * TWO_POW_8) + (*item).into();
    };
    (packed * TWO_POW_8) + len.into()
}

/// Unpack u8 items packed in a u128.
/// # Arguments
/// * `packed` - The packed items.
/// # Returns
/// * The unpacked items.
fn _unpack(mut packed: u128) -> Array<u8> {
    let mut unpacked: Array<u8> = ArrayTrait::new();
    let mut len = packed & MASK_8;
    loop {
        if len == 0 {
            break;
        }
        packed /= TWO_POW_8;
        let item = packed & MASK_8;
        unpacked.append(item.try_into().unwrap());
        len -= 1;
    };
    unpacked
}

#[cfg(test)]
mod tests {
    // Core imports

    use core::debug::PrintTrait;

    // Internal imports

    use zkrown::models::player::{Player, ZeroablePlayer};
    use zkrown::types::set::{Set, SetTrait};
    use zkrown::types::config::{Config, ConfigTrait};

    // Local imports

    use super::{HandTrait, _pack, _unpack};

    // Constants

    const CONFIG: Config = Config::Test;

    #[test]
    #[available_gas(1_000_000)]
    fn test_hand_pack_unpack() {
        let unpacked: Span<u8> = array![0, 7, 4, 1, 2, 5, 8, 9, 6, 3].span();
        let packed = _pack(unpacked);
        assert(_unpack(packed).span() == unpacked, 'Hand: wrong pack/unpack');
    }

    #[test]
    #[available_gas(1_000_000)]
    fn test_hand_unpack_pack() {
        let packed: u128 = 0x0a09080605040302010b;
        let unpacked = _unpack(packed);
        assert(_pack(unpacked.span()) == packed, 'Hand: wrong unpack/pack');
    }

    #[test]
    #[available_gas(1_000_000)]
    fn test_hand_new() {
        let hand = HandTrait::new();
        assert(hand.cards == array![], 'Hand: wrong initialization');
    }

    #[test]
    #[available_gas(1_000_000)]
    fn test_hand_load() {
        let mut player: Player = core::Zeroable::zero();
        player.cards = 0x0a09080605040302010b;
        let hand = HandTrait::load(@player);
        assert(hand.cards == _unpack(0x0a09080605040302010b), 'Hand: wrong load');
    }

    #[test]
    #[available_gas(1_000_000)]
    fn test_hand_dump() {
        let mut player: Player = core::Zeroable::zero();
        player.cards = 0x0a09080605040302010b;
        let hand = HandTrait::load(@player);
        let cards = hand.dump();
        assert(cards == player.cards, 'Hand: wrong dump');
    }

    #[test]
    #[available_gas(1_000_000)]
    fn test_hand_add() {
        let mut hand = HandTrait::new();
        hand.add(1);
        hand.add(2);
        let cards = hand.dump();
        assert(cards == 0x020102, 'Hand: wrong add');
    }

    #[test]
    #[available_gas(1_000_000)]
    #[should_panic(expected: ('Hand: max hand size reached',))]
    fn test_hand_add_invalid_size() {
        let mut hand = HandTrait::new();
        hand.add(1);
        hand.add(2);
        hand.add(3);
        hand.add(4);
        hand.add(5);
        hand.add(6);
    }

    #[test]
    #[available_gas(1_000_000)]
    fn test_hand_check() {
        let mut player: Player = core::Zeroable::zero();
        player.cards = 0x01020303;
        let hand = HandTrait::load(@player);
        let set = SetTrait::new(1, 2, 3);
        assert(hand.check(@set), 'Hand: wrong check');
    }

    #[test]
    #[available_gas(1_000_000)]
    fn test_hand_uncheck() {
        let mut player: Player = core::Zeroable::zero();
        player.cards = 0x10202;
        let hand = HandTrait::load(@player);
        let set = SetTrait::new(1, 2, 3);
        assert(!hand.check(@set), 'Hand: wrong uncheck');
    }

    #[test]
    #[available_gas(1_000_000)]
    #[should_panic(expected: ('Hand: invalid set',))]
    fn test_hand_deploy_invalid_set_not_owned() {
        let mut player: Player = core::Zeroable::zero();
        player.cards = 0x10202;
        let mut hand = HandTrait::load(@player);
        let set = SetTrait::new(1, 2, 3);
        hand.deploy(@set, CONFIG);
    }

    #[test]
    #[available_gas(1_000_000)]
    #[should_panic(expected: ('Hand: invalid set',))]
    fn test_hand_deploy_invalid_set_not_scored() {
        let mut player: Player = core::Zeroable::zero();
        player.cards = 0x1020203;
        let mut hand = HandTrait::load(@player);
        let set = SetTrait::new(1, 2, 2);
        hand.deploy(@set, CONFIG);
    }

    #[test]
    #[available_gas(1_000_000)]
    fn test_hand_deploy() {
        let mut player: Player = core::Zeroable::zero();
        player.cards = 0x1020303;
        let mut hand = HandTrait::load(@player);
        let set = SetTrait::new(1, 2, 3);
        let score = hand.deploy(@set, CONFIG);
        assert(score > 0, 'Hand: wrong score');
    }

    #[test]
    #[available_gas(1_000_000)]
    fn test_hand_merge() {
        let mut player: Player = core::Zeroable::zero();
        player.cards = 0x1020303;
        let mut main = HandTrait::load(@player);
        let mut player: Player = core::Zeroable::zero();
        player.cards = 0x4050603;
        let mut hand = HandTrait::load(@player);
        main.merge(@hand);
        assert(main.cards == array![3, 2, 1, 6, 5, 4], 'Hand: wrong merge');
    }
}
