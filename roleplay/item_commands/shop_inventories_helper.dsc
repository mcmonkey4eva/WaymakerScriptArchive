buyable_item_proc:
    type: procedure
    debug: false
    definitions: orig_item|price|reopen
    script:
    - define item <item[<[orig_item]>]>
    - if <player.money||9999> < <[price]>:
        - adjust def:item lore:<list[<&c>You cannot afford this item.|Price: <&6><[price]> TG].include[<[item].lore.parse_tag[<&color[#404040]><&o><[parse_value].strip_color>]>]>
        - if <[item].material.max_durability> > 1:
            - adjust def:item durability:<[item].material.max_durability.sub[1]>
        - determine <[item]>
    - adjust def:item lore:<list[<&f><&l>Price<&co> <&6><[price]> TG].include[<[item].lore||<list>>]>
    - determine <[item].with_flag[buyable].with_flag[price:<[price]>].with_flag[reopen:<[reopen]||true>].with_flag[buys:<[orig_item]>]>

sellable_item_proc:
    type: procedure
    debug: false
    definitions: orig_item|sell_value|reopen
    script:
    - define item <item[<[orig_item]>]>
    - if !<player.inventory.contains_item[<[item].script.name>].quantity[<[item].quantity>]>:
        - adjust def:item lore:<list[<&c>You do not have this item to sell.].include[<[item].lore.parse_tag[<&color[#404040]><&o><[parse_value].strip_color>]>]>
        - if <[item].material.max_durability> > 1:
            - adjust def:item durability:<[item].material.max_durability.sub[1]>
        - determine <[item]>
    - adjust def:item lore:<list[<&f><&l>Sell Value<&co> <&6><[sell_value]> TG].include[<[item].lore||<list>>]>
    - determine <[item].with_flag[sellable].with_flag[reopen:<[reopen]||true>].with_flag[sell_value:<[sell_value]>]>

shop_inventories_world:
    type: world
    debug: false
    events:
        on player clicks item in inventory:
        - if <context.item.has_flag[buyable]> && <context.item.flag[price]||null> != null && <context.item.flag[buys]||null> != null:
            - if <player.flag[character_mode]> != ic:
                - narrate "<&[error]>You must be IC to use buyable items."
                - stop
            - determine passively cancelled
            - define reopen <context.item.flag[reopen]>
            - define price <context.item.flag[price]>
            - if <player.money> < <[price]>:
                - narrate "<&[error]>You cannot afford that."
                - stop
            - money take quantity:<[price]>
            - run eco_log_loss def.amount:<[price]> "def.reason:bought <&lb><element[<context.item.display||<context.item.material.translated_name>>].on_hover[<context.item>].type[show_item]><&rb> from an auto shop"
            - define inv <context.inventory.note_name||<context.inventory.script.name||null>>
            - narrate "<&[base]>Paid <&6><[price]> Trade Gold<&[base]>."
            - define buys <context.item.flag[buys]>
            - wait 1t
            - run give_safe_item def.item:<[buys]>
            - inventory update
            - if <[inv]||null> != null && <[reopen]>:
                - inventory open d:<[inv]>
        - if <context.item.has_flag[sellable]> && <context.item.flag[sell_value]||null> != null:
            - if <player.flag[character_mode]> != ic:
                - narrate "<&[error]>You must be IC to use sellable items."
                - stop
            - determine passively cancelled
            - define reopen <context.item.flag[reopen]>
            - define sell_value <context.item.flag[sell_value]>
            - if !<player.inventory.contains_item[<context.item.script.name>].quantity[<context.item.quantity>]>:
                - narrate "<&[error]>You do not have this item to sell."
                - stop
            - money give quantity:<[sell_value]>
            - run eco_log_gain def.amount:<[sell_value]> "def.reason:sold <&lb><element[<context.item.display||<context.item.material.translated_name>>].on_hover[<context.item>].type[show_item]><&rb> to an auto shop"
            - take scriptname:<context.item.script.name> quantity:<context.item.quantity>
            - define inv <context.inventory.note_name||<context.inventory.script.name||null>>
            - narrate "<&[base]>Received <&6><[sell_value]> Trade Gold<&[base]>."
            - wait 1t
            - inventory update
            - if <[inv]||null> != null && <[reopen]>:
                - inventory open d:<[inv]>
