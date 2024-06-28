#[derive(Drop, Serde, starknet::Event)]
struct Emote {
    #[key]
    game_id: u32,
    player_index: u32,
    emote_index: u8
}

#[derive(Drop, Serde, starknet::Event)]
struct Supply {
    #[key]
    game_id: u32,
    #[key]
    player_index: u32,
    troops: u32,
    region: u8,
}

#[derive(Drop, Serde, starknet::Event)]
struct Defend {
    #[key]
    game_id: u32,
    #[key]
    attacker_index: u32,
    #[key]
    defender_index: u32,
    target_tile: u8,
    result: bool,
}

#[derive(Drop, Serde, starknet::Event)]
struct Fortify {
    #[key]
    game_id: u32,
    #[key]
    player_index: u32,
    from_tile: u8,
    to_tile: u8,
    troops: u32,
}

#[derive(Drop, Serde, starknet::Event)]
struct Battle {
    #[key]
    game_id: u32,
    #[key]
    tx_hash: felt252,
    battle_id: u32,
    duel_id: u32,
    attacker_index: u32,
    defender_index: u32,
    attacker_troops: u32,
    defender_troops: u32,
    attacker_value: u8,
    defender_value: u8,
}
