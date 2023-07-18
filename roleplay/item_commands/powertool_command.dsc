powertool_command:
    type: command
    debug: false
    permission: dscript.powertool
    name: powertool
    usage: /powertool [command]
    description: Creates a powertool item that executes commands when clicked.
    script:
    - if <context.args.is_empty>:
        - narrate "<&[error]>/powertool [command]"
        - stop
    - flag player last_powertool:<context.raw_args>
    - define result <item[powertool_item]>
    - run give_safe_item def.item:<[result]>
    - narrate "<&[base]>Here's your <[result].proc[embedder_for_item]>"

powertool_item:
    type: item
    material: end_rod
    display name: <&b><&l>Powertool<&co> <&e><player.flag[last_powertool].before[ ]||?>
    lore:
    - <&7>Click to execute<&co>
    - <&e><player.flag[last_powertool]||Unknown>
    enchantments:
    - VANISHING_CURSE:1
    mechanisms:
        hides: all
    flags:
        powertool_command: <player.flag[last_powertool]||powertool>

powertool_world:
    type: world
    debug: false
    events:
        on player clicks block with:powertool_item permission:dscript.powertool:
        - define cmd <context.item.flag[powertool_command]||powertool>
        - determine passively cancelled
        - wait 1t
        - execute as_player <[cmd]>
