player_interaction_world:
    type: world
    debug: false
    events:
        after player right clicks player:
        - ratelimit <player> 2t
        - announce to_console "[PlayerInteract] <player.name> interacts with <context.entity.name>"
        - flag player interact_with:<context.entity>
        - inventory open d:player_interaction_gui
        - waituntil rate:0.5s max:1m <player.open_inventory.script.name||null> != player_interaction_gui || !<player.is_online> || !<player.flag[interact_with].is_online> || <player.flag[interact_with].location.world.name> != <player.location.world.name> || <player.flag[interact_with].location.distance[<player.location>]> > 50
        - inventory close
        - flag player interact_with:!
        after player clicks player_interaction_gui_kiss in player_interaction_gui flagged:interact_with:
        - inventory close
        - execute as_player "kiss [[character:<player.flag[interact_with].name>]]"
        after player clicks player_interaction_gui_spit in player_interaction_gui flagged:interact_with:
        - inventory close
        - execute as_player "spit at [[character:<player.flag[interact_with].name>]]"
        after player clicks player_interaction_gui_view_cc in player_interaction_gui flagged:interact_with:
        - inventory close
        - execute as_player "charactercard view <player.flag[interact_with].name>"
        after player clicks player_interaction_gui_poke in player_interaction_gui flagged:interact_with:
        - if !<player.flag[interact_with].is_online||false>:
            - stop
        - inventory close
        - execute as_player "poke <player.flag[interact_with].name>"

proc_interact_gui_autoname:
    type: procedure
    debug: false
    script:
    - determine <proc[proc_format_name].context[<player.flag[interact_with]||server>|<player||server>]||Unknown><&7>

proc_interaction_charcard_lore:
    type: procedure
    debug: false
    script:
    - if !<player.has_flag[interact_with]>:
        - determine <list>
    - define target <player.flag[interact_with]>
    - define list <list>
    - define list:|:<element[<&7>Click to view <[target].proc[proc_base_name_color].context[<player>]><[target].name><&7><&sq>s full current character card.].split_lines_by_width[300].lines_to_colored_list>
    - if !<[target].has_flag[current_character]>:
        - determine <[list]>
    - define target_card <[target].flag[current_character]>
    - define details <[target].flag[character_cards.<[target_card]>]>
    - define color <&[base]>
    - define emphcolor <&[emphasis]>
    - define prefix <empty>
    - if <[target].in_group[founder]>:
        - define color <script[founder_colors_data].parsed_key[primary]>
        - define emphcolor <script[founder_colors_data].parsed_key[secondary]>
    - define "list:->:<[color]>Name: <[emphcolor]><[details.name]>"
    - define "list:->:<[color]>Species: <[emphcolor]><[details.species]> (<[details.culture]>)"
    - define "list:->:<[color]>Age: <[emphcolor]><[details.age]>"
    - define description "<[color]>Description: <[emphcolor]><[details.description].separated_by[<n>].trim>"
    - if <[description].length> > 300:
        - define description <[description].substring[1,260]>...
    - define description <[description].split_lines_by_width[250].lines_to_colored_list>
    - define list:|:<[description]>
    - determine <[list]>

player_interaction_gui_view_cc:
    type: item
    debug: false
    material: player_head
    display name: <&[base]>View Character Card
    mechanisms:
        lore: <proc[proc_interaction_charcard_lore]>
        skull_skin: <player.flag[interact_with].uuid||>|<player.flag[interact_with].skin_blob.before[;]||steve>|<player.flag[interact_with].name||>

player_interaction_gui_ooc:
    type: item
    debug: false
    material: barrier
    display name: <&[base]>OOC
    lore:
    - <&7>Player is <element[Out Of Character].bold> currently.

player_interaction_gui_poke:
    type: item
    debug: false
    material: book[custom_model_data=100004]
    display name: <&[base]>Poke
    lore:
    - <&7>Poke <proc[proc_interact_gui_autoname]>
    - <&7>to get their attention.

player_interaction_gui_kiss:
    type: item
    debug: false
    material: book[custom_model_data=100002]
    display name: <&[base]>Kiss
    lore:
    - <&7>Kiss <proc[proc_interact_gui_autoname]>

player_interaction_gui_spit:
    type: item
    debug: false
    material: book[custom_model_data=100003]
    display name: <&[base]>Spit At
    lore:
    - <&7>Spit At <proc[proc_interact_gui_autoname]>

player_interaction_gui_coming_soon:
    type: item
    debug: false
    material: barrier
    display name: <&[base]>MORE COMING SOON
    lore:
    - <&7>We'll have more interactions
    - <&7>available in this menu soon!


player_interaction_gui:
    type: inventory
    debug: false
    gui: true
    inventory: chest
    title: <&f><&font[waymaker:gui]>-b=<&font[minecraft:default]><&7><proc[proc_interact_gui_autoname]>
    definitions:
        helmet: <player.flag[interact_with].equipment_map.get[helmet]||air>
        chestplate: <player.flag[interact_with].equipment_map.get[chestplate]||air>
        leggings: <player.flag[interact_with].equipment_map.get[leggings]||air>
        boots: <player.flag[interact_with].equipment_map.get[boots]||air>
        offhand: <player.flag[interact_with].item_in_offhand||air>
        hand: <player.flag[interact_with].item_in_hand||air>
        char_card: <player.flag[interact_with].has_flag[current_character].if_null[false].if_true[player_interaction_gui_view_cc].if_false[player_interaction_gui_ooc]>
    slots:
    - [] [] [] [] [] [] [] [] []
    - [] [player_interaction_gui_poke] [] [] [] [] [] [helmet] []
    - [] [player_interaction_gui_kiss] [] [] [char_card] [] [offhand] [chestplate] [hand]
    - [] [player_interaction_gui_spit] [] [] [] [] [] [leggings] []
    - [] [] [] [] [] [] [] [boots] []
    - [] [] [] [] [] [] [] [] []
