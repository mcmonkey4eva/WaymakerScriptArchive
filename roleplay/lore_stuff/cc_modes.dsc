
cc_set_mode:
    type: task
    debug: false
    definitions: mode|name
    script:
    - if <player.flag[character_mode]> == <[mode]>:
        - if <[mode]> != ic || <[name]> == <player.flag[current_character]>:
            - debug log "[cc_set_mode] player '<player.name>' tried to swap <[mode]> / <[name]||none>, but was already in that state"
            - stop
    # Store and de-init prior mode
    - choose <player.flag[character_mode]>:
        - case ooc:
            - define inv_flag character_alt_inv.ooc
        - case working:
            - define inv_flag character_alt_inv.creative
        - case spectator:
            - define inv_flag character_alt_inv.spectator
        - case ic:
            - define current <player.flag[current_character]>
            - define inv_flag character_cards.<[current]>.inventory
            - flag player character_cards.<[current]>.location:<player.location>
            - flag player character_cards.<[current]>.last_used:<util.time_now>
            - narrate "<&[base]>You're switching out of character <&[emphasis]><[current].proc[cc_name]><&[base]>. Your location/inventory/etc. are recorded for when you swap back."
    - run inventory_history_task
    - flag player <[inv_flag]>:<player.inventory.map_slots>
    - inventory clear d:<player.inventory>
    # Enable new mode
    - flag player character_mode:<[mode]>
    - flag player current_character:!
    - choose <[mode]>:
        - case ooc:
            - define gamemode survival
            - define inv_flag character_alt_inv.ooc
            - flag player character_override:OOC
        - case working:
            - define gamemode creative
            - define inv_flag character_alt_inv.creative
            - flag player character_override:Working
        - case spectator:
            - define gamemode spectator
            - define inv_flag character_alt_inv.spectator
            - flag player character_override:Working
        - case ic:
            - define gamemode survival
            - flag player current_character:<[name]>
            - define inv_flag character_cards.<[name]>.inventory
            - flag player character_override:!
            - teleport <player> <proc[cc_flag].context[location]||<player.location>>
            - run cc_refresh_attributes
    - if <player.gamemode> != <[gamemode]>:
        - adjust <player> gamemode:<[gamemode]>
    - inventory set d:<player.inventory> o:<player.flag[<[inv_flag]>]||<map>>
    - run characters_skin_update
    - run name_suffix_character_card

characters_ooc_command:
    type: command
    debug: false
    name: ooc
    usage: /ooc
    description: Swaps you to Out-Of-Character mode.
    script:
    - if <player.flag[character_mode]> == ooc:
        - narrate "<&[error]>You are already out-of-character."
        - stop
    - run cc_set_mode def.mode:ooc
    - narrate "<&[base]>You are now marked as Out-Of-Character."

characters_ic_command:
    type: command
    debug: false
    name: ic
    usage: /ic (character)
    description: Swaps you to In-Character mode.
    tab completions:
        1: <proc[characters_list_proc]>
    script:
    - execute as_player "cc swap <context.raw_args>"

characters_working_command:
    type: command
    debug: false
    name: working
    usage: /working
    description: Swaps you to Staff Working mode (creative).
    permission: dscript.staff_working_card
    script:
    - if <player.flag[character_mode]> == working:
        - narrate "<&[error]>You are already working."
        - stop
    - run cc_set_mode def.mode:working
    - narrate "<&[base]>You are now marked as working."

characters_spectator_command:
    type: command
    debug: false
    name: spectator
    usage: /spectator
    description: Swaps you to Staff Working mode (spectator).
    permission: dscript.staff_working_card
    script:
    - if <player.flag[character_mode]> == spectator:
        - narrate "<&[error]>You are already a spectator."
        - stop
    - run cc_set_mode def.mode:spectator
    - narrate "<&[base]>You are now a spectator."

characters_afk_command:
    type: command
    debug: false
    name: afk
    usage: /afk
    description: Sets you as manually AFK or not.
    script:
    - if <player.has_flag[marked_afk]>:
        - run characters_unafk_task
        - narrate "<&[base]>No longer AFK."
    - else:
        - flag player marked_afk
        - flag player character_override:AFK
        - run name_suffix_character_card
        - narrate "<&[base]>Marked AFK."

characters_unafk_task:
    type: task
    debug: false
    script:
    - if !<player.has_flag[marked_afk]>:
        - stop
    - flag player marked_afk:!
    - if <player.flag[character_mode]> == ooc:
        - flag player character_override:OOC
    - else if <player.flag[character_mode]> in working|spectator:
        - flag player character_override:Working
    - else:
        - flag player character_override:!
    - run name_suffix_character_card

cc_proc_maxhealth:
    type: procedure
    debug: false
    definitions: pair
    script:
    - determine <[pair].proc[cc_flag].context[stats.vitality].mul[4].add[20]>

cc_refresh_attributes:
    type: task
    debug: false
    script:
    - adjust <player> max_health:<player.proc[cc_idpair].proc[cc_proc_maxhealth]>
    - if !<proc[cc_has_flag].context[finalized]>:
        - run cc_set_flag def.pair:<player.proc[cc_idpair]> def.flag:health def.value:<player.health_max>
    - define health <proc[cc_flag].context[health]||<player.health_max>>
    - if <[health]> < 0.1:
        - define health 0.1
        - cast blindness duration:2h no_ambient hide_particles no_icon
        - cast slow duration:2h no_ambient hide_particles no_icon
    - else:
        - cast blindness remove
        - cast slow remove
    - adjust <player> health:<[health]>
    - adjust <player> food_level:20

cc_health_modify:
    type: task
    debug: false
    definitions: amount|pair
    script:
    - if <[pair].exists>:
        - define __player <[pair].before[__char__]>
    - else:
        - if <player.flag[character_mode]> != IC:
            - debug error "Tried to modify character health of <player.name> while not IC by <[amount]>"
            - stop
        - define pair <player.proc[cc_idpair]>
    - define max <[pair].proc[cc_proc_maxhealth]>
    - define health <[pair].proc[cc_flag].context[health]>
    - define new_health <[health].add[<[amount]>].max[0].min[<[max]>]>
    - debug log "[CC Health] <player.name> character <[pair].after[__char__]> change by <[amount]> from <[health]> to <[new_health]>"
    - run cc_set_flag def.pair:<[pair]> def.flag:health def.value:<[new_health]>
    - if <[new_health]> > <[health]>:
        - actionbar "<green>Your health raises by <[amount].custom_color[emphasis]> to <[new_health].custom_color[emphasis]>/<[max].custom_color[emphasis]>"
    - else if <[new_health]> < <[health]>:
        - if <[new_health]> < 0.1:
            - narrate "<&[base]>You have been knocked down! You may not participate in combat, and you will need to be brought to medical treatment."
        - actionbar "<red>Your health drops by <[amount].custom_color[emphasis]> to <[new_health].custom_color[emphasis]>/<[max].custom_color[emphasis]>"
    - run cc_refresh_attributes

character_card_world:
    type: world
    debug: false
    events:
        on player deep sleeps:
        - determine cancelled
        on delta time secondly:
        - foreach <server.online_players.filter[is_sleeping].filter[flag[character_mode].equals[ic]]> as:__player:
            - flag player sleep_seconds:++
            - if <player.flag[sleep_seconds]> > 60:
                - run cc_health_modify def:1
                - flag player sleep_seconds:!
        on player heals:
        - determine passively cancelled
        on player damaged:
        - determine passively cancelled
        on player changes food level:
        - determine passively cancelled
        on player joins priority:-100:
        - if <player.flag[character_override]||null> == AFK:
            - run characters_unafk_task
        - if !<player.has_flag[character_mode]>:
            - flag player character_mode:ooc
            - flag player character_override:OOC
        - if <player.flag[character_mode]> == ic:
            - flag player character_cards.<player.flag[current_character]>.last_used:<util.time_now>
        - flag player marked_afk:!
        - flag player monitor_afk:!
        - flag player auto_afk_mark:!
        - flag player had_cc_skin:!
        after player respawns:
        - if <player.flag[character_mode]> == ic:
            - run cc_refresh_attributes
        after player joins:
        - wait 10t
        - run characters_skin_update
        - if <player.flag[character_mode]> == ic:
            - run cc_refresh_attributes
        on delta time minutely:
        - foreach <server.online_players.filter[has_flag[auto_afk_mark].not].filter[has_flag[monitor_afk].not]> as:player:
            - wait 1t
            - if <[player].is_online> && !<[player].has_flag[auto_afk_mark]>:
                - if <[player].location.simple> == <[player].flag[afk_monitor_loc]||none>:
                    - flag <[player]> monitor_afk:<util.time_now>
                - else:
                    - flag <[player]> afk_monitor_loc:<[player].location.simple>
        - foreach <server.online_players_flagged[monitor_afk].filter[has_flag[auto_afk_mark].not]> as:player:
            - wait 1t
            - if <[player].is_online>:
                - if <[player].flag[monitor_afk].from_now.in_minutes||0> > 15:
                    - flag <[player]> auto_afk_mark
                    - announce to_console "Auto-AFK <[player].name>"
                    - run name_suffix_character_card player:<[player]>
        on player walks flagged:monitor_afk priority:-100:
        - flag player monitor_afk:!
        - if <player.has_flag[auto_afk_mark]>:
            - inject auto_afk_unmark
        on player chats flagged:monitor_afk priority:-100:
        - flag player monitor_afk:!
        - if <player.has_flag[auto_afk_mark]>:
            - inject auto_afk_unmark
        on command flagged:monitor_afk priority:-100:
        - if <player||null> == null:
            - stop
        - flag player monitor_afk:!
        - if <player.has_flag[auto_afk_mark]>:
            - inject auto_afk_unmark

auto_afk_unmark:
    type: task
    debug: false
    script:
    - flag player auto_afk_mark:!
    - wait 1t
    - announce to_console "Auto-un-afk <player.name>"
    - run name_suffix_character_card
