banner_carpet_stand:
    type: entity
    entity_type: armor_stand
    debug: false
    mechanisms:
        armor_pose: head|0,<util.pi.div[2]>,<util.pi.div[2]>
        is_small: true
        gravity: false
        visible: false
        marker: true

banner_carpet_command:
    type: command
    debug: false
    name: bannercarpet
    description: Makes a banner carpet.
    usage: /bannercarpet (place|delete)
    permission: dscript.bannercarpet
    tab completions:
        1: place|delete|tool
    script:
    - choose <context.args.first||help>:
        - case place:
            - if !<player.item_in_hand.material.name.ends_with[_banner]>:
                - narrate "<&[error]>You must hold a banner to place it as carpet."
                - stop
            - define location <player.location>
            - define location <[location].with_x[<player.location.x.mul[2].round.div[2]>].with_z[<player.location.z.mul[2].round.div[2]>]>
            - define location <[location].with_y[<player.location.y>].below[0.5].with_pitch[0].with_yaw[<player.location.yaw.add[90].div[90].round.mul[90]>]>
            - if <[location].x.mul[2].round.mod[2].abs> == 1:
                - define location <[location].above[0.025]>
            - if <[location].z.mul[2].round.mod[2].abs> == 1:
                - define location <[location].above[0.0125]>
            - spawn banner_carpet_stand <[location]> save:stand
            - equip <entry[stand].spawned_entity> head:<player.item_in_hand>
            - narrate "<&[base]>Placed banner-carpet."
        - case tool:
            - if !<player.item_in_hand.material.name.ends_with[_banner]>:
                - narrate "<&[error]>You must hold a banner to place it as carpet."
                - stop
            - run give_safe_item def.item:<player.item_in_hand.with[display=<&b>Banner Carpet Tool].with_flag[banner_tool]>
            - narrate "<&[base]>Here's ya banner carpet tool."
        - case delete:
            - define stand <player.location.find_entities[armor_stand].within[5].first||null>
            - if <[stand]> == null:
                - narrate "<&[error]>No banner-carpet to delete."
                - stop
            - remove <[stand]>
            - narrate "<&[base]>Banner-carpet deleted."
        - default:
            - narrate "<&[error]>/bannercarpet tool"
            - narrate "<&[error]>/bannercarpet place"
            - narrate "<&[error]>/bannercarpet delete"

banner_diagonal_stand:
    type: entity
    entity_type: armor_stand
    debug: false
    mechanisms:
        armor_pose: head|<util.pi.div[4]>,0,0
        is_small: true
        gravity: false
        visible: false
        marker: true

banner_diagonal_world:
    type: world
    debug: false
    events:
        on player breaks block with:item_flagged:banner_tool priority:10:
        - determine passively cancelled
        - wait 1t
        - define stand <context.location.find_entities[banner_carpet_stand].within[2].first||null>
        - if <[stand]> == null:
            - stop
        - remove <[stand]>
        on player places item_flagged:banner_tool priority:10:
        - determine passively cancelled
        - wait 1t
        - if !<player.item_in_hand.material.name.ends_with[_banner]>:
            - stop
        - define location <player.eye_location.ray_trace||null>
        - if <[location]> == null:
            - stop
        - define banner <player.item_in_hand>
        - if <player.gamemode> != creative:
            - take iteminhand
        - define location <[location].with_x[<[location].x.mul[2].round.div[2]>].with_z[<[location].z.mul[2].round.div[2]>]>
        - define location <[location].with_y[<[location].y.sub[0.5]>].with_pitch[0].with_yaw[<player.location.yaw.add[90].div[90].round.mul[90]>]>
        - if <[location].x.mul[2].round.mod[2].abs> == 1:
            - define location <[location].above[0.025]>
        - if <[location].z.mul[2].round.mod[2].abs> == 1:
            - define location <[location].above[0.0125]>
        - if <[location].find_entities[banner_carpet_stand].within[0.1].filter[location.yaw.is[==].to[<[location].yaw>]].is_empty>:
            - spawn banner_carpet_stand <[location]> save:stand
            - equip <entry[stand].spawned_entity> head:<player.item_in_hand>
        on player places item_flagged:diagonal_banner priority:10:
        - determine passively cancelled
        - wait 1t
        - if !<player.item_in_hand.material.name.ends_with[_banner]>:
            - stop
        - define normal <player.eye_location.ray_trace[return=normal]||null>
        - if <[normal]> == null:
            - stop
        - define banner <player.item_in_hand>
        - if <player.gamemode> != creative:
            - take iteminhand
        - define yaw <location[0,0,0].direction[<[normal]>].yaw>
        - spawn banner_diagonal_stand <context.location.below[1].center.sub[<[normal].div[2]>].with_yaw[<[yaw]>]> save:stand
        - equip <entry[stand].spawned_entity> head:<player.item_in_hand>
