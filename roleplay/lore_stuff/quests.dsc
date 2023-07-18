
quest_arg_2_tabcomplete:
    type: procedure
    debug: false
    definitions: args
    script:
    - if !<player.has_permission[dscript.quests_admin]>:
        - determine <server.flag[quests].filter_tag[<[filter_value.everybody]>].keys.include[<player.flag[quests.current].parse[unescaped]||<list>>]||<list>>
    - choose <[args].get[1]>:
        - case create new:
            - determine <script[quests_command].data_key[data.types]>
    - determine <server.flag[quests].keys.parse[unescaped]>

quest_arg_3_tabcomplete:
    type: procedure
    debug: false
    definitions: args
    script:
    - if !<player.has_permission[dscript.quests_admin]>:
        - determine <list>
    - choose <[args].get[1]>:
        - case type:
            - determine <script[quests_command].data_key[data.types]>
        - case difficulty:
            - determine <script[quests_command].data_key[data.difficulties]>
        - case create new:
            - determine <script[quests_command].data_key[data.difficulties]>
        - case give remove:
            - determine <server.online_players.filter[has_flag[vanished].not].parse[name]>
        - case objective:
            - determine add|remove|complete|uncomplete|list
    - determine <list>

quest_arg_4_tabcomplete:
    type: procedure
    debug: false
    definitions: args
    script:
    - if !<player.has_permission[dscript.quests_admin]>:
        - determine <list>
    - choose <[args].get[1]>:
        - case objective:
            - determine <server.flag[quests.<[args].get[2].escaped>.objectives].keys||<list>>
    - determine <list>

quests_command:
    type: command
    debug: false
    name: quests
    aliases:
    - quest
    - q
    - qb
    - questbook
    description: Manages the quest system.
    usage: /quests help
    permission: dscript.quests
    tab completions:
        1: <player.has_permission[dscript.quests_admin].if_true[create|delete|name|type|difficulty|description|objective|rewards|everybody|give|remove|complete|uncomplete|list|info|book|focus].if_false[book|focus]>
        2: <context.args.proc[quest_arg_2_tabcomplete]>
        3: <context.args.proc[quest_arg_3_tabcomplete]>
        4: <context.args.proc[quest_arg_4_tabcomplete]>
    data:
        types: Main|World|Magic|Artifact|Event|Mini|Dungeon
        difficulties: Intro|Very_Easy|Easy|Normal|Hard|Very_Hard|Deathwish
    script:
    - choose <context.args.first.if_null[<list[qb|questbook].contains[<context.alias>].if_true[book].if_false[help]>]>:
        - case create new:
            - if !<player.has_permission[dscript.quests_admin]>:
                - narrate "<&[error]>You are not allowed to use this."
                - stop
            - if <context.args.size> < 4:
                - narrate "<&[error]>/quest create [type (<script.data_key[data.types].as[list].comma_separated>)] [difficulty (<script.data_key[data.difficulties].as[list].comma_separated>)] [name] <&[warning]>- Creates a new quest."
                - stop
            - define quest_name <context.args.get[4].to[last].separated_by[_].parse_color.strip_color.escaped>
            - if <server.has_flag[quests.<[quest_name]>]>:
                - narrate "<&[error]>A quest by that name already exists."
                - stop
            - if !<list[<script.data_key[data.types]>].contains[<context.args.get[2]>]>:
                - narrate "<&[error]>Unknown quest type given. (<script.data_key[data.types].as[list].comma_separated>)"
                - stop
            - if !<list[<script.data_key[data.difficulties]>].contains[<context.args.get[3]>]>:
                - narrate "<&[error]>Unknown quest difficulty given. (<script.data_key[data.difficulties].as[list].comma_separated>)"
                - stop
            - definemap quest_data players:<list> everybody:false name:<context.args.get[4].to[last].space_separated.parse_color> type:<context.args.get[2]> difficulty:<context.args.get[3]> rewards:<list> completed:false objectives:<map> description:<list[None]>
            - flag server quests.<[quest_name]>:<[quest_data]>
            - narrate "<&[base]>Quest <&[emphasis]><[quest_data.name]><&[base]> created."
        - case name:
            - if !<player.has_permission[dscript.quests_admin]>:
                - narrate "<&[error]>You are not allowed to use this."
                - stop
            - if <context.args.size> < 3:
                - narrate "<&[error]>/quest name [old name] [new name] <&[warning]>- Changes the name of a quest."
                - stop
            - inject match_quest_name_task
            - define new_name <context.args.get[3].to[last].separated_by[_].parse_color.strip_color.escaped>
            - if <server.has_flag[quests.<[new_name]>]>:
                - narrate "<&[error]>A quest by that name already exists."
                - stop
            - define quest_data.name <context.args.get[3].to[last].space_separated.parse_color>
            - flag server quests.<[quest_name]>:!
            - flag server quests.<[new_name]>:<[quest_data]>
            - foreach <[quest_data.players]> as:player:
                - flag <[player]> quests.current:<-:<[quest_name]>
                - flag <[player]> quests.current:->:<[new_name]>
                - if <[player].flag[quests.focused]> == <[quest_name]>:
                    - flag <[player]> quests.focused:<[new_name]>
            - narrate "<&[base]>Quest renamed to <&[emphasis]><[quest_data.name]><&[base]>."
        - case delete:
            - if !<player.has_permission[dscript.quests_admin]>:
                - narrate "<&[error]>You are not allowed to use this."
                - stop
            - if <context.args.size> < 2:
                - narrate "<&[error]>/quest delete [name] <&[warning]>- Deletes an existing quest."
                - stop
            - inject match_quest_name_task
            - flag server quests.<[quest_name]>:!
            - foreach <[quest_data.players]> as:player:
                - flag <player[<[player]>]> quests.current:<-:<[quest_name]>
                - if <[player].flag[quests.focused]||null> == <[quest_name]>:
                    - flag <player[<[player]>]> quests.focused:!
            - narrate "<&[base]>Quest <&[emphasis]><[quest_data.name]><&[base]> deleted."
        - case type:
            - if !<player.has_permission[dscript.quests_admin]>:
                - narrate "<&[error]>You are not allowed to use this."
                - stop
            - if <context.args.size> < 3:
                - narrate "<&[error]>/quest type [name] [type (<script.data_key[data.types].as[list].comma_separated>)] <&[warning]>- Changes the type of a quest."
                - stop
            - inject match_quest_name_task
            - if !<list[<script.data_key[data.types]>].contains[<context.args.get[3]>]>:
                - narrate "<&[error]>Unknown quest type given. (<script.data_key[data.types].as[list].comma_separated>)"
                - stop
            - flag server quests.<[quest_name]>.type:<context.args.get[3]>
            - narrate "<&[base]>Quest <&[emphasis]><[quest_name].unescaped><&[base]> type changed to <&[emphasis]><context.args.get[3]><&[base]>."
        - case difficulty:
            - if !<player.has_permission[dscript.quests_admin]>:
                - narrate "<&[error]>You are not allowed to use this."
                - stop
            - if <context.args.size> < 3:
                - narrate "<&[error]>/quest difficulty [name] [difficulty (<script.data_key[data.difficulties].as[list].comma_separated>)] <&[warning]>- Changes the difficulty of a quest."
                - stop
            - inject match_quest_name_task
            - if !<list[<script.data_key[data.difficulties]>].contains[<context.args.get[3]>]>:
                - narrate "<&[error]>Unknown quest difficulty given. (<script.data_key[data.difficulties].as[list].comma_separated>)"
                - stop
            - flag server quests.<[quest_name]>.difficulty:<context.args.get[3]>
            - narrate "<&[base]>Quest <&[emphasis]><[quest_name].unescaped><&[base]> difficulty changed to <&[emphasis]><context.args.get[3]><&[base]>."
        - case description desc d:
            - if !<player.has_permission[dscript.quests_admin]>:
                - narrate "<&[error]>You are not allowed to use this."
                - stop
            - if <context.args.size> < 2:
                - narrate "<&[error]>/quest description [name] [...] <&[warning]>- Changes the description of a quest."
                - stop
            - inject match_quest_name_task
            - define description <[quest_data.description]>
            - run multi_line_edit_tool def.args:<context.args.get[3].to[last]> def.orig_lines:<[description]> "def.cmd_prefix:/quest description [name]" def.wrap_len:99999 def.raw_args:<context.raw_args.after[ ].after[ ].parse_color> def.def_color:<&f> save:edited
            - define description <entry[edited].created_queue.determination.first>
            - flag server quests.<[quest_name]>.description:<[description]>
        - case objective obj o:
            - if !<player.has_permission[dscript.quests_admin]>:
                - narrate "<&[error]>You are not allowed to use this."
                - stop
            - if <context.args.size> < 3:
                - narrate "<&[error]>/quest objective [name] add [objective-name] [description] <&[warning]>- Adds an objective to a quest."
                - narrate "<&[error]>/quest objective [name] remove [objective-name] <&[warning]>- Removes an objective from a quest."
                - narrate "<&[error]>/quest objective [name] complete [objective-name] <&[warning]>- Marks a quest's objective as complete."
                - narrate "<&[error]>/quest objective [name] uncomplete [objective-name] <&[warning]>- Marks a quest's objective as not-yet-complete."
                - narrate "<&[error]>/quest objective [name] list <&[warning]>- Shows all objectives currently on the quest."
                - stop
            - inject match_quest_name_task
            - define objectives <[quest_data.objectives]>
            - choose <context.args.get[3]>:
                - case add:
                    - if <context.args.size> < 5:
                        - narrate "<&[error]>/quest objective [name] add [objective-name] [description] <&[warning]>- Adds an objective to a quest."
                        - stop
                    - define obj_name <context.args.get[4].escaped>
                    - if <[objectives].contains[<[obj_name]>]>:
                        - narrate "<&[error]>That objective name already exists."
                        - stop
                    - definemap obj_data description:<context.args.get[5].to[last].space_separated.parse_color> complete:false
                    - flag server quests.<[quest_name]>.objectives.<[obj_name]>:<[obj_data]>
                    - narrate "<&[base]>Added objective <&[emphasis]><[obj_name].unescaped><&[base]> to quest <&[emphasis]><[quest_data.name]><&[base]>."
                - case remove:
                    - if <context.args.size> < 4:
                        - narrate "<&[error]>/quest objective [name] remove [objective-name] <&[warning]>- Removes an objective from a quest."
                        - stop
                    - define obj_name <context.args.get[4].escaped>
                    - if !<[objectives].contains[<[obj_name]>]>:
                        - narrate "<&[error]>Unknown objective name given."
                        - stop
                    - flag server quests.<[quest_name]>.objectives.<[obj_name]>:!
                    - narrate "<&[base]>Removed objective <&[emphasis]><[obj_name].unescaped><&[base]> from quest <&[emphasis]><[quest_data.name]><&[base]>."
                - case complete:
                    - if <context.args.size> < 4:
                        - narrate "<&[error]>/quest objective [name] complete [objective-name] <&[warning]>- Marks a quest's objective as complete."
                        - stop
                    - define obj_name <context.args.get[4].escaped>
                    - if !<[objectives].contains[<[obj_name]>]>:
                        - narrate "<&[error]>Unknown objective name given."
                        - stop
                    - if <[objectives.<[obj_name]>.complete]>:
                        - narrate "<&[error]>That objective is already complete."
                        - stop
                    - flag server quests.<[quest_name]>.objectives.<[obj_name]>.complete:true
                    - narrate "<&[base]>Marked objective <&[emphasis]><[obj_name].unescaped><&[base]> in quest <&[emphasis]><[quest_data.name]><&[base]> as complete."
                    - if !<[objectives].values.filter[get[complete].not].any>:
                        - narrate "<&[base]>All objectives for quest <&[emphasis]><[quest_data.name]><&[base]> are now complete! To complete the quest itself, use <&[warning]>/quest complete <[quest_name].unescaped>"
                - case uncomplete:
                    - if <context.args.size> < 4:
                        - narrate "<&[error]>/quest objective [name] uncomplete [objective-name] <&[warning]>- Marks a quest's objective as not-yet-complete."
                        - stop
                    - define obj_name <context.args.get[4].escaped>
                    - if !<[objectives].contains[<[obj_name]>]>:
                        - narrate "<&[error]>Unknown objective name given."
                        - stop
                    - if !<[objectives.<[obj_name]>.complete]>:
                        - narrate "<&[error]>That objective already is not marked as complete."
                        - stop
                    - flag server quests.<[quest_name]>.objectives.<[obj_name]>.complete:false
                    - narrate "<&[base]>Marked objective <&[emphasis]><[obj_name].unescaped><&[base]> in quest <&[emphasis]><[quest_data.name]><&[base]> as not-yet-complete."
                - case list:
                    - narrate "<&[base]>Current objectives for quest <&[emphasis]><[quest_data.name]><&[base]>:"
                    - foreach <[objectives]> key:obj_name as:obj_data:
                        - narrate "<&[emphasis]><[loop_index]><&[base]>) <&7><[obj_name].unescaped><&7> (<[obj_data.complete].if_true[<&[emphasis]>Complete].if_false[<&[warning]>Incomplete]><&7>): <&[base]><[obj_data.description]>"
                - default:
                    - narrate "<&[error]>/quest objective [name] add [objective-name] [description] <&[warning]>- Adds an objective to a quest."
                    - narrate "<&[error]>/quest objective [name] remove [objective-name] <&[warning]>- Removes an objective from a quest."
                    - narrate "<&[error]>/quest objective [name] complete [objective-name] <&[warning]>- Marks a quest's objective as complete."
                    - narrate "<&[error]>/quest objective [name] uncomplete [objective-name] <&[warning]>- Marks a quest's objective as not-yet-complete."
                    - narrate "<&[error]>/quest objective [name] list <&[warning]>- Shows all objectives currently on the quest."
        - case rewards reward:
            - if !<player.has_permission[dscript.quests_admin]>:
                - narrate "<&[error]>You are not allowed to use this."
                - stop
            - if <context.args.size> < 2:
                - narrate "<&[error]>/quest rewards [name] <&[warning]>- Opens the rewards GUI for the quest."
                - stop
            - inject match_quest_name_task
            ### TODO: Rewards GUI
        - case everybody:
            - if !<player.has_permission[dscript.quests_admin]>:
                - narrate "<&[error]>You are not allowed to use this."
                - stop
            - if <context.args.size> < 2:
                - narrate "<&[error]>/quest everybody [name] <&[warning]>- Toggles whether the quest is given to everyone."
                - stop
            - inject match_quest_name_task
            - if <[quest_data.everybody]>:
                - flag server quests.<[quest_name]>.everybody:false
                - narrate "<&[base]>Quest <&[emphasis]><[quest_data.name]><&[base]> is no longer available to everybody."
            - else:
                - flag server quests.<[quest_name]>.everybody:true
                - announce "<&[base]>Quest <&[emphasis]><[quest_data.name]><&[base]> is now available to everybody! Check your <element[<&[clickable]>/questbook].on_click[/questbook].on_hover[Click to run /questbook]> for details."
                - flag <server.online_players> quests.notified:->:<[quest_name]>
        - case give:
            - if !<player.has_permission[dscript.quests_admin]>:
                - narrate "<&[error]>You are not allowed to use this."
                - stop
            - if <context.args.size> < 3:
                - narrate "<&[error]>/quest give [name] [player] <&[warning]>- Adds a player to the quest."
                - stop
            - inject match_quest_name_task
            - define target <server.match_offline_player[<context.args.get[3]>]||null>
            - if <[target]> == null:
                - narrate "<&[error]>Unknown player '<&[emphasis]><context.args.get[3]><&[error]>'."
                - stop
            - if <[quest_data.players].contains[<[target].uuid>]>:
                - narrate "<&[error]>That player is already on that quest."
                - stop
            - flag server quests.<[quest_name]>.players:->:<[target].uuid>
            - flag <[target]> quests.current:->:<[quest_name]>
            - narrate "<&[base]>Added player <proc[proc_format_name].context[<[target]>|<player>]> to quest <&[emphasis]><[quest_data.name]><&[base]>."
            - if <[target].is_online>:
                - narrate "<&[base]>You are now on quest <&[emphasis]><[quest_data.name]><&[base]>. Check your <element[<&[clickable]>/questbook].on_click[/questbook].on_hover[Click to run /questbook]> for details." targets:<[target]>
                - flag <player> quests.notified:->:<[quest_name]>
            - else:
                - flag <[target]> quest_notify_join:->:<[quest_name]>
        - case remove:
            - if !<player.has_permission[dscript.quests_admin]>:
                - narrate "<&[error]>You are not allowed to use this."
                - stop
            - if <context.args.size> < 3:
                - narrate "<&[error]>/quest remove [name] [player] <&[warning]>- Removes a player from the quest."
                - stop
            - inject match_quest_name_task
            - define target <server.match_offline_player[<context.args.get[3]>]||null>
            - if <[target]> == null:
                - narrate "<&[error]>Unknown player '<&[emphasis]><context.args.get[3]><&[error]>'."
                - stop
            - if !<[quest_data.players].contains[<[target].uuid>]>:
                - narrate "<&[error]>That player isn't on that quest."
                - stop
            - flag server quests.<[quest_name]>.players:<-:<[target].uuid>
            - flag <[target]> quests.current:<-:<[quest_name]>
            - if <[target].flag[quests.focused]||null> == <[quest_name]>:
                - flag <[target]> quests.focused:!
            - narrate "<&[base]>Added player <proc[proc_format_name].context[<[target]>|<player>]> to quest <&[emphasis]><[quest_data.name]><&[base]>."
            - if <[target].is_online>:
                - narrate "<&[base]>You are no longer on quest <&[emphasis]><[quest_data.name]><&[base]>." targets:<[target]>Z
            - else:
                - flag <[target]> quest_notify_leave:->:<[quest_name]>
        - case complete:
            - if !<player.has_permission[dscript.quests_admin]>:
                - narrate "<&[error]>You are not allowed to use this."
                - stop
            - if <context.args.size> < 2:
                - narrate "<&[error]>/quest complete [name] <&[warning]>- Completes the quest and distributes rewards."
                - stop
            - inject match_quest_name_task
            - if <[quest_data.completed]>:
                - narrate "<&[error]>Quest <&[emphasis]><[quest_data.name]><&[base]> is already completed."
                - stop
            - flag server quests.<[quest_name]>.completed:true
            ### TODO: Distribute rewards
            - narrate "<&[base]>Completed quest <&[emphasis]><[quest_data.name]><&[base]>."
        - case uncomplete:
            - if !<player.has_permission[dscript.quests_admin]>:
                - narrate "<&[error]>You are not allowed to use this."
                - stop
            - if <context.args.size> < 2:
                - narrate "<&[error]>/quest uncomplete [name] <&[warning]>- Un-completes a quest, allowing it to be redone."
                - stop
            - inject match_quest_name_task
            - if !<[quest_data.completed]>:
                - narrate "<&[error]>Quest <&[emphasis]><[quest_data.name]><&[base]> already isn't completed."
                - stop
            - flag server quests.<[quest_name]>.completed:false
            - narrate "<&[base]>Un-Completed quest <&[emphasis]><[quest_data.name]><&[base]>."
        - case list:
            - if !<player.has_permission[dscript.quests_admin]>:
                - narrate "<&[error]>You are not allowed to use this."
                - stop
            - narrate "<&[warning]>Non-Completed Quests: <&[emphasis]><server.flag[quests].values.filter_tag[<[filter_value.completed].not>].parse_tag[<[parse_value.name].on_click[/quests info <[parse_value.name]>]>].formatted||None>"
            - narrate "<&[base]>Completed Quests: <&[emphasis]><server.flag[quests].values.filter_tag[<[filter_value.completed]>].parse_tag[<[parse_value.name].on_click[/quests info <[parse_value.name]>]>].formatted||None>"
        - case info:
            - if !<player.has_permission[dscript.quests_admin]>:
                - narrate "<&[error]>You are not allowed to use this."
                - stop
            - if <context.args.size> < 2:
                - narrate "<&[error]>/quest info [name] <&[warning]>- Shows information on the quest."
                - stop
            - inject match_quest_name_task
            - narrate "<&[base]>=== Quest <&[emphasis]><[quest_data.name]><&[base]> ==="
            - narrate "<&[base]>Type: <&[emphasis]><[quest_data.type]>"
            - narrate "<&[base]>Difficulty: <&[emphasis]><[quest_data.difficulty]>"
            - narrate "<&[base]>Description: <&[emphasis]><[quest_data.description].separated_by[<n>]>"
            - narrate "<&[base]>Objectives: <&[emphasis]><[quest_data.objectives].size>"
            - narrate "<&[base]>Completed: <&[emphasis]><[quest_data.completed]>"
            - narrate "<&[base]>For everybody: <&[emphasis]><[quest_data.everybody]>"
            - narrate "<&[base]>Rewards: <&[emphasis]><[quest_data.rewards].size>"
            - narrate "<&[base]>Players: <&[emphasis]><[quest_data.players].parse_tag[<proc[proc_format_name].context[<[parse_value].as[player]>|<player>]>].formatted||None>"
        - case work focus:
            - if <context.args.size> < 2:
                - narrate "<&[error]>/quest focus [name] <&[warning]>- Focuses a specific quest to work on."
                - stop
            - inject match_quest_name_task
            - if !<player.flag[quests.current].contains[<[quest_name]>]> && !<[quest_data.everybody]>:
                - narrate "<&[error]>You are not on any such quest."
                - stop
            - flag player quests.focused:<[quest_name]>
            - flag player quests.current:<player.flag[quests.current].exclude[<[quest_name]>].insert[<[quest_name]>].at[1]>
            - narrate "<&[base]>You are now focused on quest <&[emphasis]><[quest_data.name]><&[base]>."
        - case book:
            - define current_quests <list>
            - define completed_quests <list>
            - if <player.has_flag[quests.focused]>:
                - define quest <server.flag[quests.<player.flag[quests.focused]>]||null>
                - if <[quest]> == null:
                    - flag player quests.focused:!
                - else:
                    - define current_quests:->:<player.flag[quests.focused]>
            - foreach <player.flag[quests.current].exclude[<player.flag[quests.focused]||>]||<list>> as:quest_name:
                - define quest <server.flag[quests.<[quest_name]>]||null>
                - if <[quest]> != null:
                    - if <[quest.completed]>:
                        - define completed_quests:->:<[quest_name]>
                    - else:
                        - define current_quests:->:<[quest_name]>
            - define current_quests:|:<[completed_quests]>
            - flag <player> quests.current:<[current_quests]>
            - define current_quests:|:<server.flag[quests].filter_tag[<[filter_value.everybody]>].keys.exclude[<[current_quests]>]>
            - define book <item[quest_book_item]>
            - define page_one "<&[book_base]>=== Quests ===<n>"
            - define last_list_page <[current_quests].size.add[1].div[6].round_up>
            - define quest_listing <list>
            - define quest_pages <list>
            - foreach <[current_quests]> as:quest_name:
                - define quest <server.flag[quests.<[quest_name]>]>
                - define "quest_listing:->:<&[book_base]><&[book_emphasis]><[loop_index]><&[book_base]>) <[quest.completed].if_true[(COMPLETED) ].if_false[]><element[<&[book_emphasis]><[quest.name]>].on_click[<[last_list_page].add[<[loop_index].mul[2].sub[1]>]>].type[change_page].on_hover[Click to view]>"
                - define objective_info <n><[quest.objectives].values.sort_by_number[get[complete].if_true[0].if_false[1]].parse[proc[proc_quest_obj_describe]].separated_by[<n>]>
                - if <[objective_info]> == <n>:
                    - define objective_info " <&[emphasis]>None specified"
                - define quest_header "<&[book_base]>== <[quest.completed].if_true[(COMPLETED) ].if_false[]>Quest <&[book_emphasis]><[quest.name]><&[book_base]> ==<n>"
                - define "quest_pages:->:<[quest_header]><&[book_base]>Description: <&[book_emphasis]><[quest.Description].separated_by[<n>]><n><&[book_base]>Objectives:<[objective_info]>"
                - define "quest_pages:->:<[quest_header]><&[book_base]>Type: <&[book_emphasis]><[quest.type]><n><&[book_base]>Difficulty: <&[book_emphasis]><[quest.difficulty]><n><&[book_base]>Completed: <&[book_emphasis]><[quest.completed].if_true[Yes].if_false[<&[book_warning]>No]><n><&[book_base]>For everybody: <&[book_emphasis]><[quest.everybody].if_true[Yes].if_false[No]><n><&[book_base]>Players: <&[book_emphasis]><[quest.players].parse_tag[<player[<[parse_value]>].name>].formatted||None>"
            - adjust def:book book_pages:<list[<[page_one]>].include[<[quest_listing]>].sub_lists[6].parse[separated_by[<n>]].include[<[quest_pages]>]>
            - adjust <player> show_book:<[book]>
        - default:
            - if <player.has_permission[dscript.quests_admin]>:
                - narrate "<&[error]>/quest create [type] [difficulty] [name] <&[warning]>- Creates a new quest."
                - narrate "<&[error]>/quest delete [name] <&[warning]>- Deletes an existing quest."
                - narrate "<&[error]>/quest name [old name] [new name] <&[warning]>- Changes the name of a quest."
                - narrate "<&[error]>/quest type [name] [type] <&[warning]>- Changes the type of a quest."
                - narrate "<&[error]>/quest difficulty [name] [difficulty] <&[warning]>- Changes the difficulty of a quest."
                - narrate "<&[error]>/quest description [name] [...] <&[warning]>- Changes the description of a quest."
                - narrate "<&[error]>/quest objective [name] add [objective-name] [description] <&[warning]>- Adds an objective to a quest."
                - narrate "<&[error]>/quest objective [name] remove [objective-name] <&[warning]>- Removes an objective from a quest."
                - narrate "<&[error]>/quest objective [name] complete [objective-name] <&[warning]>- Marks a quest's objective as complete."
                - narrate "<&[error]>/quest objective [name] uncomplete [objective-name] <&[warning]>- Marks a quest's objective as not-yet-complete."
                - narrate "<&[error]>/quest objective [name] list <&[warning]>- Shows all objectives currently on the quest."
                - narrate "<&[error]>/quest rewards [name] <&[warning]>- Opens the rewards GUI for the quest."
                - narrate "<&[error]>/quest everybody [name] <&[warning]>- Toggles whether the quest is given to everyone."
                - narrate "<&[error]>/quest give [name] [player] <&[warning]>- Adds a player to the quest."
                - narrate "<&[error]>/quest remove [name] [player] <&[warning]>- Removes a player from the quest."
                - narrate "<&[error]>/quest complete [name] <&[warning]>- Completes the quest and distributes rewards."
                - narrate "<&[error]>/quest uncomplete [name] <&[warning]>- Un-completes a quest, allowing it to be redone."
                - narrate "<&[error]>/quest list <&[warning]>- Shows all quests on the server."
                - narrate "<&[error]>/quest info [name] <&[warning]>- Shows information on the quest."
            - narrate "<&[error]>/quest focus [name] <&[warning]>- Focuses a specific quest to work on."
            - narrate "<&[error]>/quest book <&[warning]>- Opens your quest book."

proc_quest_obj_describe:
    type: procedure
    debug: false
    definitions: objective
    script:
    - if <[objective.complete]>:
        - determine "<&[book_base]>- (Complete) <&[book_emphasis]><[objective.description]>"
    - else:
        - determine "<&[book_warning]>- (Incomplete) <&[book_emphasis]><[objective.description]>"

quest_book_item:
    type: book
    debug: false
    title: Quest Book
    author: Waymaker
    text:
    - If you can read this, report an error to staff please thanks.

match_quest_name_task:
    type: task
    debug: false
    script:
    - define quest_name <context.args.get[2].escaped>
    - if !<server.has_flag[quests.<[quest_name]>]>:
        - narrate "<&[error]>Unknown quest name specified."
        - stop
    - define quest_data <server.flag[quests.<[quest_name]>]>

quest_notif_world:
    type: world
    debug: false
    events:
        after player joins:
        - foreach <player.flag[quests.current]||<list>> as:quest_name:
            - if !<server.has_flag[quests.<[quest_name]>]>:
                - flag <player> quests.current:<-:<[quest_name]>
        - if <player.has_flag[quests.focused]> && !<server.has_flag[quests.<player.flag[quests.focused]>]>:
            - flag <player> quests.focused:!
        - wait 10s
        - if !<player.is_online>:
            - stop
        - foreach <player.flag[quest_notify_join].exclude[<player.flag[quest_notify_leave]||<list>>]||<list>> as:quest_name:
            - define quest <server.flag[quests.<[quest_name]>]||null>
            - if <[quest]> != null:
                - narrate "<&[base]>You are now on quest <&[emphasis]><[quest.name]><&[base]>. Check your <element[<&[clickable]>/questbook].on_click[/questbook].on_hover[Click to run /questbook]> for details."
                - flag <player> quests.notified:->:<[quest_name]>
        - foreach <player.flag[quest_notify_leave].exclude[<player.flag[quest_notify_join]||<list>>]||<list>> as:quest_name:
            - define quest <server.flag[quests.<[quest_name]>]||null>
            - if <[quest]> != null:
                - narrate "<&[base]>You are no longer on quest <&[emphasis]><[quest.name]><&[base]>."
        - wait 10s
        - if !<player.is_online>:
            - stop
        - flag player quest_notify_join:!
        - flag player quest_notify_leave:!
        - foreach <server.flag[quests].filter_tag[<[filter_value.everybody]>].exclude[<player.flag[quests.notified]||<list>>]> key:quest_name as:quest_data:
            - narrate "<&[base]>Quest <&[emphasis]><[quest_data.name]><&[base]> is now available to everybody! Check your <element[<&[clickable]>/questbook].on_click[/questbook].on_hover[Click to run /questbook]> for details."
            - flag <player> quests.notified:->:<[quest_name]>

### TODO: Join notif if quest rewards received
