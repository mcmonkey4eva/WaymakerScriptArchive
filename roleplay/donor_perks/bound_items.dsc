
bound_can_hold_proc:
    type: procedure
    debug: false
    definitions: item|player
    script:
    - if !<[item].has_flag[bound_to]>:
        - determine true
    - if <[player].has_permission[dscript.staff_bound_override]>:
        - determine true
    - if <[item].flag[bound_to].uuid> == <[player].uuid>:
        - determine true
    - determine false

bound_blocker_world:
    type: world
    debug: false
    events:
        on player picks up item_flagged:bound_to:
        - if <context.item.flag[bound_to].uuid> != <player.uuid> && !<player.has_permission[dscript.staff_bound_override]>:
            - determine passively cancelled
            - ratelimit <player> 5s
            - actionbar "<&[error]>That item is bound to <context.item.flag[bound_to].proc[proc_format_name].context[<player>]><&[error]>, cannot pick up."
        on player clicks item_flagged:bound_to in inventory:
        - if <context.clicked_inventory.inventory_type> == player:
            - stop
        - if <context.item.flag[bound_to].uuid> != <player.uuid> && !<player.has_permission[dscript.staff_bound_override]>:
            - determine passively cancelled
            - ratelimit <player> 5s
            - actionbar "<&[error]>That item is bound to <context.item.flag[bound_to].proc[proc_format_name].context[<player>]><&[error]>, cannot pick up."

