
sit_task:
    type: task
    debug: false
    definitions: location
    script:
    - if <player.is_inside_vehicle||false>:
        - mount cancel <player>
        - wait 1t
    #- narrate "<&[base]>Sorry, sitting is temporarily disabled while we investigate a bug."
    #- stop
    - flag player sitting:<player.location>
    - spawn temporary_chair_stand_entity <[location].with_yaw[<player.location.yaw>]> save:chair
    - mount <player>|<entry[chair].spawned_entity>
    - actionbar "<&[base]>Now sitting."

sit_fix_world:
    type: world
    debug: false
    events:
        after player right clicks block location_flagged:stool priority:-10:
        - if <context.location||null> == null:
            - stop
        - run sit_task def:<context.location.block.add[0.5,0.3,0.5]>
        after player right clicks temporary_chair_stand_entity:
        - if !<context.entity.has_passenger||true>:
            - remove <context.entity>
        on entity damages temporary_chair_stand_entity:
        - determine cancelled
        - wait 1t
        - if !<context.entity.has_passenger||true>:
            - remove <context.entity>
        on player exits temporary_chair_stand_entity:
        - if <context.vehicle.is_spawned>:
            - remove <context.vehicle>
        - wait 1t
        - actionbar "<&[base]>Stood up."
        - if <player.has_flag[sitting]>:
            - if <player.is_online>:
                - teleport <player> <player.flag[sitting]>
            - flag player sitting:!
        after player joins flagged:sitting:
        - remove <player.location.find_entities[temporary_chair_stand_entity].within[5].filter[has_passenger.not]>
        - if !<player.is_inside_vehicle>:
            - teleport <player> <player.flag[sitting]>
            - flag player sitting:!
        - else:
            - wait 1t
            - mount cancel <player>
            - teleport <player> <player.flag[sitting]>
        on player quits flagged:sitting:
        - mount cancel <player>
        - teleport <player> <player.flag[sitting]>
        - flag <player> sitting:!
        after player joins priority:10:
        - if <player.is_inside_vehicle||false>:
            - mount cancel <player>
        # Stool tool
        after player breaks block priority:100 location_flagged:stool:
        - flag <context.location> stool:!
        - narrate "<&[error]>Broke a stool."
        - announce to_console "Stool at <context.location.simple> broken."
        after player places block priority:100 location_flagged:stool:
        - flag <context.location> stool:!
        - narrate "<&[error]>Broke a glitched stool."
        - announce to_console "GLITCHED Stool at <context.location.simple> broken by place."
        on player left clicks block with:stool_tool priority:-10:
        - determine passively cancelled
        - if <context.location||null> == null:
            - stop
        - wait 1t
        - if <context.location.has_flag[stool]>:
            - narrate "<&[error]>That block is already a stool."
            - stop
        - flag <context.location> stool
        - narrate "<&[base]>Enabled stool-sitting for the <&[emphasis]><context.location.material.translated_name><&[base]> at <&[emphasis]><context.location.simple><&[base]>."
        on player right clicks block with:stool_tool priority:-10:
        - determine passively cancelled
        - if <context.location||null> == null:
            - stop
        - wait 1t
        - if !<context.location.has_flag[stool]>:
            - narrate "<&[error]>That block is already not a stool."
            - stop
        - flag <context.location> stool:!
        - narrate "<&[base]>Disabled stool-sitting for the <&[emphasis]><context.location.material.translated_name><&[base]> at <&[emphasis]><context.location.simple><&[base]>."
        # Prevent misuse
        on player drops stool_tool:
        - remove <context.entity>
        on player clicks in inventory with:stool_tool:
        - inject <script> path:abuse_prevention_click
        on player drags stool_tool in inventory:
        - inject <script> path:abuse_prevention_click
    abuse_prevention_click:
        - if <context.inventory.inventory_type> == player:
            - stop
        - if <context.inventory.inventory_type> == crafting:
            - if <context.raw_slot||<context.raw_slots.numerical.first>> >= 6:
                - stop
        - determine passively cancelled
        - inventory update

temporary_chair_stand_entity:
    type: entity
    debug: false
    entity_type: armor_stand
    mechanisms:
        visible: false
        marker: true
        gravity: false
        force_no_persist: true
        max_health: 1

stool_tool:
    type: item
    material: smooth_red_sandstone_stairs
    display name: <&[emphasis]>Stool Tool
    lore:
    - <&[emphasis]>Left click<&[base]> a block to make it a stool.
    - <&[emphasis]>Right click<&[base]> a block to make it not a stool anymore.
    enchantments:
    - luck_of_the_sea:1
    mechanisms:
        hides: all

stooltool_command:
    type: command
    debug: false
    permission: dscript.stooltool
    name: stooltool
    usage: /stooltool
    description: Gives you a stool tool.
    script:
    - run give_safe_item def.item:stool_tool
    - narrate "<&[base]>There's your stool tool, ya fool."
