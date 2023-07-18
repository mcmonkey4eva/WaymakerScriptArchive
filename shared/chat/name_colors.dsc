proc_base_name_color:
    type: procedure
    debug: false
    definitions: player|for_player
    script:
    - if <[for_player].has_flag[altnamecolor.default]||false> && <[for_player].has_flag[can_use_altnamecolor]||false>:
        - define color <&color[<[for_player].flag[altnamecolor.default]>]>
    - else:
        - define color <&color[#dddddd]>
    - if <[player].has_flag[personal_name_color]> && <[player].uuid> == <[for_player].uuid||null>:
        - define color <[player].flag[personal_name_color]>
    - else if <[for_player].has_flag[altnamecolor.player.<[player].uuid>]||false> && <[for_player].has_flag[can_use_playernamecolor]||false>:
        - define color <&color[<[for_player].flag[altnamecolor.player.<[player].uuid>]>]>
    - else if <[for_player].has_flag[friends.current.<[player].uuid||null>]||false>:
        - if <[for_player].has_flag[altnamecolor.friend]> && <[for_player].has_flag[can_use_altnamecolor]>:
            - define color <&color[<[for_player].flag[altnamecolor.friend]>]>
        - else:
            - define color <&color[#FFB563]>
    - else if <[player].in_group[staff]>:
        - define color <&color[#AE56FF]>
    #- else if <[player].in_group[trainee]>:
    #    - define color <&color[#D26DDf]>
    - else if <[player].in_group[donator_one]>:
        - define color <&color[#30b99a]>
    - else if <[player].in_group[donator_two]>:
        - define color <&color[#42e7bf]>
    - determine <[color]>

proc_name_color:
    type: procedure
    debug: false
    definitions: player|for_player
    script:
    - define player <[player]||<player>>
    - define color <proc[proc_base_name_color].context[<[player]>|<[for_player]||server>]>
    - define symbol <empty>
    - if <[player].has_flag[turn_system_current]>:
        - if <[player].has_flag[turn_system_color]>:
            - define symbol <[player].flag[turn_system_color]><element[4].font[waymaker:waymaker].on_hover[<&f>In An Initiative Encounter]>
        - else:
            - define symbol <&f><element[4].font[waymaker:waymaker].on_hover[<&f>In An Initiative Encounter<n><&f>Use <&[warning]>/init color<&f> to set your team color.]>
    - if <[for_player].has_flag[friends.current.<[player].uuid||null>]||false>:
        - define symbol <[symbol]><[color]><element[❤].on_hover[<&color[#FFB563]>Friend]>
    - if <[player].in_group[booster]>:
        - define symbol <[symbol]><&f><element[w].font[waymaker:waymaker].on_hover[<&f>Discord Nitro Booster]>
    - if <[player].in_group[founder]>:
        - define symbol <[symbol]><[color]><element[✦].on_hover[<&f>Founder]>
    - if <[player].in_group[staff]>:
        - define symbol <[symbol]><&color[#AE56FF]><element[❁].on_hover[<&color[#AE56FF]>Staff]>
    - if <[symbol].length> == 0:
        - determine <[color]>
    - determine "<[symbol]><[color]> "

name_color_world:
    type: world
    debug: false
    events:
        on player joins:
        - run name_plate_cleanup
        - team name:<player.uuid.replace_text[-].substring[1,16]> remove:<player.name>
        - team name:<player.uuid.replace_text[-].substring[1,16]> add:<player.name> option:name_tag_visibility status:never
        - team name:<player.uuid.replace_text[-].substring[1,16]> option:collision_rule status:never
        - team name:<player.uuid.replace_text[-].substring[1,16]> option:see_invisible status:always
        - wait 1t
        - run name_suffix_character_card
        on player quits:
        - chunkload <player.location.chunk> duration:2t
        - run name_plate_cleanup
        - rename t:<player> per_player cancel
        - team name:<player.uuid.replace_text[-].substring[1,16]> remove:<player.name>
        on player_name_stand_helper damaged:
        - determine cancelled
        on player death:
        - run name_plate_cleanup
        on player respawns:
        - run name_plate_cleanup
        - ratelimit <player> 15
        - wait 5t
        - run name_suffix_character_card
        on player teleports:
        - run name_plate_cleanup
        - ratelimit <player> 1t
        - wait 5t
        - run name_suffix_character_card
        after player starts sneaking flagged:name_marker:
        - if <player.flag[name_marker].filter[is_spawned].any||false>:
            - sneak <player.flag[name_marker]> fake
        after player stops sneaking flagged:name_marker:
        - if <player.flag[name_marker].filter[is_spawned].any||false>:
            - sneak <player.flag[name_marker]> stopfake
        on delta time secondly every:15:
        - foreach <server.online_players> as:player:
            - if <[player].has_flag[name_marker]> && <[player].flag[name_marker].filter[is_spawned.not].any||true>:
                - announce to_console "Fix name of <[player].name>"
                - run name_suffix_character_card player:<[player]>
                - wait 2t
        after server start:
        - wait 10t
        - run nameplate_cleanup_task
        - wait 1m
        - run nameplate_cleanup_task
        - wait 5m
        - run nameplate_cleanup_task
        on delta time minutely every:20:
        - run nameplate_cleanup_task
        after player_name_stand_helper added to world:
        - if <context.entity.has_flag[name_for]>:
            - if <context.entity.flag[name_for].flag[name_marker].filter[uuid.equals[<context.entity.uuid>]].is_empty||true>:
                - debug log "(NamePlate Fix) plate entity <context.entity> added to <context.location> but was invalid, removing"
                - debug log "said was for <context.entity.flag[name_for]>/<context.entity.flag[name_for].name> but that player has <context.entity.flag[name_for].flag[name_marker]||Invalid>"
                - remove <context.entity>
        on chunk loads entities entity_type:player_name_stand_helper:
        - define relevant <context.entities.filter[advanced_matches[player_name_stand_helper]]>
        - debug log "(NamePlate Fix) plate entities <[relevant]> loaded from datastore into <context.chunk>, removing"
        - remove <[relevant]>

nameplate_cleanup_task:
    type: task
    debug: false
    script:
    - foreach <server.worlds> as:world:
        - foreach <[world].entities[player_name_stand_helper]> as:stand:
            - if !<[stand].flag[name_for].is_online||false> || <[stand].flag[name_for].flag[name_marker].filter[uuid.equals[<[stand].uuid>]].is_empty||true>:
                - remove <[stand]>

nameplate_forcefix:
    type: command
    debug: false
    name: forcefixnames
    usage: /forcefixnames
    description: Staff command to forcibly fix nameplates real fast.
    permission: dscript.forcefixnames
    script:
    - inject nameplate_cleanup_task
    - foreach <server.online_players>:
        - run name_suffix_character_card player:<[value]>
        - wait 2t
    - narrate "<&[base]>Nameplates reset."

player_name_stand_helper:
    type: entity
    debug: false
    entity_type: armor_stand
    mechanisms:
        marker: true
        visible: false
        custom_name_visible: true
        invulnerable: true
        force_no_persist: true
        #tracking_range: 100

name_plate_cleanup:
    type: task
    debug: false
    script:
    - if <player.flag[name_marker].filter[is_spawned].any||false>:
        - foreach <player.flag[name_marker].filter[is_spawned]> as:marker:
            - rename cancel t:<[marker]> per_player
            - remove <[marker]>
    - flag player name_marker:!

character_name_proc:
    type: procedure
    debug: false
    script:
    - determine <player.flag[character_override]||<player.flag[current_character].proc[cc_name].proc[chat_emoji_handler]||>>

name_suffix_character_card:
    type: task
    debug: false
    script:
    - if <server.has_flag[is_roleplay_server]>:
        - define character <player.proc[character_name_proc]>
    - else:
        - define character <server.flag[alt_server_id]||Survival>
    - define suffix <empty>
    - if <[character].length> > 0:
        - define suffix "<tern[<player.has_flag[character_override]>].pass[<&8>].fail[<&7>]> (<[character]>)"
    - if <player.has_flag[auto_afk_mark]> && !<player.has_flag[marked_afk]>:
        - define suffix "<[suffix]> <&8>(AFK)"
    - run name_plate_cleanup
    - if !<player.is_online>:
        - stop
    - if <server.has_flag[is_roleplay_server]>:
        - run dynmap_should_hide_fix
        - if <player.world.name> == tutorial:
            - invisible <player> state:true
            - flag player tutorial_hidden
            - stop
        - else if <player.has_flag[tutorial_hidden]>:
            - invisible <player> state:false
            - flag player tutorial_hidden:!
            - wait 1t
    - run name_plate_cleanup
    - if !<player.is_online>:
        - stop
    - define player <player>
    - define name <proc[proc_name_color]><player.flag[nickname].if_null[<player.name>]><[suffix]>
    - rename t:<player> <proc[proc_name_color].context[<[player]>|<player>]><[player].flag[nickname].if_null[<[player].name>]><[suffix]> per_player list_name_only
    - adjust <player> player_list_name:<[name]>
    - if <player.has_flag[vanished]> || <player.has_flag[invisibility]> || <player.has_flag[disguise_hide_name]> || <player.gamemode> == spectator:
        - stop
    - define pos_start 1.8
    - if <player.has_flag[second_nameplate_text]>:
        - define pos_start <element[1.8].add[0.3]>
    - chunkload <player.location> duration:5t
    - definemap ent_name_data:
        force_no_persist: true
        custom_name: <[name]>
    - spawn <entity[player_name_stand_helper].with_map[<[ent_name_data]>]> <player.location.add[0,<[pos_start]>,0]> save:marker
    - if !<entry[marker].spawned_entity.is_spawned||false>:
        - stop
    - flag <entry[marker].spawned_entity> name_for:<player>
    - rename <proc[proc_name_color].context[<[player]>|<player>]><[player].flag[nickname].if_null[<[player].name>]><[suffix]> t:<entry[marker].spawned_entity> per_player
    - flag player name_marker:->:<entry[marker].spawned_entity>
    - if <player.has_flag[second_nameplate_text]>:
        - definemap ent_name_data:
            force_no_persist: true
            custom_name: <player.flag[second_nameplate_text]>
        - spawn <entity[player_name_stand_helper].with_map[<[ent_name_data]>]> <player.location.add[0,<[pos_start].sub[0.3]>,0]> save:marker2
        - flag <entry[marker2].spawned_entity> name_for:<player>
        - flag player name_marker:->:<entry[marker2].spawned_entity>
    #- wait 1t
    - if !<player.is_online>:
        - run name_plate_cleanup
        - stop
    - if !<player.has_flag[name_marker]>:
        - stop
    - if !<entry[marker].spawned_entity.is_spawned||false>:
        - stop
    - foreach <player.flag[name_marker]> as:marker:
        - if <player.has_flag[name_relative]>:
            - attach <[marker]> to:<player> offset:<player.flag[name_offset]||0,1.8,0> sync_server relative
        - else:
            - attach <[marker]> to:<player> offset:0,<[pos_start].sub[<[loop_index].sub[1].mul[0.3]>]>,0 sync_server
    #- wait 1t
    - if !<entry[marker].spawned_entity.is_spawned||false>:
        - stop
    - if <player.has_flag[name_marker]>:
        - foreach <player.flag[name_marker]> as:marker:
            - adjust <server.online_players_flagged[hidenameplates]> hide_entity:<[marker]>
            - adjust <player> hide_entity:<[marker]>
        - adjust <player.flag[name_marker]> marker:false
        - wait 1t
        - if !<entry[marker].spawned_entity.is_spawned||false>:
            - stop
        - if <player.has_flag[name_marker]>:
            - adjust <player.flag[name_marker]> marker:true
            #- adjust <player.flag[name_marker]> tracking_range:100

proc_safe_name:
    type: procedure
    debug: false
    definitions: player
    script:
    - define player <player[<[player]>]>
    - if <[player].name||null> == null:
        - determine <server.flag[bungee_player_backup.<[player].uuid>]||Error>
    - determine <[player].name>

proc_format_name:
    type: procedure
    debug: false
    definitions: player|for_player|fake_online
    script:
    # Note: '.font[minecraft:default]' is to force color containment
    - if <[player]||server> == server:
        - determine <element[Server].custom_color[emphasis].font[minecraft:default]>
    - define player <player[<[player]>]>
    - if <[player].name||null> == null:
        - determine <element[<proc[proc_name_color].context[<[player]>|<[for_player]||null>]><server.flag[bungee_player_backup.<[player].uuid>]||Error>].color[f].font[minecraft:default]> player:<[player]>
    - define fake_online <[fake_online]||false>
    - if ( <[fake_online]> || <[player].is_online> ) && !<[player].has_flag[vanished]>:
        - define character <[player].flag[character_override]||<[player].flag[current_character].proc[cc_name].context[<[player]>].proc[chat_emoji_handler]||>>
        - define suffix <empty>
        - if <[character].length> > 0:
            - define suffix "<tern[<[player].has_flag[character_override]>].pass[<&8>].fail[<&7>]> (<[character]>)"
        - if <[player].has_flag[auto_afk_mark]> && !<[player].has_flag[marked_afk]>:
            - define suffix "<[suffix]> <&8>(AFK)"
        - determine <element[<proc[proc_name_color].context[<[player]>|<[for_player]||null>]><player.name><[suffix]>].color[f].font[minecraft:default]> player:<[player]>
    - else:
        - determine <element[<player.name> <&[warning]>(Offline)].color[f].font[minecraft:default]> player:<[player]>

mycolor_command:
    type: command
    debug: false
    name: mycolor
    usage: /mycolor [color]
    description: Sets your own name color in chat, for only yourself to view.
    tab completions:
        1: <context.args.first.if_null[].proc[color_tabcomplete_proc]>
    permission: dscript.mycolor
    script:
    - if <context.args.is_empty> && <player.has_flag[personal_name_color]>:
        - narrate "<player.flag[personal_name_color]>Your name color is currently #<player.flag[personal_name_color].replace_text[<&ss>].replace_text[x]>"
        - stop
    - inject set_color_command_prevalidate
    - if <[color]> == reset:
        - flag player personal_name_color_tried
        - flag player personal_name_color:!
        - narrate "<&[base]>Personal color reset."
        - stop
    - flag player personal_name_color:<&color[<[color]>]||Error>
    - narrate "<player.flag[personal_name_color]>Color set to this."
    - wait 1t
    - run name_suffix_character_card
