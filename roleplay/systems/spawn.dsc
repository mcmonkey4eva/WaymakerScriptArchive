spawn_world:
    type: world
    debug: false
    events:
        on player respawns:
        - determine passively aurum_spawn_center
        on player joins flagged:!joined_to_spawn_loc:
        - flag player joined_to_spawn_loc
        - teleport <player> aurum_spawn_center
