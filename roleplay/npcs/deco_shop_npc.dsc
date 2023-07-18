

deco_shop_world:
    type: world
    debug: false
    events:
        after player clicks item_flagged:deco_shop_key in deco_shop_root_inventory:
        - if <player.flag[character_mode]> != ic:
            - narrate "<&[error]>You must be IC to use Deco Shops."
            - stop
        - run show_deco_shop_inv def.key:<context.item.flag[deco_shop_key]> def.section:<context.item.flag[deco_shop_section]>
        after player clicks deco_shop_back_button in deco_shop_subset_inventory:
        - if <player.flag[character_mode]> != ic:
            - narrate "<&[error]>You must be IC to use Deco Shops."
            - stop
        - inventory open d:deco_shop_root_inventory
        after player clicks deco_shop_block_back_button in deco_shop_single_block_inventory:
        - if <player.flag[character_mode]> != ic:
            - narrate "<&[error]>You must be IC to use Deco Shops."
            - stop
        - run show_deco_shop_inv def.key:<context.item.flag[deco_shop_key]> def.section:<context.item.flag[deco_shop_section]>
        after player clicks item_flagged:deco_shop_item in deco_shop_subset_inventory:
        - if <player.flag[character_mode]> != ic:
            - narrate "<&[error]>You must be IC to use Deco Shops."
            - stop
        - run show_deco_shop_singleitem_inv def.item:<context.item.flag[deco_shop_item]> def.key:<context.item.flag[deco_shop_key]> def.price:<context.item.flag[deco_shop_price]> def.section:<context.item.flag[deco_shop_section]>
        after player clicks deco_shop_sell_button in deco_shop_root_inventory:
        - if <player.flag[character_mode]> != ic:
            - narrate "<&[error]>You must be IC to use Deco Shops."
            - stop
        - if <player.item_on_cursor.flag[rarity]||null> == decoration:
            - define amount <player.item_on_cursor.quantity>
            - adjust <player> item_on_cursor:air
            - money give quantity:<[amount]>
            - run eco_log_gain def.amount:<[amount]> "def.reason:sold <&lb><element[<context.item.display||<context.item.material.translated_name>>].on_hover[<context.item>].type[show_item]><&rb> back the deco shop"
            - narrate "<&[base]>Received <&6><[amount]> Trade Gold<&[base]>."

show_deco_shop_singleitem_inv:
    type: task
    debug: false
    definitions: item|key|price|section
    script:
    - if <player.flag[character_mode]> != ic:
        - narrate "<&[error]>You must be IC to use Deco Shops."
        - stop
    - define item_map <map>
    - foreach 1|2|4|8|16|32|64 as:quantity:
        - define item_map.<[loop_index]>:<[item].as[item].with_single[quantity=<[quantity]>].proc[buyable_item_proc].context[<[price].mul[<[quantity]>]>|false]>
    - define item_map.46:<item[deco_shop_block_back_button].with_flag[deco_shop_key:<[key]>].with_flag[deco_shop_section:<[section]>]>
    - define inventory <inventory[deco_shop_single_block_inventory]>
    - adjust def:inventory "title:<&2>Decoration Shop<&co> Buy <&[emphasis]><[item].display||<[item].material.translated_name>>"
    - inventory set d:<[inventory]> o:<[item_map]>
    - inventory open d:<[inventory]>

show_deco_shop_inv:
    type: task
    debug: false
    definitions: key|section
    script:
    - if <player.flag[character_mode]> != ic:
        - narrate "<&[error]>You must be IC to use Deco Shops."
        - stop
    - define items <script[deco_shop_items].parsed_key[<[key]>]||null>
    - if <[items]> == null:
        - announce to_console "Broken deco shop <[key]> used by player <player.name>"
        - stop
    - define item_map <map>
    - foreach <[items]> as:item:
        - if <[item]> == air:
            - foreach next
        - define price 2
        - if <[key]> == functionality:
            - define price <[item].after[/]>
            - define item <[item].before[/]>
        - else if <[key]> == banners:
            - define price 5
        - define item <[item].as[item].with_single[lore=<&e>[Decoration]].with_flag[rarity:decoration]>
        - define item_map.<[loop_index]>:<[item].with_single[lore=<&6>Price<&co><&sp><[price]><&sp>TG|<&e>[Decoration]].with_flag[deco_shop_item:<[item]>].with_flag[deco_shop_key:<[key]>].with_flag[deco_shop_price:<[price]>].with_flag[deco_shop_section:<[section]>]>
    - define item_map.46:deco_shop_back_button
    - define inventory <inventory[deco_shop_subset_inventory]>
    - adjust def:inventory "title:<&2>Decoration Shop<&co> <&[emphasis]><[section]>"
    - inventory set d:<[inventory]> o:<[item_map]>
    - inventory open d:<[inventory]>

deco_shop_root_inventory:
    type: inventory
    debug: false
    gui: true
    inventory: chest
    title: <&[emphasis]>Decoration Shop
    size: 54
    definitions:
        heads_indoor: <proc[deco_shop_root_item_proc].context[player_head[skull_skin=85dd7aa8-3c6b-3f88-939b-ab5c24cd11fe|eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvYWU4ZmU4NDAzMTFmMTI2MzlhOGVlNmFkN2VkNjMyNWIyMmI3OTBkODEyNzg4YzlhZGExMTI4NDE3NzVhZSJ9fX0=]|heads_indoor|Heads (Indoor)]>
        heads_outdoor: <proc[deco_shop_root_item_proc].context[player_head[skull_skin=89043a5b-7a7d-aa53-9fd2-d80506ce7f6b|eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvODZlYmU5Y2Y3NzFhNDNiOTYwYzVjZjMzYjdjZjgwNGU3OWFkZDhjYTExZjY1NmRjOGM1OWM2YzZmNzdjNSJ9fX0=]|heads_outdoor|Heads (Outdoor)]>
        heads_drinks: <proc[deco_shop_root_item_proc].context[player_head[skull_skin=c357050f-e9a0-488a-8713-6d973aa69f4c|eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvYzg3YWIyMmNiYWFhYWZjMDQwYTczOWViYWFjNWJhNWRhYjc4MzA3NWU4YzFiY2M4M2QzNTRjZDU2NmRjNzNjIn19fQ==]|heads_drinks|Heads (Drinks)]>
        heads_food: <proc[deco_shop_root_item_proc].context[player_head[skull_skin=9b80f661-aad4-4597-94cc-4365c3d9f907|eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvOGVlOTdhMDhhZDA1NGI4MDY4NGU3NmYxMzI5ZGRkMGIxZmEyNzNiMDY5OWVlODZiMjEzNzk3MDRmNzQ2OGNhIn19fQ==]|heads_food|Heads (Food)]>
    slots:
    - [] [] [] [] [] [] [] [] []
    - [] [] [<proc[deco_shop_root_item_proc].context[chest|functionality|Functionality]>] [<proc[deco_shop_root_item_proc].context[white_banner|banners|Dyes/Banners]>] [<proc[deco_shop_root_item_proc].context[warped_hyphae|crimson_warped|Crimson/Warped]>] [<proc[deco_shop_root_item_proc].context[purpur_block|exotic|Exotic]>] [] [] []
    - [] [] [heads_indoor] [heads_outdoor] [heads_drinks] [heads_food] [] [] []
    - [] [] [] [<proc[deco_shop_root_item_proc].context[oak_fence|wood_decor|Wood Decor]>] [<proc[deco_shop_root_item_proc].context[oak_planks|wood_blocks|Wood Blocks]>] [] [] [] []
    - [] [<proc[deco_shop_root_item_proc].context[white_wool|wool|Wool]>] [<proc[deco_shop_root_item_proc].context[oak_leaves|flora|Flora]>] [<proc[deco_shop_root_item_proc].context[glass|glass|Glass]>] [<proc[deco_shop_root_item_proc].context[lime_glazed_terracotta|terracotta|Terracotta]>] [<proc[deco_shop_root_item_proc].context[lantern|misc|Misc]>] [<proc[deco_shop_root_item_proc].context[lime_bed|beds|Beds]>] [<proc[deco_shop_root_item_proc].context[red_concrete|concrete|Concrete]>] []
    - [] [] [] [<proc[deco_shop_root_item_proc].context[sandstone|sandstone|Sandstone]>] [<proc[deco_shop_root_item_proc].context[stone_bricks|stone|Stone]>] [] [] [] [deco_shop_sell_button]

deco_shop_root_item_proc:
    type: procedure
    debug: false
    definitions: material|key|section
    script:
    - define item <item[<[material]>]>
    - adjust def:item display:<&2><[section]>
    - adjust def:item "lore:<&f>Click to view <&[emphasis]><[section]> <&f>blocks for sale"
    - adjust def:item flag:deco_shop_key:<[key]>
    - adjust def:item flag:deco_shop_section:<[section]>
    - determine <[item]>

deco_shop_subset_inventory:
    type: inventory
    debug: false
    gui: true
    inventory: chest
    title: <&2>Decoration Shop
    size: 54

deco_shop_back_button:
    type: item
    debug: false
    material: barrier
    display name: <&c>Back
    lore:
    - <&f>Click to return the main screen.

deco_shop_single_block_inventory:
    type: inventory
    debug: false
    gui: true
    inventory: chest
    title: <&2>Decoration Shop
    size: 54

deco_shop_block_back_button:
    type: item
    debug: false
    material: barrier
    display name: <&c>Back
    lore:
    - <&f>Click to return the block selection screen.

deco_shop_sell_button:
    type: item
    debug: false
    material: gold_nugget
    mechanisms:
        custom_model_data: 100001
    display name: <yellow>Sell Items Back
    lore:
    - <&f>Place a <&[emphasis]>Decoration Shop<&f> item
    - <&f>into this slot to sell it back
    - <&f>for <&6>1 TG <&f>each.
