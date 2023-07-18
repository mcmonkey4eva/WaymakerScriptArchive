characters_tabcomplete_arg2_proc:
    type: procedure
    debug: false
    definitions: arg1
    script:
    - choose <[arg1]>:
        - case info swap delete:
            - determine <proc[characters_list_proc]>
        - case species race:
            - determine <script[cc_data].parsed_key[species].keys>
        - case age:
            - determine 20|30|40|50
        - case description:
            - determine add|remove|clear|1|2|3
        - case view verify approve accept reject deny staffinjure staffremoveinjury reset staffheal staffhurt:
            - determine <server.online_players.filter[has_flag[vanished].not].parse[name]>
        - default:
            - determine <list>

character_card_command:
    type: command
    debug: false
    name: charactercard
    aliases:
    - charcard
    - cc
    - ccard
    usage: /charactercard [option] [setting]
    description: Controls your character card.
    permission: dscript.charactercard
    tab completions:
        1: <list[list|info|name|species|culture|age|stats|skills|description|swap|new|finalize|delete|help|view|injuries|injure|removeinjury|skin].include[<tern[<player.has_permission[dscript.ccstaff]>].pass[staffinjure|staffremoveinjury|reset|verify|approve|accept|reject|deny|staffheal|staffhurt].fail[<list>]>]>
        2: <proc[characters_tabcomplete_arg2_proc].context[<list_single[<context.args.first||null>]>]>
    script:
    - choose <context.args.first||help>:
        - case view info:
            - inject cc_helper_get_target
            - inject cc_helper_clean_injuries
            - define color <&[base]>
            - define emphcolor <&[emphasis]>
            - define prefix <empty>
            - if <[target].in_group[founder]>:
                - define color <script[founder_colors_data].parsed_key[primary]>
                - define emphcolor <script[founder_colors_data].parsed_key[secondary]>
                - define prefix "<bold>[Founder] "
            - narrate "<[color]>========= <[prefix]><[emphcolor]><[target].name><[color]>'s character ========="
            - narrate "<[color]>Name: <[emphcolor]><[details.name]>"
            - narrate "<[color]>Species: <[emphcolor]><[details.species]> (<[details.culture]>)"
            - narrate "<[color]>Age: <[emphcolor]><[details.age]>"
            - narrate "<[color]>Description: <[emphcolor]><[details.description].separated_by[<n>]>"
            - narrate "<[color]>Health: <[emphcolor]><[details.health]>"
            - if <[details].contains[skin_blob]>:
                - narrate "<[color]>Has custom skin assigned."
            - if <[target_card].starts_with[event.]>:
                - narrate "<[color]>Is a special event character."
            - foreach <[injuries]> as:injury:
                - narrate "<[color]>Injury: <&f><[injury.message]>"
        - case list:
            - define target <player>
            - if <context.args.size> == 2:
                - define target <server.match_offline_player[<context.args.get[2]>]||null>
                - if <[target]> == null:
                    - narrate "<&[error]>Unknown player '<&[emphasis]><context.args.get[2]><&[error]>'."
                    - stop
            - define cards <proc[characters_list_proc].context[<[target]>]>
            - if <[cards].size||0> == 0:
                - narrate "<&[error]>No character cards yet."
                - stop
            - narrate "<&[emphasis]><[target].name><&[base]>'s character cards: <&[emphasis]><[cards].parse[proc[cc_name].context[<[target]>]].separated_by[<&[base]>, <&[emphasis]>]>"
        - case name:
            - if <context.args.size> < 2:
                - narrate "<&[error]>/charactercard name [name]"
                - stop
            - if !<player.has_flag[current_character]>:
                - narrate "<&[error]>You must create or swap to a character first."
                - stop
            - if <player.has_flag[current_character].starts_with[event.]>:
                - narrate "<&[error]>You cannot rename event characters from /charactercard."
                - stop
            - define char_name <context.raw_args.after[ ]>
            - define new_character <[char_name].proc[cc_escape]>
            - if <[new_character]> == event:
                - narrate "<&[error]>That name is reserved."
                - stop
            - if <player.has_flag[character_cards.<[new_character]>]>:
                - narrate "<&[error]>You already have a card with that name."
                - stop
            - if <[char_name].length> < 3:
                - narrate "<&[error]>That character name is too short."
                - stop
            - if <[char_name].proc[cc_escape].length> < 2:
                - narrate "<&[error]>That character name contains no letters."
                - stop
            - if <[char_name].length> > 40:
                - narrate "<&[error]>That character name is too long. Consider setting your character name as just the first part of the name or a shortened nickname, and type the rest into the description."
                - stop
            - define current <player.flag[current_character]>
            - define old_pair <player.proc[cc_idpair]>
            - define new_pair <player.uuid>__char__<[new_character]>
            - run cc_set_mode def.mode:ooc
            - define details <player.flag[character_cards.<[current]>].with[name].as[<[char_name]>]>
            - foreach <[details.rentable_member_of]||<list>> as:area:
                - flag server rentables.<[area]>.members:<-:<[old_pair]>
                - flag server rentables.<[area]>.members:->:<[new_pair]>
            - foreach <[details.rentables_owned]||<list>> as:area:
                - flag server rentables.<[area]>.owner:<[new_pair]>
            - foreach <[details.business_member_of]||<list>> as:business:
                - flag server businesses.<[business]>.members:<-:<[old_pair]>
                - flag server businesses.<[business]>.members:->:<[new_pair]>
            - foreach <[details.businesses_owned]||<list>> as:business:
                - flag server businesses.<[business]>.owner:<[new_pair]>
            - flag player character_cards.<[current]>:!
            - flag player character_cards.<[new_character]>:<[details]>
            - run cc_set_mode def.mode:ic def.name:<[new_character]>
            - narrate "<&[base]>Character card renamed to <&[emphasis]><[char_name]><&[base]>."
            - wait 1t
            - run name_suffix_character_card
        - case species race:
            - if <context.args.size> < 2:
                - narrate "<&[error]>/charactercard species [species]"
                - stop
            - if !<player.has_flag[current_character]>:
                - narrate "<&[error]>You must create or swap to a character first."
                - stop
            - define species_ind <script[cc_data].parsed_key[species].keys.find[<context.args.get[2]>]>
            - if <[species_ind]> == 0:
                - narrate "<&[error]>Unrecognized species. Must be one of: <script[cc_data].parsed_key[species].keys.parse[custom_color[emphasis]].separated_by[<&[error]>, ]>"
                - stop
            - define species <script[cc_data].parsed_key[species].keys.get[<[species_ind]>]>
            - define current <player.flag[current_character]>
            - if <proc[cc_has_flag].context[finalized]>:
                - narrate "<&[error]>Your character card is finalized. You cannot edit your species."
                - stop
            - flag player character_cards.<[current]>.species:<[species]>
            - narrate "<&[base]>Character card for <&[emphasis]><[current].proc[cc_name]><&[base]> species changed to <&[emphasis]><[species]><&[base]>. Make sure to set your <&[emphasis]>culture<&[base]> too."
        - case culture:
            - if <context.args.size> < 2:
                - narrate "<&[error]>/charactercard culture [culture]"
                - stop
            - if !<player.has_flag[current_character]>:
                - narrate "<&[error]>You must create or swap to a character first."
                - stop
            - define current <player.flag[current_character]>
            - flag player character_cards.<[current]>.culture:<context.args.get[2].to[last].space_separated>
            - narrate "<&[base]>Character card for <&[emphasis]><[current].proc[cc_name]><&[base]> culture changed to <&[emphasis]><context.args.get[2]><&[base]>."
        - case age:
            - if <context.args.size> < 2:
                - narrate "<&[error]>/charactercard age [age]"
                - stop
            - if !<player.has_flag[current_character]>:
                - narrate "<&[error]>You must create or swap to a character first."
                - stop
            - if !<context.args.get[2].is_integer>:
                - narrate "<&[error]>Character age must be a number (years old), for example <&[emphasis]>21"
                - stop
            - if <context.args.get[2]> < 18 || <context.args.get[2]> > 1000:
                - narrate "<&[error]>Character age must be a normal number (of years), and must be at least <&[emphasis]>18"
                - stop
            - define current <player.flag[current_character]>
            - flag player character_cards.<[current]>.age:<context.args.get[2]>
            - narrate "<&[base]>Character card for <&[emphasis]><[current].proc[cc_name]><&[base]> age changed to <&[emphasis]><context.args.get[2]><&[base]>."
        - case stats:
            - if !<player.has_flag[current_character]>:
                - narrate "<&[error]>You must create or swap to a character first."
                - stop
            - run cc_open_stat_inv
        - case skills:
            - if !<player.has_flag[current_character]>:
                - narrate "<&[error]>You must create or swap to a character first."
                - stop
            - run cc_open_skills_inv
        - case description desc:
            - if <context.args.size> < 3 && <context.args.get[2]||null> != clear:
                - narrate "<&[error]>/charactercard description [line] [text]"
                - narrate "<&[base]>Or, <&[error]>/charactercard description clear"
                - narrate "<&[base]>Or, <&[error]>/charactercard description remove [line]"
                - narrate "<&[base]>Or, <&[error]>/charactercard description add [text]"
                - stop
            - if !<player.has_flag[current_character]>:
                - narrate "<&[error]>You must create or swap to a character first."
                - stop
            - define current <player.flag[current_character]>
            - define description <proc[cc_flag].context[description]>
            - run multi_line_edit_tool def.args:<context.args.get[2].to[last]> def.orig_lines:<[description]> "def.cmd_prefix:/charactercard description" def.wrap_len:99999 def.raw_args:<context.raw_args.after[ ]> def.def_color:<empty> save:edited
            - define description <entry[edited].created_queue.determination.first>
            - flag player character_cards.<[current]>.description:<[description]>
        - case skin:
            - if <context.args.size> < 2:
                - narrate "<&[error]>/charactercard skin [name/uuid/link]"
                - narrate "<&[error]>/charactercard skin reset <&[warning]>- to disable the custom skin for the character"
                - narrate "<&[error]>When in doubt, upload your skin to<&9> <element[https://mineskin.org/].on_click[https://mineskin.org/].type[open_url]> <&[error]>and use that link."
                - stop
            - if !<player.has_flag[current_character]>:
                - narrate "<&[error]>You must create or swap to a character first."
                - stop
            - ratelimit <player> 3s
            - define target <player>
            - define arg <context.args.get[2]>
            - if <[arg]> == reset:
                - flag player character_cards.<player.flag[current_character]>.skin_blob:!
            - inject skin_command_process
            - flag player character_cards.<player.flag[current_character]>.skin_blob:<player.skin_blob>
            - flag player had_cc_skin
        - case swap:
            - if <player.flag[character_cards].keys.size||0> == 0:
                - narrate "<&[error]>You must create a character first."
                - stop
            - if <context.args.size> < 2:
                - define options <list>
                - foreach <player.flag[character_cards]> as:char_data key:char_id:
                    - if <[char_id]> != <player.flag[current_character]||>:
                        - if <[char_data.location].world.name||null> == <player.location.world.name>:
                            - define dist "<&[base]>(<player.location.distance[<[char_data.location]>].round.custom_color[emphasis]> blocks away)"
                        - else:
                            - define dist <&[base]>(elsewhere)
                        - define "options:->:<player.proc[cc_idpair].context[<[char_id]>].proc[embedder_for_character].context[/cc swap <[char_data.name]>]> <[dist]>"
                - if <[options].any>:
                    - narrate "<&[base]>Choose character to swap into:<n><[options].separated_by[<n>]>"
                - else:
                    - narrate "<&[error]>/charactercard swap [name]"
                - stop
            - define character <context.raw_args.after[ ].proc[cc_escape]>
            - if <[character]> == event:
                - narrate "<&[error]>That name is reserved."
                - stop
            - if !<player.has_flag[character_cards.<[character]>]>:
                - narrate "<&[error]>You do not have a card with that name."
                - stop
            - run cc_set_mode def.mode:ic def.name:<[character]>
            - narrate "<&[base]>Switched over to character <&[emphasis]><[character].proc[cc_name]><&[base]>."
        - case new:
            - if <context.args.size> < 2:
                - narrate "<&[error]>/charactercard new [name]"
                - stop
            - define char_name <context.raw_args.after[ ]>
            - define character <[char_name].proc[cc_escape]>
            - if <[character]> in event|null|none:
                - narrate "<&[error]>That name is reserved."
                - stop
            - if <player.has_flag[character_cards.<[character]>]>:
                - narrate "<&[error]>You already have a card with that name."
                - stop
            - if <[char_name].length> < 3:
                - narrate "<&[error]>That character name is too short."
                - stop
            - if <[char_name].proc[cc_escape].length> < 2:
                - narrate "<&[error]>That character name contains no letters."
                - stop
            - if <[char_name].length> > 40:
                - narrate "<&[error]>That character name is too long. Consider setting your character name as just the first part of the name or a shortened nickname, and type the rest into the description."
                - stop
            - define max <proc[character_count_limit_proc]>
            - if <proc[characters_list_proc].size||0> >= <[max]>:
                - narrate "<&[error]>You have too many character cards already. You may have up to <&[emphasis]><[max]><&[error]>. You can <&[emphasis]>delete<&[error]> an existing card to make space."
                - stop
            - definemap char_base:
                name: <[char_name]>
                description: <list[(UNSET)]>
                species: Human
                culture: Uncultured
                age: (UNSET)
                inventory: <map>
                last_used: <util.time_now>
                player: <player>
                gold: 0
                health: 20
            - foreach <script[cc_data].parsed_key[stats].keys> as:stat:
                - define char_base.stats.<[stat]>:0
            - foreach <script[cc_data].parsed_key[skills].keys> as:skill:
                - define char_base.skills.<[skill]>:0
            - flag player character_cards.<[character]>:<[char_base]>
            - run cc_set_mode def.mode:ic def.name:<[character]>
            - narrate "<&[base]>Character card for <&[emphasis]><[char_name]><&[base]> created and swapped to. Next, set your <element[/cc species].on_click[/cc species ].type[suggest_command].custom_color[clickable]> and your <element[/cc age].on_click[/cc age ].type[suggest_command].custom_color[clickable]>"
            - narrate "<&[base]>Then, fill out your <element[/cc description ].on_click[/cc description ].type[suggest_command].custom_color[clickable]> and choose your <element[/cc stats ].on_click[/cc stats ].type[suggest_command].custom_color[clickable]>"
            - if !<player.location.is_within[aurum_spawn_safezone]>:
                - teleport <player> aurum_spawn_center
            - if <player.has_flag[cc_create_should_encourage]>:
                - flag player cc_create_should_encourage:!
                - narrate format:format_tutorial_firstmate "Got 'em? Good, now what you've gotta do is head in and find the immigration lady."
        - case delete:
            - if <context.args.size> < 2:
                - narrate "<&[error]>/charactercard delete [name]"
                - stop
            - define character <context.raw_args.after[ ].escaped>
            - if <[character]> == event:
                - narrate "<&[error]>That name is reserved."
                - stop
            - if !<player.has_flag[character_cards.<[character]>]>:
                - narrate "<&[error]>You do not have a card with that name."
                - stop
            - narrate "<&[base]>You are about to delete character <[character].proc[cc_name].custom_color[emphasis]>"
            - define details <player.flag[character_cards.<[character]>]>
            - if <[details.rentables_owned].any||false>:
                - narrate "<&[warning]>This character owns <[details.rentables_owned].size.custom_color[emphasis]> properties."
            - if <[details.rentable_member_of].any||false>:
                - narrate "<&[warning]>This character is a member of <[details.rentable_member_of].size.custom_color[emphasis]> properties."
            - if <[details.businesses_owned].any||false>:
                - narrate "<&[warning]>This character owns <[details.businesses_owned].size.custom_color[emphasis]> businesses."
            - if <[details.business_member_of].any||false>:
                - narrate "<&[warning]>This character is a member of <[details.business_member_of].size.custom_color[emphasis]> businesses."
            - narrate "<&[base]>Are you sure? If so, click: <element[confirm].custom_color[clickable].on_click[/charactercard confirm<context.raw_args>].on_hover[click me!]>."
        - case confirmdelete:
            - if <context.args.size> < 2:
                - narrate "<&[error]>/charactercard delete [name]"
                - stop
            - define character <context.raw_args.after[ ].proc[cc_escape]>
            - if <[character]> == event:
                - narrate "<&[error]>That name is reserved."
                - stop
            - if !<player.has_flag[character_cards.<[character]>]>:
                - narrate "<&[error]>You do not have a card with that name."
                - stop
            - define details <player.flag[character_cards.<[character]>]>
            - foreach <[details.rentable_member_of]||<list>> as:area:
                - flag server rentables.<[area]>.members:<-:<[old_pair]>
            - foreach <[details.rentables_owned]||<list>> as:area:
                - foreach <server.flag[rentables.<[area]>.members]> as:member:
                    - run cc_exclude_flag def.pair:<[member]> def.flag:rentable_member_of def.value:<[area]>
                - flag server rentables.<[area]>.owner:!
                - flag server rentables.<[area]>.owner_business:!
                - flag server rentables.<[area]>.owned_type:!
                - flag server rentables.<[area]>.members:<list>
            - foreach <[details.business_member_of]||<list>> as:business:
                - flag server businesses.<[business]>.members:<-:<[old_pair]>
            - foreach <[details.businesses_owned]||<list>> as:business:
                - flag server businesses.<[business]>.owner:!
                - flag server businesses.<[business]>.owned:false
                - flag server businesses.<[business]>.members:<list>
            - if <proc[cc_has_flag].context[finalized]>:
                - run discord_send_message_immediate def.channel:discord_slowlog_channel "def.message:] <&lt>**`<player.name>`**<&gt> **DELETED** a finalized character card." def.attach_name:char_data.yml def.attach_text:attach_text:<player.flag[character_cards.<[character]>].to_yaml>
            - if <player.flag[current_character]||null> == <[character]>:
                - run cc_set_mode def.mode:ooc
            - flag player character_cards.<[character]>:!
            - narrate "<&[base]>Character card for <&[emphasis]><[details.name]><&[base]> deleted."
        - case finalize:
            - if !<player.has_flag[current_character]>:
                - narrate "<&[error]>You must create or swap to a character first."
                - stop
            - define char <player.flag[current_character]>
            - if <proc[cc_has_flag].context[verified]>:
                - narrate "<&[error]>Your character is already verified."
                - stop
            - if <proc[cc_has_flag].context[finalized]>:
                - narrate "<&[error]>Your character is already finalized, and awaiting verification. Get a staff member to approve it."
                - stop
            - define stats <proc[cc_flag].context[stats]>
            - define spare_points <element[6].sub[<[stats].values.sum>]>
            - if <[spare_points]> != 0:
                - narrate "<&[error]>Your stats are not yet ready. Use <element[/cc stats].custom_color[clickable].on_click[/cc stats]><&[error]> to choose them (must have none unspent)."
                - stop
            - define skills <proc[cc_flag].context[skills]>
            - define spare_skill_points <element[10].sub[<[skills].values.sum>]>
            - if <[spare_skill_points]> != 0:
                - narrate "<&[error]>Your skills are not yet ready. Use <element[/cc skills].custom_color[clickable].on_click[/cc skills]><&[error]> to choose them (must have 0 unspent)."
                - stop
            - if !<player.has_flag[irl_dob]>:
                - narrate "<&[error]>You haven't confirmed your age yet. Use <element[/irldob yyyy/mm/dd].custom_color[clickable].on_click[/irldob ]><&[error]> to set your date of birth."
                - stop
            - if <player.flag[irl_dob].from_now.in_years.round_down> < 16:
                - narrate "<&[error]>The minimum age that we allow on Waymaker is <&[emphasis]>16 years old<&[error]>. You are welcome to return when you are old enough."
                - stop
            - flag player character_cards.<[char]>.finalized
            - narrate "<&[base]>Your character card is now finalized. You now need a staff member to verify it."
            - run discord_send_message def.channel:discord_slowlog_channel "def.message:] <&lt>**`<player.name>`**<&gt> **FINALIZED** their character card and is awaiting approval."
        - case reset:
            - if !<player.has_permission[dscript.ccstaff]>:
                - narrate "<&c>This command is for staff only."
                - stop
            - if <context.args.size> < 2:
                - narrate "<&[error]>/charactercard reset [player]"
                - stop
            - define target <server.match_offline_player[<context.args.get[2]>]||null>
            - if <[target]> == null:
                - narrate "<&[error]>Unknown player '<&[emphasis]><context.args.get[2]><&[error]>'."
                - stop
            - if <[target].name> != <context.args.get[2]>:
                - narrate "<&[error]>Please type the exact player name to avoid mistakes with the staff forcible reset command."
                - stop
            - run cc_set_mode def.mode:ooc player:<[target]>
            - foreach <player.flag[character_cards]> key:character as:details:
                - foreach <[details.rentable_member_of]||<list>> as:area:
                    - flag server rentables.<[area]>.members:<-:<[old_pair]>
                - foreach <[details.rentables_owned]||<list>> as:area:
                    - foreach <server.flag[rentables.<[area]>.members]> as:member:
                        - run cc_exclude_flag def.pair:<[member]> def.flag:rentable_member_of def.value:<[area]>
                    - flag server rentables.<[area]>.owner:!
                    - flag server rentables.<[area]>.owner_business:!
                    - flag server rentables.<[area]>.owned_type:!
                    - flag server rentables.<[area]>.members:<list>
                - foreach <[details.business_member_of]||<list>> as:business:
                    - flag server businesses.<[business]>.members:<-:<[old_pair]>
                - foreach <[details.businesses_owned]||<list>> as:business:
                    - flag server businesses.<[business]>.owner:!
                    - flag server businesses.<[business]>.owned:false
                    - flag server businesses.<[business]>.members:<list>
            - flag <[target]> character_cards:!
            - if <[target].is_online>:
                - run name_suffix_character_card player:<[target]>
            - narrate "<&[base]>All character cards for <&[emphasis]><[target].name><&[base]> deleted."
        - case verify approve accept:
            - if !<player.has_permission[dscript.ccstaff]>:
                - narrate "<&c>This command is for staff only."
                - stop
            - if <context.args.size> < 2:
                - narrate "<&[error]>/charactercard verify [player]"
                - stop
            - define target <server.match_offline_player[<context.args.get[2]>]||null>
            - if <[target]> == null:
                - narrate "<&[error]>Unknown player '<&[emphasis]><context.args.get[2]><&[error]>'."
                - stop
            - if <[target].name> != <context.args.get[2]>:
                - narrate "<&[error]>Please type the exact player name to avoid mistakes with the verification command. Did you mean <&[emphasis]><[target].name><&[error]>?"
                - stop
            - if !<[target].has_flag[discord_account]>:
                - narrate "<&[error]><[target].proc[proc_format_name].context[<player>]> has not linked their Discord account yet."
                - stop
            - if <[target].flag[character_mode]> != ic:
                - narrate "<&[error]><[target].proc[proc_format_name].context[<player>]> does not have a character selected."
                - stop
            - define char <[target].flag[current_character]>
            - if <[target].proc[cc_has_flag].context[verified]>:
                - narrate "<&[error]><[target].proc[proc_format_name].context[<player>]>'s current character is already verified."
                - stop
            - if !<[target].proc[cc_has_flag].context[finalized]>:
                - narrate "<&[error]><[target].proc[proc_format_name].context[<player>]>'s current character is not yet finalized. Please ask them to use <&[warning]>/cc finalize"
                - stop
            - flag <[target]> waymaker_verified
            - flag <[target]> character_cards.<[char]>.verified
            - narrate "<&[base]>You have verified <[target].proc[proc_format_name].context[<player>]>'s character!"
            - if <[target].is_online>:
                - run cc_verify_message_handler_task player:<[target]>
            - else:
                - flag <[target]> send_cc_verify_message
            - run discord_send_message def.channel:discord_slowlog_channel "def.message:] <&lt>**`<player.name>`**<&gt> **VERIFIED** the character card of **<[target].name>**: `<[char]>`."
        - case reject deny:
            - if !<player.has_permission[dscript.ccstaff]>:
                - narrate "<&c>This command is for staff only."
                - stop
            - if <context.args.size> < 2:
                - narrate "<&[error]>/charactercard reject [player]"
                - stop
            - define target <server.match_offline_player[<context.args.get[2]>]||null>
            - if <[target]> == null:
                - narrate "<&[error]>Unknown player '<&[emphasis]><context.args.get[2]><&[error]>'."
                - stop
            - if <[target].name> != <context.args.get[2]>:
                - narrate "<&[error]>Please type the exact player name to avoid mistakes with the rejection command. Did you mean <&[emphasis]><[target].name><&[error]>?"
                - stop
            - if <[target].flag[character_mode]> != ic:
                - narrate "<&[error]><[target].proc[proc_format_name].context[<player>]> does not have a character selected."
                - stop
            - define char <[target].flag[current_character]>
            - if !<[target].proc[cc_has_flag].context[finalized]>:
                - narrate "<&[error]><[target].proc[proc_format_name].context[<player>]>'s current character is not yet finalized."
                - stop
            - if <[target].proc[cc_has_flag].context[verified]>:
                - narrate "<&[error]><[target].proc[proc_format_name].context[<player>]>'s current character is already verified."
                - stop
            - flag <[target]> character_cards.<[char]>.finalized:!
            - narrate "<&[base]>You have rejected <[target].proc[proc_format_name].context[<player>]>'s character."
            - if <[target].is_online>:
                - run cc_reject_message_handler_task player:<[target]>
            - else:
                - flag <[target]> send_cc_reject_message
            - run discord_send_message def.channel:discord_slowlog_channel "def.message:] <&lt>**`<player.name>`**<&gt> **REJECTED** the character card of **<[target].name>**: `<[char]>`."
        - case injuries:
            - inject cc_helper_get_target
            - inject cc_helper_clean_injuries
            - if <[injuries].is_empty>:
                - narrate "<&[base]>No current injuries."
                - stop
            - inject cc_helper_list_injury_details
        - case injure addinjury addinjure:
            - if !<player.has_flag[current_character]>:
                - narrate "<&[error]>You must create or swap to a character first."
                - stop
            - if <context.args.size> < 2:
                - narrate "<&[error]>/charactercard injure (time:[time]) [text]"
                - stop
            - define target <player>
            - define target_card <player.flag[current_character]>
            - define details <player.flag[character_cards.<[target_card]>].as[map]>
            - inject cc_helper_clean_injuries
            - define message <context.raw_args.after[ ]>
            - if <context.args.get[2].starts_with[time:]>:
                - define duration <duration[<context.args.get[2].after[:]>]||null>
                - define message <[message].after[ ]>
                - if <[duration]> == null:
                    - narrate "<&[error]>Invalid time duration - example durations: 'time:3d' (3 days), 'time:5h' (5 hours)"
                    - stop
            - if <[message].trim.length> < 4:
                - narrate "<&[error]>Injury text too short. Please describe the injury."
                - stop
            - define injury <map.with[adder].as[<player>].with[message].as[<[message]>].with[date].as[<util.time_now>]>
            - if <[duration]||null> != null:
                - define injury <[injury].with[expiration].as[<util.time_now.add[<[duration]>]>]>
            - flag <[target]> character_cards.<[target_card]>.injuries:->:<[injury]>
            - narrate "<&[base]>Added new injury: <&f><[injury].get[message]>"
        - case removeinjury uninjure removeinjure:
            - if !<player.has_flag[current_character]>:
                - narrate "<&[error]>You must create or swap to a character first."
                - stop
            - if <context.args.size> < 2:
                - narrate "<&[error]>/charactercard removeinjury [id]"
                - stop
            - define target <player>
            - define target_card <player.flag[current_character]>
            - define details <player.flag[character_cards.<[target_card]>].as[map]>
            - inject cc_helper_clean_injuries
            - if <[injuries].is_empty>:
                - narrate "<&[base]>Cannot remove injury: no current injuries."
                - stop
            - define id <context.args.get[2]>
            - if !<[id].is_integer> || <[id]> <= 0 || <[id]> > <[injuries].size>:
                - narrate "<&[base]>Invalid injury ID. Must be a number from 1 to <[injuries].size>."
                - stop
            - define injury <[injuries].get[<[id]>]>
            - if <[injury].get[adder].uuid> != <player.uuid>:
                - narrate "<&[error]>You may not remove that injury, as it was added by a staff member. If the injury was fixed, ask a staff member to remove it from your card."
                - stop
            - flag <[target]> character_cards.<[target_card]>.injuries[<[id]>]:<-
            - define injuries[<[id]>]:<-
            - narrate "<&[base]>Removed injury: <&f><[injury].get[message]>"
            - inject cc_helper_list_injury_details
        - case staffinjure staffaddinjury staffaddinjure:
            - if !<player.has_permission[dscript.ccstaff]>:
                - narrate "<&c>This command is for staff only."
                - stop
            - if <context.args.size> < 3:
                - narrate "<&[error]>/charactercard staffinjure [player] (time:[time]) [text]"
                - stop
            - inject cc_helper_get_target
            - inject cc_helper_clean_injuries
            - define message <context.raw_args.after[ ].after[ ]>
            - if <context.args.get[3].starts_with[time:]>:
                - define duration <duration[<context.args.get[3].after[:]>]||null>
                - define message <[message].after[ ]>
                - if <[duration]> == null:
                    - narrate "<&[error]>Invalid time duration - example durations: 'time:3d' (3 days), 'time:5h' (5 hours)"
                    - stop
            - if <[message].trim.length> < 4:
                - narrate "<&[error]>Injury text too short. Please describe the injury."
                - stop
            - define injury <map.with[adder].as[<player>].with[message].as[<[message]>].with[date].as[<util.time_now>]>
            - if <[duration]||null> != null:
                - define injury <[injury].with[expiration].as[<util.time_now.add[<[duration]>]>]>
            - flag <[target]> character_cards.<[target_card]>.injuries:->:<[injury]>
            - narrate "<&[base]>Added new injury to <&[emphasis]><[pair].proc[cc_format_idpair].context[<player>]><&[base]>: <&f><[injury].get[message]>"
            - if <[target].is_online>:
                - define player <player>
                - narrate "<proc[proc_format_name].context[<[player]>|<[target]>]> added injury to your character <&[emphasis]><[pair].proc[cc_name]><&[base]>: <&f><[injury].get[message]>" targets:<[target]>
        - case staffremoveinjury staffuninjure staffremoveinjure:
            - if !<player.has_permission[dscript.ccstaff]>:
                - narrate "<&c>This command is for staff only."
                - stop
            - if <context.args.size> < 3:
                - narrate "<&[error]>/charactercard staffremoveinjury [player] [id]"
                - stop
            - inject cc_helper_get_target
            - inject cc_helper_clean_injuries
            - if <[injuries].is_empty>:
                - narrate "<&[base]>Cannot remove injury: no current injuries."
                - stop
            - define id <context.args.get[3]>
            - if !<[id].is_integer> || <[id]> <= 0 || <[id]> > <[injuries].size>:
                - narrate "<&[base]>Invalid injury ID. Must be a number from 1 to <[injuries].size>."
                - stop
            - define injury <[injuries].get[<[id]>]>
            - flag <[target]> character_cards.<[target_card]>.injuries[<[id]>]:<-
            - define injuries[<[id]>]:<-
            - narrate "<&[base]>Removed injury from <&[emphasis]><[pair].proc[cc_format_idpair].context[<player>]><&[base]>: <&f><[injury].get[message]>"
            - inject cc_helper_list_injury_details
            - if <[target].is_online>:
                - define player <player>
                - narrate "<proc[proc_format_name].context[<[player]>|<[target]>]> removed injury from your character <&[emphasis]><[pair].proc[cc_name]><&[base]>: <&f><[injury].get[message]>" targets:<[target]>
        - case staffheal:
            - if !<player.has_permission[dscript.ccstaff]>:
                - narrate "<&c>This command is for staff only."
                - stop
            - if <context.args.size> < 3:
                - narrate "<&[error]>/charactercard stealheal [player] [amount]"
                - stop
            - inject cc_helper_get_target
            - define health <[pair].proc[cc_flag].context[health]||0>
            - define max <[pair].proc[cc_proc_maxhealth]>
            - if <[health]> == <[max]>:
                - narrate "<&[error]><[pair].proc[cc_format_idpair].context[<player>]> is already at their maximum health."
                - stop
            - define amount <context.args.get[3]>
            - if !<[amount].is_integer>:
                - narrate "<&[error]>Input amount must be an integer number."
                - stop
            - run cc_health_modify def.amount:<[amount]> def.pair:<[pair]>
            - narrate "<&[base]><[pair].proc[cc_format_idpair].context[<player>]> has been healed by <[amount].custom_color[emphasis]> from <[health].custom_color[emphasis]> to <[pair].proc[cc_flag].context[health].custom_color[emphasis]>/<[max].custom_color[emphasis]>."
        - case staffhurt:
            - if !<player.has_permission[dscript.ccstaff]>:
                - narrate "<&c>This command is for staff only."
                - stop
            - if <context.args.size> < 3:
                - narrate "<&[error]>/charactercard staffhurt [player] [amount]"
                - stop
            - inject cc_helper_get_target
            - define health <[pair].proc[cc_flag].context[health]||0>
            - define max <[pair].proc[cc_proc_maxhealth]>
            - if <[health]> == 0:
                - narrate "<&[error]><[pair].proc[cc_format_idpair].context[<player>]> is already at zero health."
                - stop
            - define amount <context.args.get[3]>
            - if !<[amount].is_integer>:
                - narrate "<&[error]>Input amount must be an integer number."
                - stop
            - run cc_health_modify def.amount:-<[amount]> def.pair:<[pair]>
            - narrate "<&[base]><[pair].proc[cc_format_idpair].context[<player>]> has been hurt by <[amount].custom_color[emphasis]> from <[health].custom_color[emphasis]> to <[pair].proc[cc_flag].context[health].custom_color[emphasis]>/<[max].custom_color[emphasis]>."
        - default:
            - choose <context.args.get[2]||general>:
                - case basics:
                    - narrate "<&[warning]>======= Character Cards Help: Basics ======="
                    - narrate "<&[base]>You can create a new character with <&[warning]>/cc new [name]<&[base]> at any time (up to <&[emphasis]><proc[character_count_limit_proc]><&[base]> cards at the same time) - new characters are locked to the spawn region until you use <&[warning]>/cc finalize<&[base]> and a staff member verifies you."
                    - narrate "<&[base]>You may use <&[warning]>/cc swap [name]<&[base]> at any time to swap to a different character, or <&[warning]>/ooc<&[base]> to have no character (you may roam freely if you have any verified characters on account)."
                    - narrate "<&[base]>You may use <&[warning]>/cc delete [name]<&[base]> to delete a character you don't want anymore."
                - case staff:
                    - if !<player.has_permission[dscript.ccstaff]>:
                        - narrate "<&[error]>Not for you."
                        - stop
                    - narrate "<&[warning]>======= Character Cards Help: Staff ======="
                    - narrate "<&[error]>/cc reset [player] <&[warning]>- Deletes all character cards for another player."
                    - narrate "<&[error]>/cc staffinjure [player] (time:[time]) [text] <&[warning]>- Adds an injury to the specified player's character, optionally specify a time like 'time:3d' (3 days) that the injury will remain for."
                    - narrate "<&[error]>/cc staffremoveinjury [player] [id] <&[warning]>- Removes an injury from the specified player's character - use '/charactercard injuries [name]' to get the ID number for an injury."
                    - narrate "<&[error]>/cc staffheal [player] [amount] <&[warning]>- Heals a character by a given amount of HP."
                    - narrate "<&[error]>/cc staffhurt [player] [amount] <&[warning]>- Damages a character by a given amount of HP."
                    - narrate "<&[error]>/cc verify [player] <&[warning]>- Verifies that player's current character."
                    - narrate "<&[error]>/cc reject [player] <&[warning]>- Rejects that player's current character."
                - case configure:
                    - narrate "<&[warning]>======= Character Cards Help: Configure ======="
                    - narrate "<&[error]>/cc species [species] <&[warning]>- To set your character's species (locked after finalize)."
                    - narrate "<&[error]>/cc stats <&[warning]>- Configures your stats (locked after finalize)."
                    - narrate "<&[error]>/cc skills <&[warning]>- Configures your skills (locked after finalize)."
                    - narrate "<&[error]>/cc name [name] <&[warning]>- To change your character's name."
                    - narrate "<&[error]>/cc culture [culture] <&[warning]>- To set your character's culture."
                    - narrate "<&[error]>/cc age [age] <&[warning]>- To set your character's age."
                    - narrate "<&[error]>/cc description [line #] [text] <&[warning]>- To set a line of your character's description."
                    - narrate "<&[error]>/cc skin [name/uuid/link] <&[warning]>- to change the skin for your character."
                - case viewing:
                    - narrate "<&[warning]>======= Character Cards Help: Viewing ======="
                    - narrate "<&[error]>/cc view (player) <&[warning]>- To show details of a current character card."
                    - narrate "<&[error]>/cc list (player) <&[warning]>- To view available characters."
                    - narrate "<&[base]>You can also view a player's current character card by shift-right-clicking on the player."
                - case injuries:
                    - narrate "<&[warning]>======= Character Cards Help: Injuries ======="
                    - narrate "<&[error]>/cc injuries (player) <&[warning]>- Shows your character's injuries (or somebody else's)."
                    - narrate "<&[error]>/cc injure (time:[time]) [text] <&[warning]>- Adds an injury to your character, optionally specify a time like 'time:3d' (3 days) that the injury will remain for."
                    - narrate "<&[error]>/cc removeinjury [id] <&[warning]>- Removes an injury from your character - use '/charactercard injuries' to get the ID number for an injury."
                - default:
                    - narrate "<&[warning]>======= Character Cards Help ======="
                    - if <player.has_permission[dscript.ccstaff]>:
                        - narrate "<&[base]>Staff Character Card commands: <element[/cc help staff].custom_color[clickable].on_hover[click me].on_click[/cc help staff]>"
                    - narrate "<&[base]>Need to know the basics? Click here: <element[/cc help basics].custom_color[clickable].on_hover[click me].on_click[/cc help basics]>"
                    - narrate "<&[base]>Detailed configuration options?: <element[/cc help configure].custom_color[clickable].on_hover[click me].on_click[/cc help configure]>"
                    - narrate "<&[base]>Viewing options: <element[/cc help viewing].custom_color[clickable].on_hover[click me].on_click[/cc help viewing]>"
                    - narrate "<&[base]>Injuries system: <element[/cc help injuries].custom_color[clickable].on_hover[click me].on_click[/cc help injuries]>"

character_count_limit_proc:
    type: procedure
    debug: false
    script:
    - if <player.has_flag[bonus_cards]>:
        - determine <player.flag[bonus_cards]>
    - define amount 2
    #- if <player.in_group[oracle]>:
    #    - define amount 5
    #- else if <player.in_group[navigator]>:
    #    - define amount 4
    - if <player.in_group[founder]>:
        - define amount 3
    #- else if <player.in_group[crewmate]>:
    #    - define amount 3
    - determine <[amount]>

skin_autopatch_task:
    type: task
    debug: false
    script:
    - wait 1t
    - adjust <player> skin_layers:hat
    - wait 1t
    - adjust <player> skin_layers:all
    - adjust <player> hide_from_players
    - if !<player.has_flag[vanished]>:
        - wait 2t
        - adjust <player> show_to_players
    #- adjust <player> skin_layers:hat
    #- wait 5t
    #- adjust <player> skin_layers:all
    #- wait 2t
    #- adjust <player> skin_layers:all

characters_skin_update:
    type: task
    debug: false
    script:
    - if <player.flag[character_mode]> == ic && <proc[cc_has_flag].context[skin_blob]>:
        - flag player had_cc_skin
        - adjust <player> skin_blob:<proc[cc_flag].context[skin_blob]||null>
        - inject skin_autopatch_task
    - else if <player.has_flag[had_cc_skin]>:
        - flag player had_cc_skin:!
        - if <player.has_flag[custom_skin]>:
            - adjust <player> skin_blob:<player.flag[custom_skin]>
        - else:
            - adjust <player> skin:<player.name>
        - inject skin_autopatch_task

inventory_history_task:
    type: task
    debug: false
    script:
    - while <player.flag[inv_history].size||0> >= 20:
        - flag <player> inv_history[1]:<-
    - flag <player> inv_history:->:<player.inventory.list_contents>

inventory_history_world:
    type: world
    debug: false
    events:
        on player joins:
        - ratelimit <player> 12h
        - run inventory_history_task

cc_helper_get_target:
    type: task
    debug: false
    script:
    - define target <player>
    - if <context.args.size> >= 2:
        - define target_name <context.args.get[2]>
        - define target_card <empty>
        - if <[target_name].contains[:]>:
            - define target_card <[target_name].after[:].proc[cc_escape]>
            - define target_name <[target_name].before[:]>
        - define target <server.match_offline_player[<[target_name]>]||null>
        - if <[target]> == null:
            - narrate "<&[error]>Unknown player '<&[emphasis]><[target_name]><&[error]>'."
            - stop
        - if <[target_card].length> == 0:
            - if !<[target].has_flag[current_character]>:
                - narrate "<&[emphasis]><[target].name><&[error]> does not have an active character card."
                - stop
            - define target_card <[target].flag[current_character]>
        - else if !<[target].has_flag[character_cards.<[target_card]>]>:
            - define cards <proc[characters_list_proc].context[<[target]>]>
            - define target_card <[cards].filter[contains[<[target_card]>]].first||>
            - if <[target_card].length> == 0:
                - narrate "<&[emphasis]><[target].name><&[error]> does not have any matching character card."
                - stop
    - else:
        - if !<[target].has_flag[current_character]>:
            - narrate "<&[error]>You do not have an active character card."
            - stop
        - define target_card <[target].flag[current_character]>
    - define details <[target].flag[character_cards.<[target_card]>].as[map]>
    - define pair <[target].uuid>__char__<[target_card]>

cc_helper_clean_injuries:
    type: task
    debug: false
    definitions: details|target|target_card
    script:
    - define remove_ids <list>
    - define injuries <list>
    - foreach <[details].get[injuries]||<list>> as:injury:
        - if <[injury].get[expiration].is_before[<util.time_now>]||false>:
            - announce to_console "<[target].name> injury <[loop_index]> expired"
            - define remove_ids:->:<[loop_index]>
        - else:
            - define injuries:->:<[injury]>
    - foreach <[remove_ids].reverse> as:id:
        - flag <[target]> character_cards.<[target_card]>.injuries[<[id]>]:<-

cc_helper_list_injury_details:
    type: task
    debug: false
    definitions: injuries|target|target_card|pair
    script:
    - if <[injuries].size> > 0:
        - narrate "<&[base]>Current injuries for <&[emphasis]><[pair].proc[cc_format_idpair].context[<player>]><&[base]>..."
        - foreach <[injuries]> as:injury:
            - narrate "<&[emphasis]>Injury #<[loop_index]>: <&f><[injury].get[message]> <&7>(added by <proc[proc_format_name].context[<[injury].get[adder]>|<player>]><&7> at <[injury].get[date].format>, lasts <[injury].get[expiration].from_now.formatted||until manually removed>)"

characters_verify_world:
    type: world
    debug: false
    events:
        after player joins flagged:send_cc_verify_message:
        - wait 10s
        - if <player.is_online>:
            - flag player send_cc_verify_message:!
            - run cc_verify_message_handler_task
        after player joins flagged:send_cc_reject_message:
        - wait 10s
        - if <player.is_online>:
            - flag player send_cc_reject_message:!
            - run cc_reject_message_handler_task

cc_verify_message_handler_task:
    type: task
    debug: false
    script:
    - narrate format:format_tutorial_deskworker "Hm... this all seems to check out. Welcome to Danary!"
    - wait 2s
    - narrate "<&[way_emote]>[The Desk worker slams a stamp down onto your passport and hands it to you, dismissing you with a small hand gesture as she immediately turns away to busy herself with her endless other duties.]"
    - wait 4s
    - narrate "<&[base]>Congratulations! You are now verified! You may now leave the Aurum spawn."

cc_reject_message_handler_task:
    type: task
    debug: false
    script:
    - narrate format:format_tutorial_deskworker "As much as I enjoy a good joke, please don't waste my time. I have very important duties to attend to, return when you have your actual papers."
    - wait 2s
    - narrate "<&[way_emote]>[The Desk worker hands your papers back to you. She stares at you, waiting for you to pull out your actual passport.]"
    - wait 4s
    - narrate "<&[error]>Uh-oh! Looks your like character card wasn't able to be verified in its current form. It has been un-finalized for editing. Ask staff for help if you're not sure why."

cmd_player_char_select_helper_tab:
    type: procedure
    debug: false
    definitions: arg
    script:
    - define cname x
    - if <[arg].contains_text[:]>:
        - define cname <[arg].after[:]>
        - define arg <[arg].before[:]>
        - define target <server.match_offline_player[<[arg]>]||null>
        - if <[target]> == null:
            - determine <list>
        - determine <[target].flag[character_cards].keys.if_null[<list>].parse_tag[<[arg]>:<[parse_value]>]>
    - define list <server.online_players.filter[has_flag[vanished].not].parse[name]>
    - determine <[list].include[<[list].parse_tag[<[parse_value]>:]>]>

cmd_player_char_select_helper:
    type: task
    debug: false
    definitions: pl_target_name
    script:
    - define pl_char_name x
    - if <[pl_target_name].contains[:]>:
        - define pl_char_name <[pl_target_name].after[:]>
        - define pl_target_name <[pl_target_name].before[:]>
    - define target <server.match_offline_player[<[pl_target_name]>]||null>
    - if <[target]> == null:
        - narrate "<&[error]>Unknown target player."
        - stop
    - if <[pl_char_name]> == x:
        - if <[target].flag[character_mode]> != ic:
            - narrate "<&[error]>Target player is not IC."
            - stop
        - define char_name <[target].flag[current_character]>
    - else:
        - define char_name x
        - define search <[pl_char_name].proc[cc_escape]>
        - foreach <[target].flag[character_cards].keys> as:poss:
            - if <[poss]> == <[search]>:
                - define char_name <[poss]>
                - foreach stop
            - else if <[poss].contains_text[<[search]>]>:
                - define char_name <[poss]>
        - if <[char_name]> == x:
            - narrate "<&[error]>Unknown target character card."
            - stop
    - define pair <[target].uuid>__char__<[char_name]>
