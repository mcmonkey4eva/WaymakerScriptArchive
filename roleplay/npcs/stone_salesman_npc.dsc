stone_salesman_world:
    type: world
    debug: false
    data:
        stone_items: mine_item_pile_of_mossy_stones|mine_item_block_of_andesite|mine_item_block_of_diorite|mine_item_stack_of_stones|mine_item_block_of_granite|mine_item_basalt_chunk|mine_item_pile_of_gravel
    events:
        on player clicks in stone_salesman_root_gui priority:10:
        - determine cancelled
        on player clicks in stone_salesman_buyaxe_gui priority:10:
        - determine cancelled
        on player clicks in stone_salesman_sellstone_gui priority:10:
        - determine cancelled
        on player clicks in stone_salesman_buystone_gui priority:10:
        - determine cancelled
        on player clicks stone_salesman_root_gui_buystoneswap in stone_salesman_root_gui:
        - inventory open d:stone_salesman_buystone_gui
        on player clicks stone_salesman_root_gui_sellstoneswap in stone_salesman_root_gui:
        - inventory open d:stone_salesman_sellstone_gui
        on player clicks stone_salesman_root_gui_buyaxeswap in stone_salesman_root_gui:
        - inventory open d:stone_salesman_buyaxe_gui
        on player clicks stone_salesman_back_button in inventory:
        - inventory open d:stone_salesman_root_gui
        after player clicks stone_salesman_sell_all_button in stone_salesman_sellstone_gui:
        - if <player.flag[character_mode]> != ic:
            - narrate "<&[error]>You must be IC to use the Stone Salesman."
            - stop
        - define payout 0
        - foreach <script.data_key[data.stone_items]> as:type:
            - define quantity <player.inventory.quantity_item[<[type]>].div[16].round_down>
            - if <[quantity]> > 0:
                - take scriptname:<[type]> quantity:<[quantity].mul[16]>
                - money give quantity:<[quantity]>
                - define payout:+:<[quantity]>
                - run eco_log_gain def.amount:<[quantity]> "def.reason:sold all <&lb><element[<item[<[type]>].display||<item[<[type]>].material.translated_name>>].on_hover[<item[<[type]>]>].type[show_item]><&rb> to the stone shop"
        - if <[payout]> > 0:
            - narrate "<&[base]>Received <&6><[payout]> Trade Gold<&[base]>."
        - inventory open d:stone_salesman_sellstone_gui

proc_count_sellable_stone:
    type: procedure
    debug: false
    script:
    - define result 0
    - foreach <script[stone_salesman_world].data_key[data.stone_items]> as:type:
        - define result:+:<player.inventory.quantity_item[<[type]>].div[16].round_down>
    - determine <[result]>

stone_salesman_root_gui:
    type: inventory
    debug: false
    inventory: chest
    title: <&b>Matilda The Miner
    slots:
    - [] [] [] [] [stone_salesman_root_gui_buyaxeswap] [] [] [] []
    - [stone_salesman_root_gui_buystoneswap] [] [] [] [] [] [] [] [stone_salesman_root_gui_sellstoneswap]

stone_salesman_buyaxe_gui:
    type: inventory
    debug: false
    inventory: chest
    title: <&2>Buy Pickaxes
    definitions:
        buyable_stone_axe: <proc[buyable_item_proc].context[tool_item_crude_wooden_pick|5]>
        buyable_iron_axe: <proc[buyable_item_proc].context[tool_item_stone_pickaxe|15]>
        buyable_gold_axe: <proc[buyable_item_proc].context[tool_item_heavy_iron_pickaxe|50]>
        buyable_diamond_axe: <proc[buyable_item_proc].context[tool_item_kruosteel_pickaxe|150]>
        buyable_netherite_axe: <proc[buyable_item_proc].context[tool_item_dwarven_warpick|500]>
    slots:
    - [buyable_stone_axe] [] [buyable_iron_axe] [] [buyable_gold_axe] [] [buyable_diamond_axe] [] [buyable_netherite_axe]
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] [stone_salesman_back_button]

stone_salesman_buystone_gui:
    type: inventory
    debug: false
    inventory: chest
    title: <&2>Buy Stone
    size: 36
    procedural items:
    - define list <element[air].repeat_as_list[45]>
    - foreach mine_item_pile_of_mossy_stones|mine_item_block_of_andesite|mine_item_block_of_diorite|mine_item_stack_of_stones|mine_item_block_of_granite as:item:
        - define list[<[loop_index]>]:<proc[buyable_item_proc].context[<[item]>[quantity=64]|30]>
        - define list[<[loop_index].add[9]>]:<proc[buyable_item_proc].context[<[item]>[quantity=32]|20]>
        - define list[<[loop_index].add[18]>]:<proc[buyable_item_proc].context[<[item]>[quantity=16]|10]>
        - define list[<[loop_index].add[27]>]:<proc[buyable_item_proc].context[<[item]>[quantity=8]|5]>
    - define list[36]:stone_salesman_back_button
    - determine <[list]>

stone_salesman_sellstone_gui:
    type: inventory
    debug: false
    inventory: chest
    title: <&e>Sell Stone
    size: 36
    procedural items:
    - define list <element[air].repeat_as_list[45]>
    - define any false
    - foreach <script[stone_salesman_world].data_key[data.stone_items]> as:item:
        - if <player.inventory.contains_item[<[item]>].quantity[16]>:
            - define any true
        - define list[<[loop_index]>]:<proc[sellable_item_proc].context[<[item]>[quantity=64]|4]>
        - define list[<[loop_index].add[9]>]:<proc[sellable_item_proc].context[<[item]>[quantity=32]|2]>
        - define list[<[loop_index].add[18]>]:<proc[sellable_item_proc].context[<[item]>[quantity=16]|1]>
        #- define list[<[loop_index].add[27]>]:<proc[sellable_item_proc].context[<[item]>[quantity=8]|1]>
    - if <[any]>:
        - define list[18]:stone_salesman_sell_all_button
    - else:
        - define list[18]:stone_salesman_cannot_sell_all_button
    - define list[36]:stone_salesman_back_button
    - determine <[list]>

stone_salesman_cannot_sell_all_button:
    type: item
    debug: false
    material: bedrock
    display name: <&c>Sell All
    lore:
    - <&f>No stone to sell.

stone_salesman_sell_all_button:
    type: item
    debug: false
    material: cobblestone
    enchantments:
    - sharpness:5
    mechanisms:
        hides: all
    display name: <&2>Sell All
    lore:
    - <&f>Sell <&[emphasis]><proc[proc_count_sellable_stone].mul[16]||0><&f> stone for <&6><proc[proc_count_sellable_stone]||0> TG

stone_salesman_root_gui_buystoneswap:
    type: item
    debug: false
    material: andesite
    display name: <&2>Buy Stone
    lore:
    - <&f>Click to view the stone-buying screen.

stone_salesman_root_gui_sellstoneswap:
    type: item
    debug: false
    material: stone
    display name: <&e>Sell Stone
    lore:
    - <&f>Click to view the stone-selling screen.

stone_salesman_root_gui_buyaxeswap:
    type: item
    debug: false
    material: iron_pickaxe
    display name: <&2>Buy Pickaxes
    lore:
    - <&f>Click to view the pickaxe-buying screen.

stone_salesman_back_button:
    type: item
    debug: false
    material: barrier
    display name: <&c>Back
    lore:
    - <&f>Click to return the main screen.
