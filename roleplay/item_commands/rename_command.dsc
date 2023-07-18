rename_command:
    type: command
    debug: false
    permission: dscript.rename
    name: rename
    usage: /rename [name]
    aliases:
    - itemname
    description: Renames your held item.
    script:
    - if <context.args.is_empty>:
        - narrate "<&[error]>/rename [name]"
        - stop
    - if <player.item_in_hand.material.name> == air:
        - narrate "<&[error]>Air don't got a name."
        - stop
    - inventory adjust d:<player.inventory> slot:<player.held_item_slot> display:<context.raw_args.parse_color>
    - narrate "<&[base]>Renamed to <&[emphasis]><context.raw_args.parse_color>"
