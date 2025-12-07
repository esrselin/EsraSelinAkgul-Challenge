module challenge::arena;

use challenge::hero::{Hero, hero_power};
use sui::event;

// ========= STRUCTS =========

public struct Arena has key, store {
    id: UID,
    warrior: Hero,
    owner: address,
}

// ========= EVENTS =========

public struct ArenaCreated has copy, drop {
    arena_id: ID,
    timestamp: u64,
}

public struct ArenaCompleted has copy, drop {
    winner_hero_id: ID,
    loser_hero_id: ID,
    timestamp: u64,
}

// ========= FUNCTIONS =========

public fun create_arena(hero: Hero, ctx: &mut TxContext) {
    let arena = Arena {
        id: object::new(ctx),
        warrior: hero,
        owner: ctx.sender(),
    };
    event::emit(ArenaCreated {
        arena_id: object::id(&arena),
        timestamp: ctx.epoch_timestamp_ms(),
    });
    transfer::share_object(arena);
}

#[allow(lint(self_transfer))]
public fun battle(hero: Hero, arena: Arena, ctx: &mut TxContext) {
    let Arena { id, warrior, owner } = arena;
    let hero_one_id = object::id(&hero);
    let hero_two_id = object::id(&warrior);
    let win_id;
    let lose_id;
    let win_address;

    if (hero_power(&hero) > hero_power(&warrior)) {
        win_id = hero_one_id;
        lose_id = hero_two_id;
        win_address = ctx.sender();
    } else {
        win_id = hero_two_id;
        lose_id = hero_one_id;
        win_address = owner;
    };

    transfer::public_transfer(hero, win_address);
    transfer::public_transfer(warrior, win_address);
    event::emit(ArenaCompleted {
        winner_hero_id: win_id,
        loser_hero_id: lose_id,
        timestamp: ctx.epoch_timestamp_ms(),
    });

    object::delete(id);
}
