ladders_and_doors_world:
    type: world
    debug: false
    events:
        on player breaks *_door:
        - flag <player> door_clicked expire:1t
        on player right clicks block type:*_door|lever|*_button:
        - flag <player> door_clicked expire:1t
        on block physics adjacent:*_door:
        - if <context.location.find_players_within[10].filter[has_flag[door_clicked]].is_empty>:
            - determine cancelled
        on block physics adjacent:ladder:
        - determine cancelled
