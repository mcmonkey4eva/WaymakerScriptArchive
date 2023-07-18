wood_salesman_world:
    type: world
    debug: false
    data:
        log_items: mine_item_bundle_of_oak_wood|mine_item_bundle_of_spruce_wood|mine_item_bundle_of_dark_oak_wood|mine_item_bundle_of_jungle_wood|mine_item_bundle_of_birch_wood|mine_item_bundle_of_acacia_wood
    events:
        on player clicks in wood_salesman_root_gui priority:10:
        - determine cancelled
        on player clicks in wood_salesman_buyaxe_gui priority:10:
        - determine cancelled
        on player clicks in wood_salesman_sellwood_gui priority:10:
        - determine cancelled
        on player clicks in wood_salesman_buywood_gui priority:10:
        - determine cancelled
        on player clicks wood_salesman_root_gui_buywoodswap in wood_salesman_root_gui:
        - inventory open d:wood_salesman_buywood_gui
        on player clicks wood_salesman_root_gui_sellwoodswap in wood_salesman_root_gui:
        - inventory open d:wood_salesman_sellwood_gui
        on player clicks wood_salesman_root_gui_buyaxeswap in wood_salesman_root_gui:
        - inventory open d:wood_salesman_buyaxe_gui
        on player clicks wood_salesman_back_button in inventory:
        - inventory open d:wood_salesman_root_gui
        after player clicks wood_salesman_sell_all_button in wood_salesman_sellwood_gui:
        - if <player.flag[character_mode]> != ic:
            - narrate "<&[error]>You must be IC to use the Wood Salesman."
            - stop
        - define payout 0
        - foreach <script.data_key[data.log_items]> as:type:
            - define quantity <player.inventory.quantity_item[<[type]>].div[16].round_down>
            - if <[quantity]> > 0:
                - take scriptname:<[type]> quantity:<[quantity].mul[16]>
                - money give quantity:<[quantity]>
                - define payout:+:<[quantity]>
                - run eco_log_gain def.amount:<[quantity]> "def.reason:sold all <&lb><element[<item[<[type]>].display||<item[<[type]>].material.translated_name>>].on_hover[<item[<[type]>]>].type[show_item]><&rb> to the wood shop"
        - if <[payout]> > 0:
            - narrate "<&[base]>Received <&6><[payout]> Trade Gold<&[base]>."
        - inventory open d:wood_salesman_sellwood_gui

proc_count_sellable_wood:
    type: procedure
    debug: false
    script:
    - define result 0
    - foreach <script[wood_salesman_world].data_key[data.log_items]> as:type:
        - define result:+:<player.inventory.quantity_item[<[type]>].div[16].round_down>
    - determine <[result]>

wood_salesman_root_gui:
    type: inventory
    debug: false
    inventory: chest
    title: <&b>Woody The Woodsman
    slots:
    - [] [] [] [] [wood_salesman_root_gui_buyaxeswap] [] [] [] []
    - [wood_salesman_root_gui_buywoodswap] [] [] [] [] [] [] [] [wood_salesman_root_gui_sellwoodswap]

wood_salesman_buyaxe_gui:
    type: inventory
    debug: false
    inventory: chest
    title: <&2>Buy Axes
    definitions:
        buyable_stone_axe: <proc[buyable_item_proc].context[tool_item_cheap_stone_hatchet|15]>
        buyable_iron_axe: <proc[buyable_item_proc].context[tool_item_iron_lumber_axe|50]>
        buyable_gold_axe: <proc[buyable_item_proc].context[tool_item_flimsy_golden_lumber_axe|500]>
        buyable_diamond_axe: <proc[buyable_item_proc].context[tool_item_kruosteel_lumber_axe|150]>
        buyable_netherite_axe: <proc[buyable_item_proc].context[tool_item_the_foe_of_the_forest|500]>
    slots:
    - [buyable_stone_axe] [] [buyable_iron_axe] [] [buyable_gold_axe] [] [buyable_diamond_axe] [] [buyable_netherite_axe]
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] [wood_salesman_back_button]

wood_salesman_buywood_gui:
    type: inventory
    debug: false
    inventory: chest
    title: <&2>Buy Wood
    size: 36
    procedural items:
    - define list <element[air].repeat_as_list[45]>
    - foreach oak|spruce|dark_oak|jungle|birch|acacia as:wood:
        - define item mine_item_bundle_of_<[wood]>_wood
        - define list[<[loop_index]>]:<proc[buyable_item_proc].context[<[item]>[quantity=64]|30]>
        - define list[<[loop_index].add[9]>]:<proc[buyable_item_proc].context[<[item]>[quantity=32]|20]>
        - define list[<[loop_index].add[18]>]:<proc[buyable_item_proc].context[<[item]>[quantity=16]|10]>
        - define list[<[loop_index].add[27]>]:<proc[buyable_item_proc].context[<[item]>[quantity=8]|5]>
    - define list[36]:wood_salesman_back_button
    - determine <[list]>

wood_salesman_sellwood_gui:
    type: inventory
    debug: false
    inventory: chest
    title: <&e>Sell Wood
    size: 36
    procedural items:
    - define list <element[air].repeat_as_list[45]>
    - define any false
    - foreach acacia|birch|jungle|dark_oak|spruce|oak as:wood:
        - define item mine_item_bundle_of_<[wood]>_wood
        - if <player.inventory.contains_item[<[item]>].quantity[16]>:
            - define any true
        - define list[<[loop_index]>]:<proc[sellable_item_proc].context[<[item]>[quantity=64]|4]>
        - define list[<[loop_index].add[9]>]:<proc[sellable_item_proc].context[<[item]>[quantity=32]|2]>
        - define list[<[loop_index].add[18]>]:<proc[sellable_item_proc].context[<[item]>[quantity=16]|1]>
        #- define list[<[loop_index].add[27]>]:<proc[sellable_item_proc].context[<[item]>[quantity=8]|1]>
    - if <[any]>:
        - define list[17]:wood_salesman_sell_all_button
    - else:
        - define list[17]:wood_salesman_cannot_sell_all_button
    - define list[36]:wood_salesman_back_button
    - determine <[list]>

wood_salesman_cannot_sell_all_button:
    type: item
    debug: false
    material: bedrock
    display name: <&c>Sell All
    lore:
    - <&f>No logs to sell.

wood_salesman_sell_all_button:
    type: item
    debug: false
    material: birch_wood
    enchantments:
    - sharpness:5
    mechanisms:
        hides: all
    display name: <&2>Sell All
    lore:
    - <&f>Sell <&[emphasis]><proc[proc_count_sellable_wood].mul[16]||0><&f> logs for <&6><proc[proc_count_sellable_wood]||0> TG

wood_salesman_root_gui_buywoodswap:
    type: item
    debug: false
    material: oak_log
    display name: <&2>Buy Wood
    lore:
    - <&f>Click to view the wood-buying screen.

wood_salesman_root_gui_sellwoodswap:
    type: item
    debug: false
    material: birch_log
    display name: <&e>Sell Wood
    lore:
    - <&f>Click to view the wood-selling screen.

wood_salesman_root_gui_buyaxeswap:
    type: item
    debug: false
    material: iron_axe
    display name: <&2>Buy Axes
    lore:
    - <&f>Click to view the axe-buying screen.

wood_salesman_back_button:
    type: item
    debug: false
    material: barrier
    display name: <&c>Back
    lore:
    - <&f>Click to return the main screen.
