enchant_command:
    type: command
    debug: false
    permission: dscript.enchant
    name: enchant
    usage: /enchant [enchantment] [level]
    description: Adds an enchant to your held item. Use level 0 to remove.
    script:
    - if <context.args.size> < 2:
        - narrate "<&[error]>/enchant [enchantment] [level]"
        - stop
    - if <player.item_in_hand.material.name> == air:
        - narrate "<&[error]>Air cannot be enchanted."
        - stop
    - if !<context.args.get[2].is_integer>:
        - narrate "<&[error]>Level must be an integer number. Use 0 to remove."
        - stop
    - define enchantment null
    - if <server.enchantments.parse[name].contains[<context.args.get[1]>]>:
        - define enchantment <context.args.get[1]>
    - else if <server.enchantments.parse[name].filter[contains_text[<context.args.get[1]>]].size> == 1:
        - define enchantment <server.enchantments.parse[name].filter[contains_text[<context.args.get[1]>]].first>
    - else:
        - narrate "<&[error]>Invalid enchantment, must be any of: <&[emphasis]><server.enchantments.parse[name].separated_by[, ]>"
        - stop
    - if <context.args.get[2]> == 0:
        - inventory adjust d:<player.inventory> slot:<player.held_item_slot> remove_enchantments:<[enchantment]>
        - narrate "<&a>Removed <&[emphasis]><[enchantment]><&[base]> from your item."
    - else:
        - inventory adjust d:<player.inventory> slot:<player.held_item_slot> enchantments:<[enchantment]>,<context.args.get[2]>
        - narrate "<&a>Enchanted your <&[emphasis]><player.item_in_hand.material.name><&a> with the enchantment <&[emphasis]><[enchantment]><&[base]> at level <&[emphasis]><context.args.get[2]><&[base]>."
