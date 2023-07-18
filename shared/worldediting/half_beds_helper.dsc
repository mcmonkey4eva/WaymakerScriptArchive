half_beds_world:
    type: world
    debug: false
    events:
        on player places item_flagged:half_bed priority:100 bukkit_priority:highest:
        - if <player.gamemode> != creative || <context.cancelled>:
            - stop
        - determine passively cancelled
        - define half <context.item_in_hand.flag[half_bed]>
        - define item <context.item_in_hand.material.name>
        - define face <player.location.yaw.simple>
        - wait 1t
        - if <context.location.material.name> != air || !<[item].ends_with[_bed]>:
            - stop
        - flag <context.location> safe_half
        - modifyblock <context.location> <[item]>[half=<[half]>;direction=<[face]>]
        on player breaks block location_flagged:safe_half priority:100 bukkit_priority:monitor:
        - if <player.gamemode> != creative || <context.cancelled>:
            - stop
        - flag <context.location> safe_half:!
        on block physics:
        - if <context.location.find_blocks[*bed].within[2].filter[has_flag[safe_half]].any||false>:
            - determine cancelled

generate_half_beds:
    type: task
    debug: false
    script:
    - foreach <server.material_types.filter[name.ends_with[_bed]].parse[name]> as:bed:
        - flag <player> bed_color_temp:<[bed].before_last[_].replace_text[_].with[ ].to_titlecase>
        - narrate "Giving <player.flag[bed_color_temp]>"
        - run give_safe_item def.item:half_bed_top_item
        - run give_safe_item def.item:half_bed_bottom_item
    - flag <player> bed_color_temp:!

half_bed_top_item:
    type: item
    debug: false
    material: <player.flag[bed_color_temp].replace[ ].with[_]||red>_bed
    display name: <&f><player.flag[bed_color_temp]||Red> Bed Top Half
    lore:
    - <&7>Head side of the bed only.
    flags:
        half_bed: head

half_bed_bottom_item:
    type: item
    debug: false
    material: <player.flag[bed_color_temp].replace[ ].with[_]||red>_bed
    display name: <&f><player.flag[bed_color_temp]||Red> Bed Bottom Half
    lore:
    - <&7>Foot side of the bed only.
    flags:
        half_bed: foot
