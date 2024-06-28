trait ConfigTrait {
    /// Return the tile number
    fn tile_number() -> u32;
    /// Return the army number
    fn army_number() -> u32;
    /// Return the card number based on tile number.
    fn card_number() -> u32;
    /// Return the tile id and unit type based on the card id.
    /// # Arguments
    /// * `id` - The card id.
    /// # Returns
    /// * The corresponding tile id and unit type.
    fn card(id: u8) -> Option<(u8, u16)>;
    /// Return tile faction based on id.
    /// # Arguments
    /// * `id` - The tile id.
    /// # Returns
    /// * The corresponding faction.
    fn faction(id: u8) -> Option<felt252>;
    /// Return the factions as an iterable.
    /// # Returns
    /// * The factions.
    fn factions() -> Span<felt252>;
    /// Return ids per faction.
    /// # Arguments
    /// * `faction` - The faction id.
    /// # Returns
    /// * The corresponding ids.
    fn ids(faction: felt252) -> Option<Span<u8>>;
    /// Return score per faction.
    /// # Arguments
    /// * `faction` - The faction id.
    /// # Returns
    /// * The corresponding score.
    fn score(faction: felt252) -> Option<u32>;
    /// Return tile neighbors based on id.
    /// # Arguments
    /// * `id` - The tile id.
    /// # Returns
    /// * The corresponding neighbors.
    fn neighbors(id: u8) -> Option<Span<u8>>;
    /// Return the start army supply.
    /// # Arguments
    /// * `player_count` - The fcount of player.
    /// # Returns
    /// * The start army supply.
    fn start_supply(player_count: u8) -> u32;
}
