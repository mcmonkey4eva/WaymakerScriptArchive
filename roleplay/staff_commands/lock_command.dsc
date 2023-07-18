lock_command:
    type: command
    name: lock
    debug: false
    usage: /lock
    description: Gives you a locktool.
    permission: dscript.lock
    script:
    - run give_safe_item def.item:lock_tool
    - narrate "<&[base]>Gave a <&[emphasis]><element[Lock Tool].on_hover[<script[lock_tool].parsed_key[lore].separated_by[<n>]>]><&[base]>."

lockall_cmd_core:
    type: task
    debug: false
    script:
    - if <context.args.is_empty>:
        - narrate "<&[error]>/<context.alias> (types)"
        - narrate "<&[warning]>For example: /<context.alias> *_trapdoor"
        - stop
    - if !<player.has_flag[seltool_selection]>:
        - narrate "<&[error]>You do not have a SelTool selection."
        - stop
    - define cuboid <player.flag[seltool_selection]>
    - define approx_scale <[cuboid].max.sub[<[cuboid].min>].vector_length>
    - if <[approx_scale]> > 500:
        - narrate "<&[error]>Your selection is too large."
        - stop
    - define blocks <[cuboid].blocks[<context.args.get[1]>]>
    - wait 1t

lockall_command:
    type: command
    name: lockall
    debug: false
    usage: /lockall (types)
    description: Locks all blocks of the given types in your current CTool selection.
    permission: dscript.lockall
    script:
    - inject lockall_cmd_core
    - define blocks <[blocks].filter[has_flag[locked].not]>
    - wait 1t
    - flag <[blocks]> locked
    - wait 1t
    - flag <player> stats_blocks_locked:+:<[blocks].size>
    - narrate "<&[base]>Locked <&[emphasis]><[blocks].size> <&[base]>blocks."

unlockall_command:
    type: command
    name: unlockall
    debug: false
    usage: /unlockall (types)
    description: Unlocks all blocks of the given types in your current CTool selection.
    permission: dscript.lockall
    script:
    - inject lockall_cmd_core
    - define blocks <[blocks].filter[has_flag[locked]]>
    - wait 1t
    - flag <[blocks]> locked:!
    - wait 1t
    - narrate "<&[base]>Unlocked <&[emphasis]><[blocks].size> <&[base]>blocks."

lock_tool:
    type: item
    material: tripwire_hook
    display name: <&[emphasis]>Lock Tool
    lore:
    - <&[emphasis]>Left click<&[base]> a block to lock it.
    - <&[emphasis]>Right click<&[base]> a block to unlock it.
    enchantments:
    - luck_of_the_sea:1
    mechanisms:
        hides: all

lock_tool_world:
    type: world
    debug: false
    events:
        on player left clicks block with:lock_tool priority:-10:
        - determine passively cancelled
        - if <context.location||null> == null:
            - stop
        - wait 1t
        - if <context.location.has_flag[locked]>:
            - narrate "<&[error]>That block is already locked."
            - stop
        - flag <context.location> locked
        - flag <player> stats_blocks_locked:++
        - narrate "<&[base]>Locked the <&[emphasis]><context.location.material.translated_name><&[base]> at <&[emphasis]><context.location.simple><&[base]>."
        on player right clicks block with:lock_tool priority:-10:
        - determine passively cancelled
        - if <context.location||null> == null:
            - stop
        - wait 1t
        - if !<context.location.has_flag[locked]>:
            - narrate "<&[error]>That block is already unlocked."
            - stop
        - flag <context.location> locked:!
        - narrate "<&[base]>Unlocked the <&[emphasis]><context.location.material.translated_name><&[base]> at <&[emphasis]><context.location.simple><&[base]>."
        on player right clicks block priority:-5 location_flagged:locked:
        - determine passively cancelled
        - wait 1t
        - actionbar "<&[error]>That block is locked."
        on player stands on block priority:-5 location_flagged:locked:
        - determine passively cancelled
        - wait 1t
        - actionbar "<&[error]>This pressure plate is locked."
        on entity interacts with block priority:-5 location_flagged:locked:
        - determine passively cancelled
        on player breaks block priority:-5 location_flagged:locked:
        - determine passively cancelled
        - wait 1t
        - actionbar "<&[error]>That block is locked."
        after player places block priority:100 location_flagged:locked:
        - flag <context.location> locked:!
        - narrate "<&[error]>Glitched lock removed."
        - announce to_console "GLITCHED lock at <context.location.simple> broken by place."
        # Prevent misuse
        on player drops lock_tool:
        - remove <context.entity>
        on player clicks in inventory with:lock_tool:
        - inject <script> path:abuse_prevention_click
        on player drags lock_tool in inventory:
        - inject <script> path:abuse_prevention_click
    abuse_prevention_click:
        - if <context.inventory.inventory_type> == player:
            - stop
        - if <context.inventory.inventory_type> == crafting:
            - if <context.raw_slot||<context.raw_slots.numerical.first>> >= 6:
                - stop
        - determine passively cancelled
        - inventory update

lock_stats_top_command:
    type: command
    debug: false
    name: lockstatstop
    permission: dscript.lockstatstop
    usage: /lockstatstop
    description: Shows lock tool statistics.
    script:
    - narrate "<&[base]>===== Lock Stats Top ====="
    - foreach <server.players_flagged[stats_blocks_locked].sort_by_number[flag[stats_blocks_locked]].reverse.get[1].to[10]> as:player:
        - narrate "<&[base]><[loop_index]>) <proc[proc_format_name].context[<[player]>|<player>]><&[base]>: <&[emphasis]><[player].flag[stats_blocks_locked]>"
