keep_hunger_world:
    type: world
    debug: false
    events:
        on player death:
        - flag player death_food:<player.food_level>
        after player respawns flagged:death_food:
        - adjust <player> food_level:<player.flag[death_food]>
        - adjust <player> saturation:0
        - flag player death_food:!
