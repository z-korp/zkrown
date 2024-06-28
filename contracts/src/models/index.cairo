#[derive(Copy, Drop, Serde, IntrospectPacked)]
#[dojo::model]
struct Game {
    #[key]
    id: u32,
    host: felt252,
    over: bool,
    seed: felt252,
    player_count: u8,
    nonce: u32,
    price: u256,
    clock: u64,
    penalty: u64,
    limit: u32,
    config: u8,
}

#[derive(Copy, Drop, Serde, IntrospectPacked)]
#[dojo::model]
struct Player {
    #[key]
    game_id: u32,
    #[key]
    index: u32,
    address: felt252,
    name: felt252,
    supply: u32,
    cards: u128,
    conqueror: bool,
    rank: u8,
}

#[derive(Copy, Drop, Serde, IntrospectPacked)]
#[dojo::model]
struct Tile {
    #[key]
    game_id: u32,
    #[key]
    id: u8,
    army: u32,
    owner: u32,
    dispatched: u32,
    to: u8,
    from: u8,
    order: felt252,
}
