// Core imports

use core::debug::PrintTrait;
use core::poseidon::{PoseidonTrait, HashState};
use core::hash::HashStateTrait;

// Internal imports

use zkrown::elements::configs::complete::{Config as Complete};
use zkrown::elements::configs::simple::{Config as Simple};
use zkrown::elements::configs::test::{Config as Test};

#[derive(Copy, Drop, Serde, Introspect)]
enum Config {
    None,
    Test,
    Complete,
    Simple,
}

#[generate_trait]
impl ConfigImpl of ConfigTrait {
    #[inline(always)]
    fn tile_number(self: Config) -> u32 {
        match self {
            Config::None => 0,
            Config::Test => Test::tile_number(),
            Config::Complete => Complete::tile_number(),
            Config::Simple => Simple::tile_number(),
        }
    }
    #[inline(always)]
    fn army_number(self: Config) -> u32 {
        match self {
            Config::None => 0,
            Config::Test => Test::army_number(),
            Config::Complete => Complete::army_number(),
            Config::Simple => Simple::army_number(),
        }
    }

    #[inline(always)]
    fn card_number(self: Config) -> u32 {
        match self {
            Config::None => 0,
            Config::Test => Test::card_number(),
            Config::Complete => Complete::card_number(),
            Config::Simple => Simple::card_number(),
        }
    }

    #[inline(always)]
    fn card(self: Config, id: u8) -> Option<(u8, u16)> {
        match self {
            Config::None => Option::None,
            Config::Test => Test::card(id),
            Config::Complete => Complete::card(id),
            Config::Simple => Simple::card(id),
        }
    }

    #[inline(always)]
    fn faction(self: Config, id: u8) -> Option<felt252> {
        match self {
            Config::None => Option::None,
            Config::Test => Test::faction(id),
            Config::Complete => Complete::faction(id),
            Config::Simple => Simple::faction(id),
        }
    }

    #[inline(always)]
    fn factions(self: Config) -> Span<felt252> {
        match self {
            Config::None => array![].span(),
            Config::Test => Test::factions(),
            Config::Complete => Complete::factions(),
            Config::Simple => Simple::factions(),
        }
    }

    #[inline(always)]
    fn ids(self: Config, faction: felt252) -> Option<Span<u8>> {
        match self {
            Config::None => Option::None,
            Config::Test => Test::ids(faction),
            Config::Complete => Complete::ids(faction),
            Config::Simple => Simple::ids(faction),
        }
    }

    #[inline(always)]
    fn score(self: Config, faction: felt252) -> Option<u32> {
        match self {
            Config::None => Option::None,
            Config::Test => Test::score(faction),
            Config::Complete => Complete::score(faction),
            Config::Simple => Simple::score(faction),
        }
    }

    #[inline(always)]
    fn neighbors(self: Config, id: u8) -> Option<Span<u8>> {
        match self {
            Config::None => Option::None,
            Config::Test => Test::neighbors(id),
            Config::Complete => Complete::neighbors(id),
            Config::Simple => Simple::neighbors(id),
        }
    }

    #[inline(always)]
    fn start_supply(self: Config, player_count: u8) -> u32 {
        match self {
            Config::None => 0,
            Config::Test => Test::start_supply(player_count),
            Config::Complete => Complete::start_supply(player_count),
            Config::Simple => Simple::start_supply(player_count),
        }
    }
}


impl IntoDeckFelt252 of core::Into<Config, felt252> {
    #[inline(always)]
    fn into(self: Config) -> felt252 {
        match self {
            Config::None => 'NONE',
            Config::Test => 'TEST',
            Config::Complete => 'COMPLETE',
            Config::Simple => 'SIMPLE',
        }
    }
}

impl IntoDeckU8 of core::Into<Config, u8> {
    #[inline(always)]
    fn into(self: Config) -> u8 {
        match self {
            Config::None => 0,
            Config::Test => 1,
            Config::Complete => 2,
            Config::Simple => 2,
        }
    }
}

impl IntoDeck of core::Into<u8, Config> {
    #[inline(always)]
    fn into(self: u8) -> Config {
        let deck: felt252 = self.into();
        match deck {
            0 => Config::None,
            1 => Config::Test,
            2 => Config::Complete,
            3 => Config::Simple,
            _ => Config::None,
        }
    }
}

impl DeckPrint of PrintTrait<Config> {
    #[inline(always)]
    fn print(self: Config) {
        let felt: felt252 = self.into();
        felt.print();
    }
}
