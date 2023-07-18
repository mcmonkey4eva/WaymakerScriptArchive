itemcolor_command:
    type: command
    debug: false
    permission: dscript.itemcolor
    name: itemcolor
    usage: /itemcolor [color]
    description: Recolors a colorable item.
    tab completions:
        1: <context.args.first.if_null[].proc[color_tabcomplete_proc]>
    script:
    - if <context.args.is_empty>:
        - narrate "<&[error]>/itemcolor [color]"
        - if <player.item_in_hand.color||null> != null:
            - narrate "<&[base]>Your held item is <&color[<player.item_in_hand.color>]>this color<&[base]>: <player.item_in_hand.color.hex>."
        - stop
    - if <player.item_in_hand.color||null> == null:
        - narrate "<&[error]>Your held item cannot change color."
        - stop
    - inject set_color_command_prevalidate
    - define color <color[<[color]>]||null>
    - if <[color]> == null:
        - narrate "<&[error]>Input must be a valid color, like '#FF00FF' or 'magenta' or '255,0,255'."
        - stop
    - inventory adjust d:<player.inventory> slot:<player.held_item_slot> color:<[color]>
    - narrate "<&a>Recolored your your <&[emphasis]><player.item_in_hand.material.translated_name><&a> to <&color[<[color]>]>this color<&[base]>: <[color].hex>."
