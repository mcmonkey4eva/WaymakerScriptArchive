
characters_list_proc:
    type: procedure
    debug: false
    definitions: player
    script:
    - define player <[player]||<player>>
    - determine <[player].flag[character_cards].keys.exclude[event]||<list>>

cc_list_char_datas:
    type: procedure
    debug: false
    definitions: player
    script:
    - define player <[player]||<player>>
    - determine <[player].flag[character_cards].get_subset[<[player].proc[characters_list_proc]>].values||<list>>

cc_idpair:
    type: procedure
    debug: false
    definitions: player|character
    script:
    - if !<[player].exists>:
        - define <[player]> <player>
    - if <[character].exists>:
        - determine <[player].uuid>__char__<[character]>
    - if <[player].flag[character_mode]> != ic:
        - debug error "CC_IDPAIR CALLED NON-IC"
        - stop
    - determine <[player].uuid>__char__<[player].flag[current_character]>

cc_has_flag:
    type: procedure
    debug: false
    definitions: flag_name|f2
    script:
    - if <[f2].exists>:
        - define __player <[flag_name]>
        - define flag_name <[f2]>
    - if <player.flag[character_mode]> != ic:
        - determine false
    - define current <player.flag[current_character]>
    - if !<player.has_flag[character_cards.<[current]>.<[flag_name]>]>:
        - determine false
    - determine true

cc_flag:
    type: procedure
    debug: false
    definitions: flag_name|f2
    script:
    - if <[f2].exists>:
        - define pair <[flag_name]>
        - define flag_name <[f2]>
        - if <[pair].contains_text[__char__]>:
            - define __player <[pair].before[__]>
            - define current <[pair].after[__char__]>
        - else:
            - define __player <[pair]>
            - if <player.flag[character_mode]> != ic:
                - stop
            - define current <player.flag[current_character]>
    - else:
        - if <player.flag[character_mode]> != ic:
            - stop
        - define current <player.flag[current_character]>
    - if !<player.has_flag[character_cards.<[current]>.<[flag_name]>]>:
        - stop
    - determine <player.flag[character_cards.<[current]>.<[flag_name]>]>

cc_format_idpair:
    type: procedure
    debug: false
    definitions: pair|player
    script:
    - define pl <[pair].before[__]>
    - define char <[pair].after[__char__]>
    - define char_name <[pl].as[player].flag[character_cards.<[char]>.name]||Unknown>
    - determine <element[<[pl].as[player].proc[proc_format_name].context[<[player]||<list>>]>'s character <[char_name]>].custom_color[base].font[minecraft:default]>

cc_rem_flag:
    type: task
    debug: false
    definitions: pair|flag
    script:
    - define __player <[pair].before[__]>
    - define char <[pair].after[__char__]>
    - flag <player> character_cards.<[char]>.<[flag]>:!

cc_set_flag:
    type: task
    debug: false
    definitions: pair|flag|value
    script:
    - define __player <[pair].before[__]>
    - define char <[pair].after[__char__]>
    - flag <player> character_cards.<[char]>.<[flag]>:<[value]>

cc_exclude_flag:
    type: task
    debug: false
    definitions: pair|flag|value
    script:
    - define __player <[pair].before[__]>
    - define char <[pair].after[__char__]>
    - flag <player> character_cards.<[char]>.<[flag]>:<-:<[value]>

cc_include_flag:
    type: task
    debug: false
    definitions: pair|flag|value
    script:
    - define __player <[pair].before[__]>
    - define char <[pair].after[__char__]>
    - flag <player> character_cards.<[char]>.<[flag]>:->:<[value]>

cc_escape:
    type: procedure
    debug: false
    definitions: name
    script:
    - determine <[name].replace_text[regex:[^a-zA-Z0-9]].with[_]>

cc_name:
    type: procedure
    debug: false
    definitions: character|player
    script:
    - if !<[player].exists>:
        - define player <player||null>
    - if <[character].contains_text[-]> && <[character].contains_text[__char__]>:
        - define player <[character].before[__].as[player]>
        - define character <[character].after[__char__]>
    - if <[player].has_flag[character_cards.<[character]>.name]>:
        - determine <[player].flag[character_cards.<[character]>.name]>
