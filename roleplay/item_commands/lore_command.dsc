lore_command:
    type: command
    debug: false
    permission: dscript.lore
    name: lore
    usage: /lore [line or 'clear' or 'remove'] [text]
    description: Changes lore on your held item.
    tab completions:
        1: add|remove|clear|1|2|3|4|5|6|7
        2: 1|2|3|4|5|6|7|8|9
    script:
    - if <player.item_in_hand.material.name> == air:
        - narrate "<&[error]>Air can't have lore."
        - stop
    - define full_lore <player.item_in_hand.lore||<list>>
    - if <player.item_in_hand.has_flag[lore_sign]>:
        - define full_lore <[full_lore].remove[last]>
    - if <player.item_in_hand.has_flag[rarity]>:
        - define full_lore <[full_lore].remove[last]>
    - run multi_line_edit_tool def.args:<context.args> def.orig_lines:<[full_lore]> def.cmd_prefix:/lore def.wrap_len:160 def.raw_args:<context.raw_args.parse_color> def.def_color:<&7> save:edited
    - define full_lore <entry[edited].created_queue.determination.first>
    - if <[full_lore].filter[strip_color.length.is_more_than[40]].any>:
        - narrate "<&[error]>Lore lines must be less than <&[emphasis]>40 <&[error]>characters. You should aim for 20-30."
        - stop
    - if <player.item_in_hand.has_flag[rarity]>:
        - define full_lore <[full_lore].include[<script[rarity_data].parsed_key[colors.<player.item_in_hand.flag[rarity]>]><&lb><player.item_in_hand.flag[rarity]><&rb>]>
    - if <player.item_in_hand.has_flag[lore_sign]>:
        - define full_lore <[full_lore].include[<player.item_in_hand.flag[lore_sign]>]>
    - if <[full_lore].is_empty>:
        - inventory adjust d:<player.inventory> slot:<player.held_item_slot> lore
    - else:
        - inventory adjust d:<player.inventory> slot:<player.held_item_slot> lore:<[full_lore]>
