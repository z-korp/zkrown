mod constants;
mod store;
mod events;

mod elements {
    mod configs {
        mod interface;
        mod test;
        mod complete;
        mod simple;
    }
}

mod helpers {
    mod extension;
}

mod models {
    mod index;
    mod game;
    mod player;
    mod tile;
}

mod types {
    mod config;
    mod hand;
    mod map;
    mod set;
    mod reward;
}

mod components {
    mod emitter;
    mod hostable;
    mod payable;
    mod playable;
}

mod systems {
    mod play;
}

#[cfg(test)]
mod tests {
    mod setup;
    mod host;
    mod supply;
    mod emote;
    mod attack;
    mod transfer;
    mod finish;
    mod surrender;
    mod banish;

    mod mocks {
        mod erc20;
    }
}

