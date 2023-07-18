
trade_gold_pay_aliaser_command:
    type: command
    debug: false
    name: pay
    permission: dscript.tradegold
    usage: /pay [player] [amount]
    description: Pay money to a player.
    tab completions:
        1: <server.online_players.filter[has_flag[vanished].not].parse[name]>
        2: 1|5|10|20|50|100
    script:
    - execute as_player "money pay <context.raw_args>"

trade_gold_withdraw_aliaser_command:
    type: command
    debug: false
    name: withdraw
    permission: dscript.tradegold
    usage: /withdraw [amount]
    description: Withdraw money to gold items.
    tab completions:
        1: <context.args.first.replace[p].replace[s].replace[l].round||10>s|<context.args.first.replace[p].replace[s].replace[l].round||10>p|<context.args.first.replace[p].replace[s].replace[l].round||10>L|<context.args.first.round||10>
    script:
    - execute as_player "money withdraw <context.raw_args>"

trade_gold_deposit_aliaser_command:
    type: command
    debug: false
    name: deposit
    permission: dscript.tradegold
    usage: /deposit (amount)
    description: Deposits gold items into your bank.
    tab completions:
        1: 1|5|10|20|50|100
    script:
    - execute as_player "money deposit <context.raw_args>"

trade_gold_command:
    type: command
    debug: false
    name: money
    aliases:
    - m
    - tradegold
    - balance
    - bal
    - tg
    permission: dscript.tradegold
    usage: /money or /money pay [player] [amount]
    description: Manages your money.
    tab completions:
        1: pay
        2: <server.online_players.filter[has_flag[vanished].not].parse[name]>
    script:
    - if <player.flag[character_mode]> != ic:
        - narrate "<&[error]>You must be IC to manage money."
        - stop
    - if <context.args.is_empty>:
        - narrate "<&[base]>You have <&6><player.money> Trade Gold<&[base]> in your coin purse."
        - stop
    - choose <context.args.first>:
        - case pay:
            - if <context.args.size> < 3:
                - narrate "<&[error]>/pay [player] [amount]"
                - stop
            - define amount <context.args.get[3]>
            - if <context.args.get[2]> in Waymaker|WaymakerMC|WaymakerRP:
                - narrate "<&[error]>Use: /business pay Waymaker <[amount]>"
                - stop
            - define target <server.match_offline_player[<context.args.get[2]>]||null>
            - if <[target]> == null:
                - narrate "<&[error]>Unknown target player."
                - stop
            - if <[target].flag[character_mode]> != ic:
                - narrate "<[target].proc[proc_format_name].context[<player>]><&[error]> is not IC."
                - stop
            - if !<[target].proc[cc_has_flag].context[verified]>:
                - narrate "<[target].proc[cc_idpair].proc[cc_format_idpair].context[<player>]><&[error]> is not yet verified."
                - stop
            - if !<[amount].is_integer>:
                - narrate "<&[error]>Amount must be an integer number."
                - stop
            - if <[amount]> <= 0 || <[amount]> > 999999999:
                - narrate "<&[error]>Amount must be more than zero and less than a billion."
                - stop
            - if <[amount]> > <player.money>:
                - narrate "<&[error]>You cannot afford to pay that much."
                - stop
            - money take quantity:<[amount]>
            - money give quantity:<[amount]> players:<[target]>
            - define reason "was paid via command by <&[emphasis]><player.name.on_hover[<player.uuid>]>"
            - run eco_log_gain player:<[target]> def.amount:<[amount]> def.reason:<[reason]>
            - define reason "paid via command to <&[emphasis]><[target].name.on_hover[<[target].uuid>]>"
            - run eco_log_loss def.amount:<[amount]> def.reason:<[reason]>
            - narrate "<&[base]>You paid <[target].proc[proc_format_name].context[<player>]><&6> <[amount]> Trade Gold<&[base]>."
            - narrate "<player.proc[proc_format_name].context[<[target]>]> paid you<&6> <[amount]> Trade Gold<&[base]>." targets:<[target]>
            - stop
        - default:
            - narrate "<&[error]>/money <&[warning]> to show your balance"
            - narrate "<&[error]>/pay [player] [amount]"

eco_staff_command:
    type: command
    debug: false
    name: economy
    aliases:
    - eco
    permission: dscript.ecostaff
    usage: /economy [view/set/add/take/history/statistics] [player] [amount]
    description: Controls other players' money as staff.
    tab completions:
        1: view|set|add|take|history|help|statistics
        2: <context.args.get[2].if_null[].proc[cmd_player_char_select_helper_tab]>
    script:
    - choose <context.args.first||help>:
        - case view:
            - define pl_target_name <context.args.get[2]||null>
            - inject cmd_player_char_select_helper
            - narrate "<&[emphasis]><[pair].proc[cc_format_idpair].context[<player>]> <&[base]>has <&6><[pair].proc[eco_proc_get_cc_coins].proc[eco_count_proc]> Trade Gold<&[base]>."
        - case history:
            - define target <server.match_offline_player[<context.args.get[2]||null>]||null>
            - if <[target]> == null:
                - narrate "<&[error]>Unknown target player."
                - stop
            - define page <context.args.get[3]||1>
            - if !<[page].is_integer>:
                - narrate "<&[error]>Invalid page number."
                - stop
            - define page_start <[page].sub[1].mul[10]>
            - define page_end <[page_start].add[10]>
            - define history_length <[target].flag[economy_history].size||0>
            - define history <[target].flag[economy_history].reverse.get[<[page_start]>].to[<[page_end]>]||<list>>
            - if <[page]> == 1:
                - narrate "<&[base]>======= <&[emphasis]><[target].name> <&[base]>has <&6><[target].money> Trade Gold<&[base]>... <&[base]>======="
            - else:
                - narrate "<&[base]>======= <&[emphasis]><[target].name> <&[base]>economy history, page <&[emphasis]><[page]><&[base]>: ======="
            - if <[history].is_empty>:
                - narrate "<&[error]>No history to show."
            - else:
                - foreach <[history]> as:entry:
                    - narrate <[entry]>
            - define previous_page <&[clickable]><element[<&lb>Previous Page: <[page].sub[1]><&rb>].on_hover[Click To Navigate].on_click[/economy history <[target].name> <[page].sub[1]>]>
            - define next_page <&[clickable]><element[<&lb>Next Page: <[page].add[1]><&rb>].on_hover[Click To Navigate].on_click[/economy history <[target].name> <[page].add[1]>]>
            - if <[page]> == 1 && <[history_length]> > <[page_end]>:
                - narrate <[next_page]>
            - else if <[page]> > 1 && <[history_length]> > <[page_end]>:
                - narrate "<[previous_page]> <&7>| <[next_page]>"
            - else if <[page]> > 1:
                - narrate <[previous_page]>
        - case set:
            - define pl_target_name <context.args.get[2]||null>
            - inject cmd_player_char_select_helper
            - if !<context.args.get[3].is_integer>:
                - narrate "<&[error]>Amount must be a number."
                - stop
            - define amount <context.args.get[3].round>
            - if <[amount]> != <context.args.get[3]> || <[amount]> < 0 || <[amount]> > <script[trade_gold_economy].parsed_key[data.wallet_max]>:
                - narrate "<&[error]>Amount cannot have a decimal point, and must be non-negative, and less than <script[trade_gold_economy].parsed_key[data.wallet_max]>."
                - stop
            - flag <[target]> character_cards.<[char_name]>.coinpurse:<list>
            - run money_give_task def.pair:<[pair]> def.amount:<[amount]>
            - define reason "was staff-set by <&[emphasis]><player.name.on_hover[<player.uuid>]||server>"
            - run eco_log_set player:<[target]> def.amount:<[amount]> def.reason:<[reason]> def.character:<[char_name]>
            - narrate "<&[emphasis]><[pair].proc[cc_format_idpair].context[<player>]> <&[base]>now has <&6><[amount]> Trade Gold<&[base]>."
        - case add give:
            - define pl_target_name <context.args.get[2]||null>
            - inject cmd_player_char_select_helper
            - if !<context.args.get[3].is_integer>:
                - narrate "<&[error]>Amount must be a number."
                - stop
            - define amount <context.args.get[3].round>
            - if <[amount]> != <context.args.get[3]> || <[amount]> <= 0 || <[amount]> > <script[trade_gold_economy].parsed_key[data.wallet_max]>:
                - narrate "<&[error]>Amount cannot have a decimal point, and must be greater than 0, and less than <script[trade_gold_economy].parsed_key[data.wallet_max]>."
                - stop
            - run money_give_task def.pair:<[pair]> def.amount:<[amount]>
            - define reason "was staff-given by <&[emphasis]><player.name.on_hover[<player.uuid>]||server>"
            - run eco_log_gain player:<[target]> def.amount:<[amount]> def.reason:<[reason]> def.character:<[char_name]>
            - narrate "<&[emphasis]><[pair].proc[cc_format_idpair].context[<player>]> <&[base]>given <&6><[amount]> Trade Gold<&[base]>."
        - case take remove subtract:
            - define pl_target_name <context.args.get[2]||null>
            - inject cmd_player_char_select_helper
            - if !<context.args.get[3].is_integer>:
                - narrate "<&[error]>Amount must be a number."
                - stop
            - define amount <context.args.get[3].round>
            - if <[amount]> != <context.args.get[3]> || <[amount]> <= 0 || <[amount]> > <script[trade_gold_economy].parsed_key[data.wallet_max]>:
                - narrate "<&[error]>Amount cannot have a decimal point, and must be greater than 0, and less than <script[trade_gold_economy].parsed_key[data.wallet_max]>."
                - stop
            - if <[amount]> > <[target].money>:
                - define amount <[target].money>
            - run money_take_task def.pair:<[pair]> def.amount:<[amount]>
            - define reason "was staff-taken by <&[emphasis]><player.name.on_hover[<player.uuid>]||server>"
            - run eco_log_loss player:<[target]> def.amount:<[amount]> def.reason:<[reason]> def.character:<[char_name]>
            - narrate "<&[base]>Took <&6><[amount]> Trade Gold<&[base]> from <&[emphasis]><[pair].proc[cc_format_idpair].context[<player>]><&[base]>."
        - case statistics:
            - narrate "<&[base]>Please hold, calculating..."
            - wait 1t
            - define economy_all <server.players.filter[has_flag[eco_active]].filter[has_flag[eco_ignore].not].parse[proc[cc_list_char_datas]].combine.sort_by_number[get[gold]].reverse>
            - if <[economy_all].is_empty>:
                - narrate "<&[error]>No playerdata in economy."
                - stop
            - wait 2t
            - narrate "<&[base]>Top characters:"
            - foreach <[economy_all].get[1].to[10]> as:target:
                - narrate "<&[emphasis]><[loop_index]>) <proc[proc_format_name].context[<[target.player]>|<player||server>]><&[base]>'s character <&[emphasis]><[target.name]> <&[base]>has <&6><[target.gold]> TG"
            - wait 1t
            - narrate "<&[base]> ==== All Characters In Economy ===="
            - wait 1t
            - define amounts <[economy_all].parse[get[gold]]>
            - wait 1t
            - define sum <[amounts].sum>
            - wait 1t
            - define mean <[sum].div[<[amounts].size>].round>
            - define median <[amounts].get[<[amounts].size.div[2].round>]>
            - wait 1t
            - define amounts_std <[amounts].parse[sub[<[mean]>].power[2]]>
            - wait 1t
            - define sum_std <[amounts_std].sum>
            - wait 1t
            - define std_dev <[sum_std].div[<[amounts_std].size>].sqrt.round>
            - wait 1t
            - narrate "<&[base]>Minimum: <&6><[economy_all].last.get[gold]> TG<&[base]>, Maximum: <&6><[economy_all].first.get[gold]> TG<&[base]>, Total: <&6><[sum]> TG<&[base]>, People: <&[emphasis]><[economy_all].size><&[base]>, Average (Mean): <&6><[mean]> TG<&[base]>, Average (Median): <&6><[median]> TG<&[base]>, Std. Dev: <&6><[std_dev]> TG"
            - wait 1t
            - narrate "<&[base]> ==== Characters Active In Last Month ===="
            - define month <util.time_now.sub[31d]>
            - define sub_list <[economy_all].filter[get[last_used].is_after[<[month]>]]>
            - wait 1t
            - define amounts <[sub_list].parse[get[gold]]>
            - wait 1t
            - define sum <[amounts].sum>
            - wait 1t
            - define mean <[sum].div[<[amounts].size>].round>
            - define median <[amounts].get[<[amounts].size.div[2].round>]>
            - wait 1t
            - define amounts_std <[amounts].parse[sub[<[mean]>].power[2]]>
            - wait 1t
            - define sum_std <[amounts_std].sum>
            - wait 1t
            - define std_dev <[sum_std].div[<[amounts_std].size>].sqrt.round>
            - wait 1t
            - narrate "<&[base]>Minimum: <&6><[sub_list].last.get[gold]> TG<&[base]>, Maximum: <&6><[sub_list].first.get[gold]> TG<&[base]>, Total: <&6><[sum]> TG<&[base]>, People: <&[emphasis]><[sub_list].size><&[base]>, Average (Mean): <&6><[sum].div[<[amounts].size>].round> TG<&[base]>, Average (Median): <&6><[median]> TG<&[base]>, Std. Dev: <&6><[std_dev]> TG"
        - default:
            - narrate "<&[error]>/economy view/history [player]"
            - narrate "<&[error]>/economy set/add/take [player] [amount]"
            - narrate "<&[error]>/economy statistics"

eco_log_loss:
    type: task
    debug: false
    definitions: amount|reason|character
    script:
    - define character <[character].if_null[<player.flag[current_character]>]>
    - flag <player> "economy_history:->:<element[<&c>- <[amount]> TG].on_hover[<util.time_now.format>]> <&f>for:<&[emphasis]><[character]> <&f><[reason]> <&f>(now <&6><player.flag[character_cards.<[character]>.gold]> TG<&f>)"
    - flag <player> eco_shift_today:-:<[amount]>
    - if !<player.has_flag[eco_active]> && <player.flag[economy_history].size> > 3:
        - flag player eco_active
    - if <player.is_online>:
        - actionbar "<&c>- <[amount]> <&6>TG"
    - define message "] - `<player.name>`'s character `<[character].proc[discord_escape]>` LOST `<[amount]> TG` for reason `<[reason].proc[discord_escape]>` (now `<player.flag[character_cards.<[character]>.gold]> TG`)"
    - run eco_log_to_discord def:<list_single[<[message]>]>

eco_log_gain:
    type: task
    debug: false
    definitions: amount|reason|character
    script:
    - define character <[character].if_null[<player.flag[current_character]>]>
    - flag <player> "economy_history:->:<element[<&2>+ <[amount]> TG].on_hover[<util.time_now.format>]> <&f>for:<&[emphasis]><[character]> <&f><[reason]> <&f>(now <&6><player.flag[character_cards.<[character]>.gold]> TG<&f>)"
    - flag <player> eco_shift_today:+:<[amount]>
    - if !<player.has_flag[eco_active]> && <player.flag[economy_history].size> > 3:
        - flag player eco_active
    - if <player.is_online>:
        - actionbar "<&2>+ <[amount]> <&6>TG"
    - define message "] + `<player.name>`'s character `<[character].proc[discord_escape]>` GAINED `<[amount]> TG` for reason `<[reason].proc[discord_escape]>` (now `<player.flag[character_cards.<[character]>.gold]> TG`)"
    - run eco_log_to_discord def:<list_single[<[message]>]>

eco_log_set:
    type: task
    debug: false
    definitions: amount|reason|character
    script:
    - define character <[character].if_null[<player.flag[current_character]>]>
    - if !<[amount].is_integer||false>:
        - debug error "Invalid amount <[amount]> for eco log with reason <[reason]>"
        - stop
    - flag <player> "economy_history:->:<element[<&b>* SET TO <[amount]> TG].on_hover[<util.time_now.format>]> <&f>for:<&[emphasis]><[character]> <&f><[reason]>"
    - flag <player> eco_shift_today:!
    - if <player.is_online>:
        - actionbar "<&b>* <[amount]> <&6>TG"
    - define message "] `*` `<player.name>`'s character `<[character].proc[discord_escape]>` WAS RESET TO `<[amount]> TG` for reason `<[reason].proc[discord_escape]>`"
    - run eco_log_to_discord def:<list_single[<[message]>]>

eco_log_to_discord:
    type: task
    debug: false
    definitions: message
    script:
    - define message <[message].strip_color>
    - announce to_console "Economy log: <[message]>"
    - run discord_send_message def:<list[123].include_single[<[message]>]>

eco_endofday_handler:
    type: world
    debug: false
    events:
        on system time 01:00:
        - define total 0
        - foreach <server.players_flagged[eco_shift_today].filter[has_flag[eco_ignore].not]> as:target:
            - wait 1t
            - if <[target].flag[eco_shift_today]> > 0:
                - define message "] (Stats) `<[target].name>` had their balance INCREASE today by `<[target].flag[eco_shift_today]> TG`"
            - else if <[target].flag[eco_shift_today]> < 0:
                - define message "] (Stats) `<[target].name>` had their balance DECREASE today by `<[target].flag[eco_shift_today]> TG`"
            - else:
                - foreach next
            - define total:+:<[target].flag[eco_shift_today]>
            - flag <[target]> eco_shift_today:!
            - run eco_log_to_discord def:<list_single[<[message]>]>
        - foreach <server.flag[businesses].values.filter[contains[eco_ignore].not]> as:target:
            - wait 1t
            - if <[target].get[eco_shift_today]||0> > 0:
                - define message "] (Stats) **business** `<[target].get[name]>` had their balance INCREASE today by `<[target].get[eco_shift_today]> TG`"
            - else if <[target].get[eco_shift_today]||0> < 0:
                - define message "] (Stats) **business** `<[target].get[name]>` had their balance DECREASE today by `<[target].get[eco_shift_today]> TG`"
            - else:
                - foreach next
            - define total:+:<[target].get[eco_shift_today]||0>
            - flag server businesses.<[target].get[name].escaped>.eco_shift_today:!
            - run eco_log_to_discord def:<list_single[<[message]>]>
        - define message "] (Stats) Total economy shift today: `<[total]> TG`"
        - run eco_log_to_discord def:<list_single[<[message]>]>
        - run eco_log_to_discord def:<list_single[<&rb> (Stats) **Waymaker pseudo-business** economy shift: `<server.flag[businesses.waymaker.eco_shift_today]||0> TG`]>
        - run eco_log_to_discord def:<list_single[<&rb> (Stats) **Town_Rent pseudo-business** economy shift: `<server.flag[businesses.Town_Rent.eco_shift_today]||0> TG`]>
        - flag server businesses.waymaker.eco_shift_today:!
        - flag server businesses.Town_Rent.eco_shift_today:!

trade_gold_economy:
    type: economy
    data:
        wallet_max: <element[64].mul[100].mul[9]>
    debug: false
    priority: normal
    name single: Trade Gold
    name plural: Trade Gold
    digits: 0
    format: <[amount]> TG
    balance: <player.proc[eco_proc_get_coins].proc[eco_count_proc]||0>
    has: <player.money.is[or_more].than[<[amount]>]||false>
    withdraw:
    - if <player.flag[character_mode]> != ic:
        - debug error "<player.name> is not IC, cannot eco withdraw!"
        - stop
    - run money_take_task def.pair:<player.proc[cc_idpair]> def.amount:<[amount]>
    deposit:
    - if <player.flag[character_mode]> != ic:
        - debug error "<player.name> is not IC, cannot eco deposit!"
        - stop
    - run money_give_task def.pair:<player.proc[cc_idpair]> def.amount:<[amount]>
