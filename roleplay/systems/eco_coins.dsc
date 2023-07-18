
trade_penny_item:
    type: item
    debug: false
    material: gold_nugget
    display name: <&color[#8BD54C]>Trade Penny
    lore:
    - <&7>This thick, triangular coin is made
    - <&7>almost entirely from gold. A large
    - <&7>triangular hole has been punched
    - <&7>into the centre of it, while its edge
    - <&7>is decorated with stylized sets of
    - <&7>overlapping merchant's scales.
    - <&6>[1 Trade Gold]
    - <&f>[Common]
    mechanisms:
        custom_model_data: 100001
    flags:
        rarity: Common

trade_stater_item:
    type: item
    debug: false
    material: gold_nugget
    display name: <&color[#8BD54C]>Trade Stater
    lore:
    - <&7>This rectangular coin is roughly
    - <&7>pinky-length, and is made of pure
    - <&7>gold. The centre of the coin is
    - <&7>stamped with the symbol of the
    - <&7>International House Of Conversions
    - <&7>and Measures.
    - <&6>[10 Trade Gold]
    - <&f>[Common]
    mechanisms:
        custom_model_data: 100002
    flags:
        rarity: Common

trade_lion_item:
    type: item
    debug: false
    material: gold_nugget
    display name: <&color[#8BD54C]>Trade Lion
    lore:
    - <&7>This weighty golden brick sheens
    - <&7>with little to no imperfections on it.
    - <&7>The top of the golden bar is marked
    - <&7>with the symbol of the International
    - <&7>House of Conversions and Measures.
    - <&6>[100 Trade Gold]
    - <&f>[Common]
    mechanisms:
        custom_model_data: 100003
    flags:
        rarity: Common

eco_coin_inv_world:
    type: world
    debug: false
    events:
        on player drags in inventory:
        - if <player.flag[character_mode]> != ic:
            - stop
        - if <context.clicked_inventory.inventory_type> != player:
            - stop
        - if <context.item> matches trade_*_item:
            - if <context.slots.exclude[10|11|12|13|14].any>:
                - determine cancelled
        - else if <context.slots.contains_any[10|11|12|13|14]>:
            - determine cancelled
        on player clicks in inventory:
        - if <player.flag[character_mode]> != ic:
            - stop
        - if <context.action> in drop_all_cursor|drop_all_slot|drop_one_cursor:
            - stop
        - define cursor <context.cursor_item||<item[air]>>
        - define base <context.item||<item[air]>>
        - if <[cursor]> !matches trade_*_item && <[base]> !matches trade_*_item:
            - stop
        - if <context.clicked_inventory.inventory_type> != player:
            - determine cancelled
        - define slot <context.slot>
        - if <[slot]> !in 10|11|12|13|14:
            - if <[cursor]> matches trade_*_item:
                - determine cancelled
            - stop
        - choose <context.action>:
            - case pickup_all pickup_half pickup_one pickup_some swap_with_cursor drop_all_cursor drop_all_slot drop_one_cursor:
                - stop
            - case place_one place_all place_some:
                - if <[cursor]> !matches trade_*_item:
                    - determine cancelled
            # nothing unknown clone_stack hotbar_swap hotbar_move_and_readd
            - default:
                - determine cancelled
        on player picks up item:
        - if <player.flag[character_mode]> != ic:
            - stop
        - determine passively cancelled
        - run give_safe_item def.item:<context.item> def.drop_extra:false save:given
        - define leftover_qty <entry[given].created_queue.definition[leftover_qty]>
        - if <[leftover_qty]> == 0:
            - adjust <player> fake_pickup:<context.entity>
            - remove <context.entity>
        - else if <[leftover_qty]> != <context.item.quantity>:
            - adjust <player> fake_pickup:<context.entity>
            - remove <context.entity>
            - drop <entry[given].created_queue.definition[leftover]> <player.location>
        on player inventory slot changes:
        - if <context.new_item> matches air:
            - stop
        - if <player.flag[character_mode]> == ic && <context.slot.is_in[10|11|12|13|14]> != <context.new_item.advanced_matches[trade_*_item]>:
            - inventory set d:<player.inventory> slot:<context.slot> o:air
            # Backup plan in case something goes weird to prevent hyperrecursion
            - flag player inv_slot_eco_fix_depth:++ expire:1t
            - if <player.flag[inv_slot_eco_fix_depth]> > 50:
                - drop <context.new_item> <player.location>
                - stop
            - run give_safe_item def.item:<context.new_item>

give_safe_item:
    type: task
    debug: false
    definitions: item|inventory|drop_extra
    script:
    - if <[item]> matches air:
        - debug exception "Give_Safe_Item invalid input - tried to give air"
    - if !<[drop_extra].exists>:
        - define drop_extra true
    - if !<[inventory].exists>:
        - define inventory <player.inventory>
    - if <[inventory].inventory_type> == player && <[inventory].id_holder.as[player].flag[character_mode]> == ic:
        - if <[item]> matches trade_*_item:
            - define player <[inventory].id_holder.as[player]>
            - give <[item]> allowed_slots:10|11|12|13|14 ignore_leftovers:<[drop_extra].not> save:given to:<[inventory]>
            - run cc_set_flag def.pair:<[player].proc[cc_idpair]> def.flag:gold def.value:<proc[eco_proc_get_coins].proc[eco_count_proc]>
        - else:
            - give <[item]> allowed_slots:!10|11|12|13|14 ignore_leftovers:<[drop_extra].not> save:given to:<[inventory]>
    - else:
            - give <[item]> ignore_leftovers:<[drop_extra].not> save:given to:<[inventory]>
    - define leftover <entry[given].leftover_items>
    - define leftover_qty <[leftover].parse[quantity].sum>

eco_task_set_cc_coins:
    type: task
    debug: false
    definitions: pair|coins
    script:
    - define __player <[pair].before[__char__]>
    - define char <[pair].after[__char__]>
    - if <player.flag[character_mode]> == ic && <player.flag[current_character]> == <[char]>:
        - foreach 10|11|12|13|14 as:slot:
            - inventory set d:<player.inventory> o:air slot:<[slot]>
        - foreach <[coins]> as:coin:
            - inventory set d:<player.inventory> o:<[coin]> slot:<[loop_index].add[9]>
        - run cc_set_flag def.pair:<[pair]> def.flag:gold def.value:<[coins].proc[eco_count_proc]>
        - stop
    - define inv_map <[pair].proc[cc_flag].context[inventory]>
    - foreach 10|11|12|13|14 as:slot:
        - define inv_map.<[slot]>:!
    - foreach <[coins]> as:coin:
        - define inv_map.<[loop_index].add[9]>:<[coin]>
    - run cc_set_flag def.pair:<[pair]> def.flag:inventory def.value:<[inv_map]>
    - run cc_set_flag def.pair:<[pair]> def.flag:gold def.value:<[inv_map].values.proc[eco_count_proc]>

eco_proc_get_cc_coins:
    type: procedure
    debug: false
    definitions: pair
    script:
    - define __player <[pair].before[__char__]>
    - define char <[pair].after[__char__]>
    - if <player.flag[character_mode]> == ic && <player.flag[current_character]> == <[char]>:
        - determine <player.inventory.slot[10|11|12|13|14]>
    - define inv_map <[pair].proc[cc_flag].context[inventory]>
    - determine <[inv_map].get_subset[10|11|12|13|14].values>

eco_proc_get_coins:
    type: procedure
    debug: false
    definitions: player
    script:
    - define player <[player]||<player>>
    - determine <[player].inventory.slot[10|11|12|13|14]>

eco_count_proc:
    type: procedure
    debug: false
    definitions: items
    script:
    - define gold 0
    - foreach <[items]> as:item:
        - if <[item]> matches trade_lion_item:
            - define gold:+:<[item].quantity.mul[100]>
        - if <[item]> matches trade_stater_item:
            - define gold:+:<[item].quantity.mul[10]>
        - if <[item]> matches trade_penny_item:
            - define gold:+:<[item].quantity>
    - determine <[gold]>

eco_coinpurse_ref:
    type: inventory
    debug: false
    inventory: chest
    slots:
    - [] [] [] [] [] [stone] [stone] [stone] [stone]

money_give_task:
    type: task
    debug: false
    definitions: pair|amount
    script:
    - define items <[pair].proc[eco_proc_get_cc_coins]||<list>>
    - define temp_inv <inventory[eco_coinpurse_ref]>
    - give <[items].filter[advanced_matches[air].not]> to:<[temp_inv]>
    - define gold <[amount]>
    - while <[gold]> >= 100 && <[temp_inv].can_fit[trade_lion_item]>:
        - define gold:-:100
        - give trade_lion_item to:<[temp_inv]> ignore_leftovers
    - while <[gold]> >= 10 && <[temp_inv].can_fit[trade_stater_item]>:
        - define gold:-:10
        - give trade_stater_item to:<[temp_inv]> ignore_leftovers
    - while <[gold]> >= 1 && <[temp_inv].can_fit[trade_penny_item]>:
        - define gold:-:1
        - give trade_penny_item to:<[temp_inv]> ignore_leftovers
    - if <[gold]> == 0:
        - define items <[temp_inv].list_contents.first[5]>
    - else:
        - debug log "<[pair].proc[cc_format_idpair]> has too much gold in coinpurse, attempting reformat."
        - define full_amt <[pair].proc[eco_proc_get_cc_coins].proc[eco_count_proc].add[<[gold]>]>
        - if <[full_amt]> > <script[trade_gold_economy].parsed_key[data.wallet_max]>:
            - define lost <script[trade_gold_economy].parsed_key[data.wallet_max].sub[<[full_amt]>]>
            - narrate "<&[error]>Your wallet is overfilled! <&6><[lost]> TG <&[error]>is spilled onto the ground! Deposit your gold at the bank to avoid losing it from overfill."
            - drop trade_penny_item[quantity=<[lost]>] <player.location>
            - define items <item[trade_lion_item[quantity=64]].repeat_as_list[9]>
        - else:
            - define lions <[full_amt].div[100].round_down>
            - define full_amt:-:<[lions].mul[100]>
            - define staters <[full_amt].div[10].round_down>
            - define full_amt:-:<[staters].mul[10]>
            - define temp_inv <inventory[eco_coinpurse_ref]>
            - give trade_lion_item quantity:<[lions]> to:<[temp_inv]> ignore_leftovers
            - give trade_stater_item quantity:<[staters]> to:<[temp_inv]> ignore_leftovers
            - give trade_penny_item quantity:<[gold]> to:<[temp_inv]> ignore_leftovers
            - define items <[temp_inv].list_contents.first[5]>
    - run eco_task_set_cc_coins def.pair:<[pair]> def.coins:<[items]>

money_take_task:
    type: task
    debug: false
    definitions: pair|amount
    script:
    - define items <[pair].proc[eco_proc_get_cc_coins]||<list>>
    - define gold <[amount]>
    - foreach <[items]> as:item:
        - if <[gold]> > 100 && <[item]> matches trade_lion_item:
            - define scale 100
        - else if <[gold]> > 10 && <[item]> matches trade_stater_item:
            - define scale 10
        - else if <[gold]> > 0 && <[item]> matches trade_penny_item:
            - define scale 1
        - define item_amount <[item].quantity.mul[<[scale]>]>
        - if <[gold]> >= <[item_amount]>:
            - define items[<[loop_index]>]:air
            - define gold:-:<[item_amount]>
        - else:
            - define take <[gold].div[<[scale]>].round_down>
            - if <[take]> > 0:
                - define items[<[loop_index]>]:<[item].with[quantity=<[item].quantity.sub[<[take]>]>]>
                - define gold:-:<[take].mul[<[scale]>]>
    - if <[gold]> > 0:
        - define timestamp <util.time_now.epoch_millis>
        - debug error "<[timestamp]> Attempted to take <[amount]> gold from <[pair].proc[cc_format_idpair]> but ended up with <[gold]> gold left over for <[items]>"
        - narrate "<&[error]>Please report that an economy error has occurred: <&[emphasis]><[timestamp]>"
    - run eco_task_set_cc_coins def.pair:<[pair]> def.coins:<[items]>
