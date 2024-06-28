// Internal imports

use zkrown::constants::{INFANTRY, CAVALRY, ARTILLERY, JOCKER};
use zkrown::elements::configs::interface::ConfigTrait;

// Constants

const TILE_NUMBER: u32 = 5;
const ARMY_NUMBER: u32 = 5;
const FACTION_01: felt252 = 'RED';
const FACTION_02: felt252 = 'BLUE';

impl Config of ConfigTrait {
    #[inline(always)]
    fn tile_number() -> u32 {
        TILE_NUMBER
    }

    #[inline(always)]
    fn army_number() -> u32 {
        ARMY_NUMBER
    }

    #[inline(always)]
    fn card_number() -> u32 {
        // Tile number + 5% if > 20, otherwise add 1
        if TILE_NUMBER > 20 {
            TILE_NUMBER + 5 * TILE_NUMBER / 100
        } else {
            TILE_NUMBER + 1
        }
    }

    #[inline(always)]
    fn card(id: u8) -> Option<(u8, u16)> {
        // ID cannot be 0
        if id == 0 {
            return Option::None;
        // If extra cards, set special unit type
        } else if TILE_NUMBER < id.into() {
            return Option::Some((id, JOCKER));
        // Otherwise, set unit type based on id
        } else {
            let unit: u16 = if id % 3 == 0 {
                INFANTRY
            } else if id % 3 == 1 {
                CAVALRY
            } else {
                ARTILLERY
            };
            return Option::Some((id, unit));
        }
    }

    #[inline(always)]
    fn faction(id: u8) -> Option<felt252> {
        if id < 4 {
            return Option::Some(FACTION_01);
        } else if TILE_NUMBER >= id.into() {
            return Option::Some(FACTION_02);
        } else {
            return Option::None;
        }
    }

    #[inline(always)]
    fn factions() -> Span<felt252> {
        array![FACTION_01, FACTION_02].span()
    }

    #[inline(always)]
    fn ids(faction: felt252) -> Option<Span<u8>> {
        if faction == FACTION_01 {
            return Option::Some(array![1, 2, 3].span());
        } else if faction == FACTION_02 {
            return Option::Some(array![4, 5].span());
        } else {
            return Option::None;
        }
    }

    #[inline(always)]
    fn score(faction: felt252) -> Option<u32> {
        match Self::ids(faction) {
            Option::Some(_ids) => { Option::Some((_ids.len() - 1) / 2) },
            Option::None => { Option::None },
        }
    }

    #[inline(always)]
    fn neighbors(id: u8) -> Option<Span<u8>> {
        if id == 1 {
            return Option::Some(array![3].span());
        } else if id == 2 {
            return Option::Some(array![3].span());
        } else if id == 3 {
            return Option::Some(array![1, 2, 4, 5].span());
        } else if id == 4 {
            return Option::Some(array![3].span());
        } else if id == 5 {
            return Option::Some(array![3].span());
        } else {
            return Option::None;
        }
    }

    #[inline(always)]
    fn start_supply(player_count: u8) -> u32 {
        let felt: felt252 = player_count.into();
        match felt {
            0 => { ARMY_NUMBER },
            _ => { ARMY_NUMBER },
        }
    }
}
