
chat_local_emote_handler:
    type: task
    debug: false
    definitions: message|raw_message|text_color
    script:
    - if <player.flag[character_mode]> == ic:
        - define end_message <[raw_message].split[<&dq>]>
        - define message <[end_message].first>
        - foreach <[end_message].get[2].to[99999]||> as:bit:
            - if <[loop_index].mod[2]> == 0:
                - define message <[message]><&dq><[text_color]><&o><[bit]>
            - else:
                - define message <[message]><player.flag[chat_color]||<&f>><&dq><[bit]>
        - if <[raw_message].ends_with[<&dq>]>:
            - define message <[message]><&dq>

embedder_for_item:
    type: procedure
    debug: false
    definitions: item
    script:
    - define item_name <&[emphasis]>[<[item].book_title||<[item].display||<[item].material.translated_name>>><&[emphasis]>]
    - determine <[item_name].on_hover[<[item]>].type[show_item]>

founder_colors_data:
    type: data
    primary: <&color[#FFD662]>
    secondary: <&color[#72B3EC]>

embedder_for_character:
    type: procedure
    debug: false
    definitions: pair|alt_cmd
    script:
    - define __player <[pair].before[__]>
    - define character_name <[pair].after[__char__]>
    - define color <&[base]>
    - define emphcolor <&[emphasis]>
    - define prefix <empty>
    - if <player.in_group[founder]>:
        - define color <script[founder_colors_data].parsed_key[primary]>
        - define emphcolor <script[founder_colors_data].parsed_key[secondary]>
        - define prefix "<bold>[Founder] "
    - define character <player.flag[character_cards.<[character_name]>]>
    - define card_desc <[character.description]||None.>
    - define card_desc <[card_desc].separated_by[<n>].split_lines_by_width[300]>
    - if <[card_desc].length> > 250:
        - define card_desc <[card_desc].substring[1,200]>...
    - define hover_text "<[color]>Name: <[emphcolor]><[character.name]><n><[color]>Species: <[emphcolor]><[character.species]> (<[character.culture]>)<n><[color]>Age: <[emphcolor]><[character.age]><n><[color]>Description: <[emphcolor]><[card_desc]>"
    - if !<[character].contains[verified]>:
        - define hover_text "<[hover_text]><n><&[warning]>(Not Yet Verified)"
    - define alt_cmd <[alt_cmd].if_null[/cc view <player.name>:<[character_name]>]>
    - determine <[character.name].color[<[emphcolor]>].on_hover[<[hover_text]>].on_click[<[alt_cmd]>]>

emojify_proc:
    type: procedure
    debug: false
    definitions: name
    data:
        waymaker: a
        adventurous: b
        agree: c
        angery: d
        gold_star: e
        lol: f
        love: g
        sad: h
        surprise: i
        dracry: j
        disgust: k
        grapeeyes: l
        napple: m
        owona: n
        rage: o
        salsatime: p
        uwuna: q
        mcmonkey: r
        pride: s
        pengu: t
        clown: u
        harold: v
        nitro: w
        knife: x
        discord: y
        haroldjar: z
        kingharold: 1
        sailorharold: 2
        warriorharold: 3
        initiative: 4
        darroway: 5
        danary: 6
    script:
    - define res <script.data_key[data.<[name]>].color[white].on_hover[:<[name]>:].font[waymaker:waymaker].if_null[null]>
    - if <[res]> == null:
        - determine null
    - determine <[res]>

chat_emoji_handler:
    type: procedure
    debug: false
    definitions: message
    script:
    - define split <[message].split[:].limit[3]>
    - if <[split].size> != 3:
        - determine <[message]>
    - define emoji <[split].get[2].escaped.proc[emojify_proc]>
    - if <[emoji]> == null:
        - determine <[split].get[1]>:<[split].get[2]>:<[split].get[3].proc[chat_emoji_handler]>
    - determine <[split].get[1]><[emoji].font[waymaker:waymaker]><[split].get[3].proc[chat_emoji_handler]>

chat_embed_handler:
    type: procedure
    debug: false
    definitions: message
    script:
    - define split <[message].split[<&lb><&lb>].limit[2]>
    - if <[split].size> == 1:
        - determine <[message]>
    - define split_two <[split].get[2].split[<&rb><&rb>].limit[2]>
    - if <[split_two].size> == 1:
        - determine <[message]>
    - define replace <empty>
    - define pair <[split_two].get[1].split[:].limit[2]>
    - choose <[pair].get[1]>:
        - case item:
            - if <[pair].size> == 2:
                - if ( <[pair].get[2].is_integer> && <[pair].get[2]> >= 1 && <[pair].get[2]> <= 41 ) || <[pair].get[2]> == offhand:
                    - define replace <player.inventory.slot[<[pair].get[2]>].proc[embedder_for_item]>
                - foreach <player.inventory.list_contents> as:item:
                    - if <[item].material.name.contains_text[<[pair].get[2]>]> || <[item].display.strip_color.contains_text[<[pair].get[2]>]||false>:
                        - define replace <[item].proc[embedder_for_item]>
                        - foreach stop
                - foreach <player.enderchest.list_contents> as:item:
                    - if <[item].material.name.contains_text[<[pair].get[2]>]> || <[item].display.strip_color.contains_text[<[pair].get[2]>]||false>:
                        - define replace <[item].proc[embedder_for_item]>
                        - foreach stop
        - case i helditem:
            - define replace <player.item_in_hand.proc[embedder_for_item]>
        - case c character:
            - if <[pair].size> == 2:
                - define search <[pair].get[2]>
                - define character <proc[characters_list_proc].filter[contains[<[search].proc[cc_escape]>]].first||>
                - if <[character].length> > 0 && <player.has_flag[character_cards.<[character]>]>:
                    - define replace <player.proc[cc_idpair].context[<[character]>].proc[embedder_for_character]>
                - else:
                    - define sub_split <[pair].get[2].split[:].limit[2]>
                    - define player <server.match_offline_player[<[sub_split].get[1]>]||null>
                    - if <[player]> != null:
                        - if <[sub_split].size> == 2:
                            - define search <[sub_split].get[2]>
                            - define character <proc[characters_list_proc].context[<[player]>].filter[contains[<[search].proc[cc_escape]>]].first||>
                            - if <[character].length> > 0 && <[player].has_flag[character_cards.<[character]>]>:
                                - define replace <[player].proc[cc_idpair].context[<[character]>].proc[embedder_for_character]>
                        - else if <[player].has_flag[current_character]>:
                            - define character <[player].flag[current_character]>
                            - if <[player].has_flag[character_cards.<[character]>]>:
                                - define replace <[player].proc[cc_idpair].context[<[character]>].proc[embedder_for_character]>
                        - else:
                            - define replace <[player].flag[nickname].if_null[<[player].name>].color[<&[emphasis]>]>
            - else:
                - if <player.has_flag[current_character]>:
                    - define character <player.flag[current_character]>
                    - if <player.has_flag[character_cards.<[character]>]>:
                        - define replace <player.proc[cc_idpair].context[<[character]>].proc[embedder_for_character]>
        - case spell ability:
            - if <[pair].size> == 2:
                - define ability_name <[pair].get[2].escaped>
                - if <server.has_flag[abilities.<[ability_name]>]>:
                    - define replace <[ability_name].proc[embedder_for_ability]>
                - else:
                    - foreach <server.flag[abilities]> as:ability key:out_ability_name:
                        - if <[ability].get[name].strip_color.contains_text[<[ability_name]>]>:
                            - define replace <[out_ability_name].proc[embedder_for_ability]>
                            - foreach stop
        - default:
            - define search_name <[pair].get[1].escaped>
            - if <[search_name].trim.length> > 2 && !<[search_name].starts_with[<&sp>]>:
                - foreach <player.flag[character_cards].keys> as:character:
                    - if <[character].contains[<[search_name]>]>:
                        - define replace <player.proc[cc_idpair].context[<[character]>].proc[embedder_for_character]>
                        - foreach stop
                - if <[replace].length> == 0:
                    - foreach <player.inventory.list_contents> as:item:
                        - if <[item].material.name.contains_text[<[search_name]>]> || <[item].display.strip_color.contains_text[<[search_name]>]||false>:
                            - define replace <[item].proc[embedder_for_item]>
                            - foreach stop
                - if <[replace].length> == 0:
                    - foreach <server.flag[abilities]> as:ability key:out_ability_name:
                        - if <[ability].get[name].strip_color.contains_text[<[search_name]>]>:
                            - define replace <[out_ability_name].proc[embedder_for_ability]>
                            - foreach stop
    - if <[replace].length> == 0:
        - determine <[split].get[1]>[[<[split_two].get[1]>]]<[split_two].get[2].proc[chat_embed_handler]>
    - determine <[split].get[1]><[replace]><[split_two].get[2].proc[chat_embed_handler]>
