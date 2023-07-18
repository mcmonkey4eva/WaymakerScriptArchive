iteminfo_command:
    type: command
    debug: false
    name: iteminfo
    usage: /iteminfo
    description: Tells you about the item in your hand.
    permission: dscript.iteminfo
    script:
    - define item <player.item_in_hand>
    - narrate "<&[base]>===== <[item].proc[embedder_for_item]> <&[base]>====="
    - narrate "<&[base]>Material: <&[emphasis]><[item].material.name>"
    - if <[item].material.name> == air:
        - stop
    - if <[item].has_display>:
        - define name <[item].display>
        - if <[name].starts_with[<&r>]>:
            - define name <[name].after[<&r>]>
        - narrate "<&[base]>Display name: <&[emphasis]><[name].replace[<&ss>].with[&]>"
    - if <[item].has_flag[rarity]>:
        - narrate "<&[base]>Rarity: <&[emphasis]><script[rarity_data].parsed_key[colors.<[item].flag[rarity]>]||><[item].flag[rarity]>"
    - if <[item].has_flag[lore_breaker_item]>:
        - narrate "<&[base]>Is mine farm tool for: <&[emphasis]><[item].flag[lore_breaker_item]>"
    - if <[item].has_flag[bound_to]>:
        - narrate "<&[base]>Bound to: <[item].flag[bound_to].proc[proc_format_name].context[<player>]>"
        - narrate "<&[base]>Bound because: <&[emphasis]><[item].flag[bound_sources].formatted>"
    - if <[item].has_flag[lore_sign_player]>:
        - narrate "<&[base]>Lore signed by: <[item].flag[lore_sign_player].proc[proc_format_name].context[<player>]>"
        - narrate "<&[base]>Lore signed at: <[item].flag[lore_sign_time].format>"
