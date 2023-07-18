disguise_command:
    type: command
    debug: false
    aliases:
    - d
    - dis
    - disg
    permission: dscript.disguise
    name: disguise
    usage: /disguise [type/stop] [options]
    description: Disguises yourself as something.
    tab complete:
    - define last_arg <tern[<context.raw_args.ends_with[<&sp>]>].pass[].fail[<context.args.last||null>]>
    - if <context.raw_args.trim> == <empty> || ( <context.args.size> == 1 && !<context.raw_args.ends_with[<&sp>]> ):
        - define output <server.entity_types.filter_tag[<script[disguise_data].data_key[allowed_dead_types].contains[<[filter_value]>].or[<entity[<[filter_value]>].is_living||false>]>].filter_tag[<player.has_permission[dscript.disguise_as.<[filter_value]>]||true>].include[help|stop]>
    - else if <[last_arg].starts_with[color:]>:
        - if !<server.entity_types.contains[<context.args.get[1]>]>:
            - determine <list>
        - define type <entity[<context.args.get[1]>]||null>
        - if !<[type].is_living||false> || <[type].entity_type> == player:
            - determine <list>
        - if !<player.has_permission[dscript.disguise_as.<[type].entity_type>]>:
            - determine <list>
        - if <[type].entity_type> == tropical_fish:
            - determine <list>
        - if <[type].allowed_colors||null> == null:
            - determine <list>
        - define output <[type].allowed_colors.parse_tag[color:<[parse_value]>]>
    - else if <[last_arg].starts_with[player:]> && <player.has_permission[dscript.disguise_control]>:
        - define output <server.online_players.filter[has_flag[vanished].not].parse_tag[player:<[parse_value].name>]>
    - else:
        - define output <list[<tern[<player.has_permission[dscript.disguise_control]||true>].pass[age:baby|age:adult|size:|self:false|profession:|player:|color:|name:|sheared:|hidename:true|sitting:true|].fail[age:baby|age:adult|profession:|color:|name:|sheared:|self:false|sitting:true|]>]>
    - determine <[output].filter_tag[<[filter_value].starts_with[<[last_arg]>]||true>]>
    script:
    - if <context.args.is_empty>:
        - narrate "<&[error]>/disguise [type/stop] [options]"
        - narrate "<&[warning]>Use <&[error]>/disguise help [type] <&[warning]>for available options."
        - stop
    - if <context.args.first> == help:
        - if <context.args.size> == 1:
            - narrate "<&[error]>/disguise help [type]"
            - if <player.has_permission[dscript.disguise_control]>:
                - narrate "<&[error]>Global options: <&[warning]>self:true/false, name:[name], hidename:true/false, player:[name]"
            - stop
        - if !<server.entity_types.contains[<context.args.get[2]>]>:
            - narrate "<&[error]>Unknown entity type."
            - stop
        - define type <entity[<context.args.get[2]>]||null>
        - if !<[type].is_living||false> || <[type].entity_type> == player:
            - narrate "<&[error]>Unsupported entity type."
            - stop
        - if !<player.has_permission[dscript.disguise_as.<[type].entity_type>]>:
            - narrate "<&[error]>You are not authorized to disguise as that."
            - stop
        - narrate "<&[warning]>/disguise <[type].entity_type> name:[name]"
        - narrate "<&[warning]>/disguise <[type].entity_type> self:[true/false]"
        - narrate "<&[warning]>/disguise <[type].entity_type> age:[baby/adult]"
        - if <list[phantom|slime|magma_cube].contains[<[type].entity_type>]>:
            - narrate "<&[warning]>/disguise <[type].entity_type> size:[1-120]"
        - if <[type].entity_type> == villager:
            - narrate "<&[warning]>/disguise <[type].entity_type> profession:[profession]"
        - else if <[type].entity_type> == sheep:
            - narrate "<&[warning]>/disguise <[type].entity_type> sheared:[true/false]"
        - if <[type].allowed_colors||null> != null:
            - narrate "<&[warning]>/disguise <[type].entity_type> color:[color] <&7>where color is any of: <&[emphasis]><[type].allowed_colors.formatted.replace[,].with[<&7>,<&[emphasis]>]>"
        - if <[type].entity_type> == tropical_fish:
            - narrate "<&[warning]>Tropical_Fish color input format is Type,PatternColor,BodyColor"
        - stop
    - if <list[stop|end|cancel|remove|reset|none|disable|und|undisguise|undis|off].contains[<context.args.first>]>:
        - run undisguise_task
        - narrate "<&[base]>Disguised disabled."
        - stop
    - if !<server.entity_types.contains[<context.args.first>]>:
        - narrate "<&[error]>Unknown entity type."
        - stop
    - define type <entity[<context.args.first>]||null>
    #- if !<[type].is_living||false> || <[type].entity_type> == player:
    - if !<[type].is_living||false> && !<script[disguise_data].data_key[allowed_dead_types].contains[<[type].entity_type>]>:
        - narrate "<&[error]>Unsupported entity type."
        - stop
    - if <[type].entity_type> == player:
        - narrate "<&[error]>Unsupported entity type."
        - stop
    - if !<player.has_permission[dscript.disguise_as.<[type].entity_type>]>:
        - narrate "<&[error]>You are not authorized to disguise as that."
        - stop
    - flag <player> disguise_hide_name:!
    - flag <player> in_disguise
    - if <list[phantom|slime|magma_cube].contains[<[type].entity_type>]>:
        - adjust <[type]> size:2
    - define target <player>
    - define self true
    - define hide_name false
    - foreach <context.args.get[2].to[9999]||<list>> as:arg:
        - if !<[arg].contains[:]>:
            - narrate "<&[error]>Invalid entity options."
            - stop
        - choose <[arg].before[:]>:
            - case color style variant type:
                - if <[type].allowed_colors||null> == null:
                    - narrate "<&[error]>That entity type does not support colors."
                    - stop
                - define newcolor <[arg].after[:].replace_text[,].with[|]>
                - if <[type]> == tropical_fish:
                    - if <[newcolor].split[,].size> != 3:
                        - narrate "<&[error]>Invalid fish color."
                        - stop
                - else:
                    - if !<[type].allowed_colors.contains_text[<[newcolor]>]>:
                        - narrate "<&[error]>Invalid color."
                        - stop
                - if <[type].entity_type> == wolf:
                    - adjust def:type tame:true
                - adjust def:type color:<[newcolor]>
            - case name:
                - if <player.has_permission[dscript.disguise_control]>:
                    - adjust def:type custom_name:<[arg].after[:]>
            - case sheared:
                - if <[type].entity_type> != sheep:
                    - narrate "<&[error]>That entity type does not support professions."
                    - stop
                - adjust def:type sheared:<[arg].after[:]>
            - case age:
                - adjust def:type age:<[arg].after[:]>
            - case self showself viewself:
                - define self <[arg].after[:]>
            - case size scale:
                - if <player.has_permission[dscript.disguise_control]>:
                    - if !<list[phantom|slime|magma_cube].contains[<[type].entity_type>]>:
                        - narrate "<&[error]>That entity type does not support resizing."
                        - stop
                    - adjust def:type size:<[arg].after[:]>
            - case profession:
                - if <[type].entity_type> != villager:
                    - narrate "<&[error]>That entity type does not support professions."
                    - stop
                - adjust def:type profession:<[arg].after[:]>
            - case hidename:
                - if <player.has_permission[dscript.disguise_control]>:
                    - define hide_name <[arg].after[:]>
            - case sitting:
                - adjust def:type sitting:<[arg].after[:]>
            - case player:
                - if <player.has_permission[dscript.disguise_control]>:
                    - define target <server.match_player[<[arg].after[:]>]||null>
                    - if <[target]> == null:
                        - narrate "<&[error]>Invalid player."
                        - stop
            - default:
                - narrate "<&[error]>Invalid entity options."
                - stop
    - if <[self]>:
        - define players <list[<[target]>]>
        - flag <[target]> disguise_hide_self:!
    - else:
        - define players <list>
        - flag <[target]> disguise_hide_self
    - if <[hide_name]>:
        - flag <[target]> disguise_hide_name:true
    - if <[target].has_flag[vanished]>:
        - adjust <[target]> show_to_players
        - flag <[target]> vanished:!
        - narrate <&[base]>Unvanished! player:<[target]>
        - wait 1t
    - if !<[target].has_flag[disguise_hide_self]>:
        - team name:<[target].uuid.replace_text[-].substring[1,16]> option:see_invisible status:never
    - disguise <[target]> as:<[type]> global players:<[players]>
    - narrate "<&[base]>You are now disguised as a <&[emphasis]><[type].entity_type><&[base]>." targets:<[target]>
    - if <[target]> != <player>:
        - narrate "<&[base]>Disguised <proc[proc_format_name].context[<[target]>|<player>]> as a<&[base]> <&[emphasis]><[type].entity_type><&[base]>."
    - wait 1t
    - run name_suffix_character_card player:<[target]>

undisguise_command:
    type: command
    debug: false
    aliases:
    - und
    - undis
    - undisg
    - stopdis
    - stopdisguise
    permission: dscript.disguise
    name: undisguise
    usage: /undisguise (player)
    description: Removes your disguise.
    script:
    - define target <player>
    - if !<context.args.is_empty> && <player.has_permission[dscript.disguise_control]>:
        - define target <server.match_player[<context.args.first>]||null>
        - if <[target]> == null:
            - narrate "<&[error]>Invalid player."
            - stop
    - run undisguise_task player:<[target]>
    - narrate "<&[base]>Disguised disabled."
    - stop

undisguise_task:
    type: task
    debug: false
    script:
    - disguise <player> cancel global
    - flag <player> disguise_hide_name:!
    - flag <player> disguise_hide_self:!
    - flag <player> in_disguise:!
    - flag <player> ocelot_sitting:!
    - team name:<player.uuid.replace_text[-].substring[1,16]> option:see_invisible status:always
    - wait 1t
    - if <player.is_online>:
        - run name_suffix_character_card

disguise_helper_world:
    type: world
    debug: false
    events:
        on player changes world flagged:in_disguise:
        - run undisguise_task
        on player joins flagged:in_disguise:
        - flag <player> disguise_hide_name:!
        - flag <player> disguise_hide_self:!
        - flag <player> in_disguise:!
        on player quits flagged:in_disguise:
        - run undisguise_task
        on player starts sneaking flagged:in_disguise:
        - if <player.disguised_type.entity_type||null> == polar_bear:
            - if <player.disguise_to_self||null> != null:
                - animate <player.disguise_to_self> animation:polar_bear_start_standing
            - if <player.disguise_to_others||null> != null:
                - animate <player.disguise_to_others> animation:polar_bear_start_standing
        - else if <player.disguised_type.entity_type||null> == ghast:
            - if <player.disguise_to_self||null> != null:
                - adjust <player.disguise_to_self> ghast_attacking:true
            - if <player.disguise_to_others||null> != null:
                - adjust <player.disguise_to_others> ghast_attacking:true
        - else if <player.disguised_type.entity_type||null> == skeleton:
            - if <player.disguise_to_self||null> != null:
                - animate <player.disguise_to_self> animation:SKELETON_START_SWING_ARM
            - if <player.disguise_to_others||null> != null:
                - animate <player.disguise_to_others> animation:SKELETON_START_SWING_ARM
        - else if <player.disguised_type.entity_type||null> == horse:
            - if <player.disguise_to_self||null> != null:
                - animate <player.disguise_to_self> animation:HORSE_START_STANDING
            - if <player.disguise_to_others||null> != null:
                - animate <player.disguise_to_others> animation:HORSE_START_STANDING
        - else if <player.disguised_type.entity_type||null> == creeper:
            - if <player.disguise_to_self||null> != null:
                - adjust <player.disguise_to_self> ignite
            - if <player.disguise_to_others||null> != null:
                - adjust <player.disguise_to_others> ignite
        - else if <player.disguised_type.entity_type||null> == wolf:
            - if <player.disguise_to_self||null> != null:
                - animate <player.disguise_to_self> animation:wolf_shake for:<player>
            - if <player.disguise_to_others||null> != null:
                - animate <player.disguise_to_others> animation:wolf_shake
        - else if <player.disguised_type.entity_type||null> == sheep:
            - if <player.disguise_to_self||null> != null:
                - animate <player.disguise_to_self> animation:sheep_eat for:<player>
            - if <player.disguise_to_others||null> != null:
                - animate <player.disguise_to_others> animation:sheep_eat
        - else if <player.disguised_type.entity_type||null> == enderman:
            - if <player.disguise_to_self||null> != null:
                - adjust <player.disguise_to_self> enderman_angry:true
            - if <player.disguise_to_others||null> != null:
                - adjust <player.disguise_to_others> enderman_angry:true
        - else if <player.disguised_type.entity_type||null> == iron_golem:
            - if <player.disguise_to_self||null> != null:
                - animate <player.disguise_to_self> animation:iron_golem_rose for:<player>
            - if <player.disguise_to_others||null> != null:
                - animate <player.disguise_to_others> animation:iron_golem_rose
        - else if <player.disguised_type.entity_type||null> == ocelot:
            #- playsound sound:ENTITY_CAT_HISS volume:0.5 <player.location>
            - if <player.disguise_to_self||null> != null:
                - adjust <player.disguise_to_self> max_health:8
                - adjust <player.disguise_to_self> health:8
                - adjust <player> fake_entity_health:[entity=<player.disguise_to_self>;health=8]
            - if <player.disguise_to_others||null> != null:
                - adjust <player.disguise_to_others> max_health:8
                - adjust <player.disguise_to_others> health:8
                - adjust <player.location.find_players_within[50]> fake_entity_health:[entity=<player.disguise_to_others>;health=8]
        on player stops sneaking flagged:in_disguise:
        - if <player.disguised_type.entity_type||null> == polar_bear:
            - if <player.disguise_to_self||null> != null:
                - animate <player.disguise_to_self> animation:polar_bear_stop_standing for:<player>
            - if <player.disguise_to_others||null> != null:
                - animate <player.disguise_to_others> animation:polar_bear_stop_standing
        - else if <player.disguised_type.entity_type||null> == polar_bear:
            - if <player.disguise_to_self||null> != null:
                - animate <player.disguise_to_self> animation:horse_stop_standing for:<player>
            - if <player.disguise_to_others||null> != null:
                - animate <player.disguise_to_others> animation:horse_stop_standing
        - else if <player.disguised_type.entity_type||null> == ghast:
            - if <player.disguise_to_self||null> != null:
                - adjust <player.disguise_to_self> ghast_attacking:false
            - if <player.disguise_to_others||null> != null:
                - adjust <player.disguise_to_others> ghast_attacking:false
        - else if <player.disguised_type.entity_type||null> == skeleton:
            - if <player.disguise_to_self||null> != null:
                - animate <player.disguise_to_self> animation:SKELETON_STOP_SWING_ARM for:<player>
            - if <player.disguise_to_others||null> != null:
                - animate <player.disguise_to_others> animation:SKELETON_STOP_SWING_ARM
        - else if <player.disguised_type.entity_type||null> == enderman:
            - if <player.disguise_to_self||null> != null:
                - adjust <player.disguise_to_self> enderman_angry:false
            - if <player.disguise_to_others||null> != null:
                - adjust <player.disguise_to_others> enderman_angry:false
        - else if <player.disguised_type.entity_type||null> == iron_golem:
            - if <player.disguise_to_self||null> != null:
                - animate <player.disguise_to_self> animation:iron_golem_sheath for:<player>
            - if <player.disguise_to_others||null> != null:
                - animate <player.disguise_to_others> animation:iron_golem_sheath
        - else if <player.disguised_type.entity_type||null> == creeper:
            - define type <player.disguised_type>
            - disguise <player> cancel global
            - disguise <player> as:<[type]> global players:<tern[<player.has_flag[disguise_hide_self]>].pass[].fail[<player>]>
        - else if <player.disguised_type.entity_type||null> == ocelot:
            - define health <player.has_flag[ocelot_sitting].if_true[9].if_false[20]>
            - if <player.disguise_to_self||null> != null:
                - adjust <player.disguise_to_self> max_health:<[health]>
                - adjust <player.disguise_to_self> health:<[health]>
                - adjust <player> fake_entity_health:[entity=<player.disguise_to_self>;health=<[health]>]
            - if <player.disguise_to_others||null> != null:
                - adjust <player.disguise_to_others> max_health:<[health]>
                - adjust <player.disguise_to_others> health:<[health]>
                - adjust <player.location.find_players_within[50]> fake_entity_health:[entity=<player.disguise_to_others>;health=<[health]>]

disguise_data:
    type: data
    allowed_dead_types: shulker_bullet
