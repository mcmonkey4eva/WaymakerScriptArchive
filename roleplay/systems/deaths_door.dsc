deaths_door_world:
    type: world
    debug: false
    events:
        on player death:
        - if <context.damager||null> == null:
            - announce to_console "<player.name> dies by their own fault"
            - flag player deaths_door duration:12h
        after player respawns flagged:deaths_door:
        - flag player deaths_door:!
        - if <player.has_flag[deaths_door_effect]>:
            - narrate "<&7><&o>You once again cross through death's door..."
        - flag player deaths_door_effect:++ duration:10m
        - cast slow duration:2m amplifier:<player.flag[deaths_door_effect].sub[1]>
        - cast unluck duration:3m amplifier:<player.flag[deaths_door_effect].sub[1]>
        - cast slow_digging duration:2.5m amplifier:<player.flag[deaths_door_effect].sub[1]>
