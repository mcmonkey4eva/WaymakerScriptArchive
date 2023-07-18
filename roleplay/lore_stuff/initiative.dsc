turn_cmd_tabcomplete_arg2:
    type: procedure
    debug: false
    definitions: args
    script:
    - choose <[args].first||>:
        - case color:
            - determine <context.args.get[2].if_null[].proc[color_tabcomplete_proc]>
        - case help:
            - determine basic|combat|advanced
        - case timer:
            - determine off|1m|5m|10m|15m
        - case attack remove transfer move:
            - define id <player.flag[turn_system_current]||null>
            - if <[id]> != null:
                - define turns <server.flag[turn_system.<[id]>]||null>
                - if <[turns]> != null:
                    - determine <[turns.players].parse[name]>
    - determine <server.online_players.filter[has_flag[vanished].not].parse[name]>

turn_command:
    type: command
    debug: false
    name: turn
    usage: /turn
    description: Rolls for initiative.
    permission: dscript.initiative
    aliases:
    - init
    - initiative
    - combat
    tab completions:
        1: new|view|complete|add|remove|transfer|move|skip|help|leave|disband|reroll|color|timer|attack|defend
        2: <context.args.proc[turn_cmd_tabcomplete_arg2]>
        default: <server.online_players.filter[has_flag[vanished].not].parse[name]>
    script:
    - choose <context.args.first||help>:
        - case new start begin create:
            - if <player.has_flag[turn_system_current]>:
                - narrate "<&[error]>You are currently in a turn-tracked encounter. You must <&[emphasis]>leave<&[error]> or <&[emphasis]>disband<&[error]> the tracker before you can start a new one."
                - stop
            - if <context.args.size> == 1:
                - narrate "<&[error]>/<context.alias> new 10 <&[warning]>- to start a turn-tracked encounter for all players in a 10-block radius"
                - narrate "<&[error]>/<context.alias> new bob joe bill <&[warning]>- to start a turn-tracked encounter with yourself and the players named bob, joe, and bill"
                - stop
            - if <context.args.size> == 2 && <context.args.get[2].is_decimal>:
                - define targets <player.location.find_players_within[<context.args.get[2]>]>
            - else:
                - define targets <context.args.get[2].to[last].parse_tag[<server.match_player[<[parse_value]>]||null>].deduplicate>
                - if <[targets].contains[null]>:
                    - narrate "<&[error]>Unknown player name(s) given."
                    - stop
                - if <[targets].filter[has_flag[turn_system_current]].any>:
                    - narrate "<&[error]>The following players cannot be added due to already being in turn-tracked encounters: <[targets].filter[has_flag[turn_system_current]].parse[name].formatted>"
                    - stop
            - define targets <[targets].filter[has_flag[turn_system_current].not].include[<player>].deduplicate>
            - if <[targets].size> == 1:
                - narrate "<&[error]>Can't roll initiative for only one person."
                - stop
            - flag server initiative_id:++
            - define id <server.flag[initiative_id]>
            - foreach <[targets]> as:target:
                - flag <[target]> turn_system_current:<[id]> duration:48h
                - flag <[target]> turn_system_roll:<util.random.int[1].to[20]>
                - flag <[target]> turn_system_color:!
                - run name_suffix_character_card player:<[target]>
                - narrate "<&7>[Initiative] <&[base]>you roll <&[emphasis]><[target].flag[turn_system_roll]>" targets:<[target]>
            - define roll <[targets].sort_by_number[flag[turn_system_roll]].reverse>
            - flag server turn_system.<[id]>.players:<[roll]>
            - flag server turn_system.<[id]>.roller:<player>
            - flag server turn_system.<[id]>.current:1
            - flag server turn_system.<[id]>.turn_start:<util.time_now.to_utc>
            - define roller <player>
            - narrate "<&7>[Initiative] <&[base]><proc[proc_format_name].context[<[roller]>|<player>]> began tracking turns for <&[emphasis]><[roll].size> <&[base]>player<[roll].size.proc[auto_s_proc]>..." targets:<[targets]> per_player
            - foreach <[targets]> as:target:
                - run turn_cmd_showcurrent_chat player:<[target]>
            - run turn_cmd_loglocal "def.message:`<player.name>` started initiative for `<[roll].parse_tag[<[parse_value].name> (<[parse_value].flag[turn_system_roll]>)].formatted>`"
            - run turn_cmd_didadvance def:<[id]>

        - case timer:
            - if <context.args.size> != 2:
                - narrate "<&[error]>/<context.alias> timer [time or 'off']"
                - stop
            - inject turn_cmd_requireowner
            - define player <player>
            - if <context.args.get[2]> == off:
                - flag server turn_system.<[id]>.timer:!
                - narrate "<&7>[Initiative] <&[base]><proc[proc_format_name].context[<[player]>|<player>]> disabled the turn timer." targets:<[turns.players]> per_player
                - run turn_cmd_loglocal "def.message:`<player.name>` disabled timer"
                - stop
            - define duration <duration[<context.args.get[2]>]||null>
            - if <[duration]> == null:
                - narrate "&<[error]>Invalid duration specified. Duration should be formatted like <&[warning]>5m<&[error]> for 5 minutes."
                - stop
            - if <[duration].in_minutes> > 60:
                - narrate "<&[error]>Turn timer can't be longer than an hour. To remove the turn timer completely, use <&[warning]>/init timer off<&[error]>."
                - stop
            - if <[duration].in_seconds> < 10:
                - narrate "<&[error]>Turn timer too short. To remove the turn timer completely, use <&[warning]>/init timer off<&[error]>."
                - stop
            - flag server turn_system.<[id]>.timer:<[duration]>
            - flag server turn_system.<[id]>.turn_start:<util.time_now.to_utc>
            - narrate "<&7>[Initiative] <&[base]><proc[proc_format_name].context[<[player]>|<player>]> set the turn timer to <&[emphasis]><[duration].formatted_words><&[base]>." targets:<[turns.players]> per_player
            - run turn_cmd_loglocal "def.message:`<player.name>` set turn timer to `<[duration].formatted>`"

        - case reroll:
            - inject turn_cmd_requireowner
            - if <context.args.get[2]||none> == confirm && <player.has_flag[turn_system_conf_reroll]>:
                - define reroller <player>
                - narrate "<&7>[Initiative] <&[base]><proc[proc_format_name].context[<[reroller]>|<player>]> re-rolls initiative for the group." targets:<[turns.players]> per_player
                - foreach <[turns.players]> as:target:
                    - flag <[target]> turn_system_roll:<util.random.int[1].to[20]>
                    - narrate "<&7>[Initiative] <&[base]>you roll <&[emphasis]><[target].flag[turn_system_roll]>" targets:<[target]>
                - define roll <[turns.players].sort_by_number[flag[turn_system_roll]].reverse>
                - flag server turn_system.<[id]>.players:<[roll]>
                - flag server turn_system.<[id]>.current:1
                - foreach <[roll]> as:target:
                    - run turn_cmd_showcurrent_chat player:<[target]>
                - run turn_cmd_loglocal "def.message:`<player.name>` rerolled initiative for `<[roll].parse_tag[<[parse_value].name> (<[parse_value].flag[turn_system_roll]>)].formatted>`"
            - else:
                - flag <player> turn_system_conf_reroll duration:10m
                - narrate "<&[base]>This will restart and reorder the current turn tracked encounter for all players. Are you sure? If so, type <&[warning]>/<context.alias> reroll confirm"

        - case view show info current:
            - inject turn_cmd_requireactive
            - run turn_cmd_showcurrent_chat

        - case color:
            - inject turn_cmd_requireactive
            - define color <context.args.get[2]||>
            - define alias "<context.alias> color"
            - inject set_color_command_extravalidate
            - if <[color]> == reset:
                - flag <player> turn_system_color:!
            - else:
                - flag <player> turn_system_color:<&color[<[color]>]>
            - narrate "<&[base]>Initiative team color updated."
            - run name_suffix_character_card

        #- case book:
        #    - inject turn_cmd_requireactive
        #    - define text <list>
        #    - define "text:->:<&7>[Initiative] <&[base]>Started by: <proc[proc_format_name].context[<[turns.roller]>|<player>]>"
        #    - foreach <[turns.players]> as:player:
        #        - if <[loop_index]> == <[turns.current]>:
        #            - define "text:->:<&[emphasis]><bold><[loop_index]><&[base]><bold>) <proc[proc_format_name].context[<[player]>|<player>]> <&[emphasis]><bold>(Current)"
        #        - else:
        #            - define "text:->:<&[emphasis]><[loop_index]><&[base]>) <proc[proc_format_name].context[<[player]>|<player>]>"
        #    - adjust <player> show_book:<item[written_book].with[book_author=Initative;book_title=Initiative].with_single[book_pages=<[text].separated_by[<n>]>]>

        - case complete done next finish finished completed:
            - inject turn_cmd_requirecurrent
            - narrate "<&[base]>Turn completed."
            - run turn_cmd_loglocal "def.message:`<player.name>` completed their turn"
            - run turn_cmd_gonext def.id:<[id]>

        - case add:
            - inject turn_cmd_requireowner
            - if <context.args.size> == 1:
                - narrate "<&[error]>/<context.alias> add 10 <&[warning]>- to add all players in a 10-block radius"
                - narrate "<&[error]>/<context.alias> add bob joe bill <&[warning]>- to add the players named bob, joe, and bill"
                - stop
            - if <context.args.size> == 2 && <context.args.get[2].is_decimal>:
                - define targets <player.location.find_players_within[<context.args.get[2]>]>
            - else:
                - define targets <context.args.get[2].to[last].parse_tag[<server.match_player[<[parse_value]>]||null>].deduplicate>
                - if <[targets].contains[null]>:
                    - narrate "<&[error]>Unknown player name(s) given."
                    - stop
            - define targets <[targets].filter[has_flag[turn_system_current].not]>
            - if <[targets].is_empty>:
                - narrate "<&[error]>No players can be added."
                - stop
            - define minimum_roll <[turns.players].parse[flag[turn_system_roll]].highest>
            - foreach <[targets]> as:target:
                - flag <[target]> turn_system_current:<[id]> duration:48h
                - flag <[target]> turn_system_roll:<[minimum_roll].add[<util.random.int[1].to[20]>]>
                - flag <[target]> turn_system_color:!
                - run name_suffix_character_card player:<[target]>
            - define roll <[targets].sort_by_number[flag[turn_system_roll]].reverse>
            - flag server turn_system.<[id]>.players:|:<[targets]>
            - define roller <player>
            - narrate "<&7>[Initiative] <&[base]><proc[proc_format_name].context[<[roller]>|<player>]> added <&[emphasis]><[roll].size> <&[base]>player<[roll].size.proc[auto_s_proc]>..." targets:<[targets].include[<[turns.players]>]> per_player
            - foreach <[targets]> as:player:
                - narrate "<&[emphasis]><[loop_index].add[<[turns.players].size>]><&[base]>) <proc[proc_format_name].context[<[player]>|<player>]> <&[emphasis]>(<[player].flag[turn_system_roll]>)" targets:<[targets].include[<[turns.players]>]> per_player
            - run turn_cmd_loglocal "def.message:`<player.name>` added players `<[roll].parse_tag[<[parse_value].name> (<[parse_value].flag[turn_system_roll]>)].formatted>`"

        - case remove:
            - inject turn_cmd_requireowner
            - if <context.args.size> != 2:
                - narrate "<&[error]>/<context.alias> remove [player]"
                - stop
            - define target <server.match_player[<context.args.get[2]>]||null>
            - if <[target]> == null:
                - narrate "<&[error]>Unknown target player."
                - stop
            - if <[target].flag[turn_system_current]||none> != <[id]>:
                - narrate "<&[error]>That player is not in your turn-tracked encounter."
                - stop
            - define remover <player>
            - narrate "<&7>[Initiative] <&[base]><proc[proc_format_name].context[<[remover]>|<player>]> removes <proc[proc_format_name].context[<[target]>|<player>]> from the turn-tracked encounter." targets:<[turns.players]> per_player
            - run turn_cmd_loglocal "def.message:`<player.name>` removes `<[target].name>` from the turn tracker"
            - run turn_cmd_removeplayer def:<[target]>

        - case transfer:
            - inject turn_cmd_requireowner
            - if <context.args.size> != 2:
                - narrate "<&[error]>/<context.alias> transfer [player]"
                - stop
            - define target <server.match_player[<context.args.get[2]>]||null>
            - if <[target]> == null:
                - narrate "<&[error]>Unknown target player."
                - stop
            - if <[target].flag[turn_system_current]||none> != <[id]>:
                - narrate "<&[error]>That player is not in your turn-tracked encounter."
                - stop
            - define old_owner <player>
            - narrate "<&7>[Initiative] <&[base]><proc[proc_format_name].context[<[old_owner]>|<player>]> transfer encounter ownership to <proc[proc_format_name].context[<[target]>|<player>]>." targets:<[turns.players]> per_player
            - run turn_cmd_loglocal "def.message:`<player.name>` transferred ownership to `<[target].name>`"
            - flag server turn_system.<[id]>.roller:<[target]>

        - case move:
            - inject turn_cmd_requireowner
            - if <context.args.size> != 3:
                - narrate "<&[error]>/<context.alias> move [player] [index]"
                - stop
            - define target <server.match_player[<context.args.get[2]>]||null>
            - if <[target]> == null:
                - narrate "<&[error]>Unknown target player."
                - stop
            - if <[target].flag[turn_system_current]||none> != <[id]>:
                - narrate "<&[error]>That player is not in your turn-tracked encounter."
                - stop
            - if !<context.args.get[3].is_integer> || <context.args.get[3]> < 1 || <context.args.get[3]> > <[turns.players].size>:
                - narrate "<&[error]>Invalid index. Index must be a number from 1 to <[turns.players].size>"
                - stop
            - define previous_index <[turns.players].find[<[target]>]>
            - flag server turn_system.<[id]>.players:<[turns.players].exclude[<[target]>].insert[<[target]>].at[<context.args.get[3]>]>
            - if <[previous_index]> < <[turns.current]> && <context.args.get[3]> >= <[turns.current]>:
                - flag server turn_system.<[id]>.current:--
            - else if <[previous_index]> > <[turns.current]> && <context.args.get[3]> <= <[turns.current]>:
                - flag server turn_system.<[id]>.current:++
            - else if <[previous_index]> == <[turns.current]>:
                - flag server turn_system.<[id]>.current:<context.args.get[3]>
            - define mover <player>
            - narrate "<&7>[Initiative] <&[base]><proc[proc_format_name].context[<[mover]>|<player>]> moved <proc[proc_format_name].context[<[target]>|<player>]> to index <&[emphasis]><context.args.get[3]>" targets:<[turns.players]> per_player
            - run turn_cmd_loglocal "def.message:`<player.name>` moved player `<[target].name>` to index `<context.args.get[3]>`"

        - case skip:
            - inject turn_cmd_requireowner
            - define current <[turns.players].get[<[turns.current]>]>
            - if <context.args.get[2]||none> == confirm && <[current].uuid> == <player.flag[turn_system_conf_skip]||none>:
                - flag <player> turn_system_conf_skip:<[current].uuid>:!
                - define skipper <player>
                - narrate "<&7>[Initiative] <&[base]><proc[proc_format_name].context[<[skipper]>|<player>]> skipped <proc[proc_format_name].context[<[current]>|<player>]>'s turn." targets:<[turns.players]> per_player
                - run turn_cmd_loglocal "def.message:`<player.name>` skipped turn for `<[current].name>`"
                - run turn_cmd_gonext def.id:<[id]>
            - else:
                - flag <player> turn_system_conf_skip:<[current].uuid> duration:10m
                - narrate "<&[base]>This will skip the turn of <proc[proc_format_name].context[<[current]>|<player>]>. Are you sure? If so, type <&[warning]>/<context.alias> skip confirm"

        - case leave:
            - inject turn_cmd_requireactive
            - define leaver <player>
            - narrate "<&7>[Initiative] <&[base]><proc[proc_format_name].context[<[leaver]>|<player>]> leaves the turn-tracked encounter." targets:<[turns.players]> per_player
            - run turn_cmd_loglocal "def.message:`<player.name>` leaves tracker"
            - run turn_cmd_removeplayer def:<player>

        - case disband:
            - inject turn_cmd_requireowner
            - if <context.args.get[2]||none> == confirm && <player.has_flag[turn_system_conf_disband]>:
                - define skipper <player>
                - narrate "<&7>[Initiative] <&[base]><proc[proc_format_name].context[<[skipper]>|<player>]> ends the encounter." targets:<[turns.players]> per_player
                - flag <[turns.players]> turn_system_current:!
                - flag <[turns.players]> turn_system_roll:!
                - foreach <[turns.players]> as:target:
                    - run name_suffix_character_card player:<[target]>
                - flag server turn_system.<[id]>:!
                - run turn_cmd_loglocal "def.message:`<player.name>` ends the encounter."
            - else:
                - flag <player> turn_system_conf_disband duration:10m
                - narrate "<&[base]>This will end the entire turn-tracked encounter and remove all players. Are you sure? If so, type <&[warning]>/<context.alias> disband confirm"

        - case attack:
            - inject turn_cmd_requirecurrent
            - if <context.args.size> < 2:
                - narrate "<&[error]>/<context.alias> attack [player]"
                - stop
            - define target <server.match_player[<context.args.get[2]>]||null>
            - if <[target]> == null:
                - narrate "<&[error]>Unknown target player to attack."
                - stop
            - if <player.flag[character_mode]> != IC:
                - narrate "<&[error]>You must swap to IC to attack."
                - stop
            - if <[target].flag[character_mode]> != IC:
                - narrate "<&[error]>Your target must swap to IC to be attacked."
                - stop
            - define cdat.item <player.item_in_hand>
            - define cdat.type <[cdat.item].flag[combat_item_type]||phys>
            - define cdat.bonus_item <[cdat.item].flag[combat_attack_bonus]||0>
            # TODO
            - narrate TODO

        - case defend:
            # TODO
            - narrate TODO

        - default:
            - if <context.args.get[2]||none> == basic:
                - narrate "<&[base]>==== Initiative Turn System Basic Help ===="
                - narrate "<&[error]>/<context.alias> view <&[warning]>- shows the current turn tracker and initiative rolls in your chat."
                - narrate "<&[error]>/<context.alias> color [color] <&[warning]>- sets your team color."
                #- narrate "<&[error]>/<context.alias> book <&[warning]>- shows the current turn tracker and initiative rolls in a book (to avoid chat clutter)."
                - narrate "<&[error]>/<context.alias> complete <&[warning]>- if it's your turn, completes your turn."
                - narrate "<&[error]>/<context.alias> leave <&[warning]>- leaves your current turn tracker."
                - narrate "<&[error]>/sidebar <&[warning]>- turns your sidebar on/off. Current turn information will be visible in your sidebar."
            - else if <context.args.get[2]||none> == combat:
                - narrate "<&[error]>/<context.alias> attack [player] <&[warning]>- (on your turn) roll your attack a player with your held item."
                - narrate "<&[error]>/<context.alias> defend <&[warning]>- (if being attacked) roll your defense against the attack."
            - else if <context.args.get[2]||none> == advanced:
                - narrate "<&[base]>==== Initiative Turn System Advanced Help ===="
                - narrate "<&[error]>/<context.alias> new [range in blocks, or player names] <&[warning]>- starts a new initiative roll + turn tracker."
                - narrate "<&[error]>/<context.alias> add [range in blocks, or player names] <&[warning]>- adds players to the end of the current turn tracker."
                - narrate "<&[error]>/<context.alias> remove [player] <&[warning]>- removes a player from your current turn tracker."
                - narrate "<&[error]>/<context.alias> timer [time or 'off'] <&[warning]>- sets the max turn time, for example <&[error]>/init timer 5m<&[warning]>."
                - narrate "<&[error]>/<context.alias> move [player] [index] <&[warning]>- moves a player's position in the current turn tracker."
                - narrate "<&[error]>/<context.alias> transfer [player] <&[warning]>- transfers ownership of the encounter to another player."
                - narrate "<&[error]>/<context.alias> skip <&[warning]>- skips another player's turn."
                - narrate "<&[error]>/<context.alias> reroll <&[warning]>- rerolls the same group, instantly restarting the turn tracked encounter."
                - narrate "<&[error]>/<context.alias> disband <&[warning]>- disbands the entire turn tracker, removing all players."
            - else:
                - narrate "<&[clickable]><element[/<context.alias> help basic].on_hover[Click Here].on_click[/<context.alias> help basic]><&[warning]> - to show basic turn-tracker usage for players"
                - narrate "<&[clickable]><element[/<context.alias> help combat].on_hover[Click Here].on_click[/<context.alias> help combat]><&[warning]> - to show help about combat commands"
                - narrate "<&[clickable]><element[/<context.alias> help advanced].on_hover[Click Here].on_click[/<context.alias> help advanced]><&[warning]> - to show advanced turn-tracker usage for DMs"

turn_cmd_loglocal:
    type: task
    debug: false
    definitions: message
    script:
    - run discord_send_message def.channel:discord_local_channel "def.message:[INITIATIVE] <[message]>"

turn_cmd_proc_current:
    type: procedure
    debug: false
    script:
    - if !<player.has_flag[turn_system_current]>:
        - determine none
    - define id <player.flag[turn_system_current]>
    - define turns <server.flag[turn_system.<[id]>]>
    - determine <[turns.players].get[<[turns.current]>]>

turn_cmd_proc_next:
    type: procedure
    debug: false
    script:
    - if !<player.has_flag[turn_system_current]>:
        - determine none
    - define id <player.flag[turn_system_current]>
    - define turns <server.flag[turn_system.<[id]>]>
    - determine <[turns.players].get[<[turns.current].mod[<[turns.players].size>].add[1]>]>

turn_cmd_proc_count_turns:
    type: procedure
    debug: false
    script:
    - if !<player.has_flag[turn_system_current]>:
        - determine Infinite
    - define id <player.flag[turn_system_current]>
    - define turns <server.flag[turn_system.<[id]>]>
    - define index <[turns.players].find[<player>]>
    - if <[index]> >= <[turns.current]>:
        - determine <[index].sub[<[turns.current]>]>
    - else:
        - determine <[turns.players].size.sub[<[turns.current]>].add[<[index]>]>

turn_cmd_requireactive:
    type: task
    debug: false
    script:
    - if !<player.has_flag[turn_system_current]>:
        - narrate "<&[error]>You are not currently in a turn-tracked encounter. You must start or join one before you can use this command."
        - stop
    - define id <player.flag[turn_system_current]>
    - define turns <server.flag[turn_system.<[id]>]>

turn_cmd_requirecurrent:
    type: task
    debug: false
    script:
    - inject turn_cmd_requireactive
    - define current <[turns.players].get[<[turns.current]>]>
    - if <player.uuid> != <[current].uuid>:
        - narrate "<&[error]>It's not your turn."
        - stop

turn_cmd_requireowner:
    type: task
    debug: false
    script:
    - inject turn_cmd_requireactive
    - if <[turns.roller].uuid> != <player.uuid> && !<player.has_permission[dscript.initative_staff]>:
        - narrate "<&[error]>You are not the creator of this encounter. Only the one who starts a roll or a staff member may use DM commands."
        - stop

turn_cmd_removeplayer:
    type: task
    debug: false
    definitions: target
    script:
    - inject turn_cmd_requireactive
    - define previous_index <[turns.players].find[<[target]>]>
    - flag server turn_system.<[id]>.players:<-:<[target]>
    - flag <[target]> turn_system_current:!
    - flag <[target]> turn_system_roll:!
    - if <[previous_index]> == <[turns.current]>:
        - flag server turn_system.<[id]>.turn_start:<util.time_now.to_utc>
        - if <[turns.current]> >= <[turns.players].size>:
            - flag server turn_system.<[id]>.current:1
        - run turn_cmd_didadvance def:<[id]>
    - else if <[previous_index]> < <[turns.current]>:
        - flag server turn_system.<[id]>.current:--
    - run name_suffix_character_card player:<[target]>
    - if <server.flag[turn_system.<[id]>.players].is_empty||true>:
        - flag server turn_system.<[id]>:!
        - stop
    - if <[turns.roller].uuid> == <[target].uuid>:
        - define new_owner <server.flag[turn_system.<[id]>.players].first>
        - flag server turn_system.<[id]>.roller:<[new_owner]>
        - narrate "<&7>[Initiative] <&[base]><proc[proc_format_name].context[<[new_owner]>|<player>]> <&[base]>is now the owner of this initiative encounter." targets:<server.flag[turn_system.<[id]>.players]> per_player
        - run turn_cmd_loglocal "def.message:`<[new_owner].name>` automatically became owner due to logout of prior owner"

turn_cmd_showcurrent_chat:
    type: task
    debug: false
    script:
    - inject turn_cmd_requireactive
    - narrate "<&[base]>==== Initative Roll Order ===="
    - foreach <[turns.players]> as:player:
        - if <[turns.roller].uuid> == <[player].uuid>:
            - define suffix " (Encounter owner)"
        - else:
            - define suffix <empty>
        - if <[loop_index]> == <[turns.current]>:
            - narrate "<&[emphasis]><bold><[loop_index]><&[base]><bold>) <proc[proc_format_name].context[<[player]>|<player>]> <&[emphasis]><bold>(<[player].flag[turn_system_roll]>) <&[emphasis]><bold>(Current)<&[emphasis]><[suffix]>"
        - else:
            - narrate "<&[emphasis]><[loop_index]><&[base]>) <proc[proc_format_name].context[<[player]>|<player>]> <&[emphasis]>(<[player].flag[turn_system_roll]>)<[suffix]>"

turn_cmd_gonext:
    type: task
    debug: false
    definitions: id
    script:
    - define turns <server.flag[turn_system.<[id]>]>
    - flag server turn_system.<[id]>.current:<[turns.current].mod[<[turns.players].size>].add[1]>
    - run turn_cmd_didadvance def.id:<[id]>
    - flag server turn_system.<[id]>.turn_start:<util.time_now.to_utc>

turn_cmd_didadvance:
    type: task
    debug: false
    definitions: id
    script:
    - define turns <server.flag[turn_system.<[id]>]>
    - define current_player <[turns.players].get[<[turns.current]>]>
    - run turn_cmd_shownext def.id:<[id]>
    - if <[current_player].flag[character_mode]> != IC && <[turns.players].filter[flag[character_mode].equals[IC]].any>:
        - run turn_cmd_loglocal "def.message:`<[current_player].name>` automatically skipped (not IC)"
        - narrate "<&7>[Initiative] <&[base]><[current_player].proc[proc_format_name].context[<player>]>'s turn was automatically skipped, as they are not IC." targets:<[turns.players]> per_player
        - run turn_cmd_gonext def.id:<[id]>

turn_cmd_shownext:
    type: task
    debug: false
    definitions: id
    script:
    - define turns <server.flag[turn_system.<[id]>]>
    - define current_turn <[turns.players].get[<[turns.current]>]>
    - define next <[turns.players].get[<[turns.current].mod[<[turns.players].size>].add[1]>]>
    - narrate "<&7>[Initiative] <&[base]>it's your turn!" targets:<[current_turn]>
    - actionbar "<&7>[Initiative] <&[base]>it's your turn!" targets:<[current_turn]>
    - playsound <[turns.players].exclude[<[current_turn]>]> sound:BLOCK_AMETHYST_BLOCK_CHIME
    - playsound <[current_turn]> sound:BLOCK_AMETHYST_CLUSTER_FALL
    - actionbar "<&7>[Initiative] <&[base]>your turn is next, after <proc[proc_format_name].context[<[current_turn]>|<player>]> is done - get ready!" targets:<[next]> per_player
    - actionbar "<&7>[Initiative] <&[base]>Turn: <proc[proc_format_name].context[<[current_turn]>|<player>]>" targets:<[turns.players].exclude[<[current_turn]>|<[next]>]> per_player
    - run turn_cmd_loglocal "def.message:`<[current_turn].name>` begins turn"

turn_cmd_world:
    type: world
    debug: false
    events:
        on player quits flagged:turn_system_current:
        - inject turn_cmd_requireactive
        - define quitter <player>
        - narrate "<&7>[Initiative] <&[base]><proc[proc_format_name].context[<[quitter]>|<player>]> leaves the turn-tracked encounter due to logging off." targets:<[turns.players]> per_player
        - run turn_cmd_loglocal "def.message:`<player.name>` leaves tracker due to logging off"
        - run turn_cmd_removeplayer def:<player>
        after player joins flagged:turn_system_current:
        - flag <player> turn_system_current:!
        - flag <player> turn_system_roll:!
        after server start:
        - flag server turn_system:!
        on delta time secondly server_flagged:turn_system:
        - foreach <server.flag[turn_system].filter_tag[<[filter_value].contains[timer]>]> key:id as:turns:
            - if <[turns.players].is_empty>:
                - flag server turn_system.<[id]>:!
                - foreach next
            - if <util.time_now.to_utc.sub[<[turns.timer]>].is_after[<[turns.turn_start]>]>:
                - define current_turn <[turns.players].get[<[turns.current]>]>
                - run turn_cmd_loglocal "def.message:`<[current_turn].name>` passed the turn timer"
                - narrate "<&7>[Initiative] <&[base]><proc[proc_format_name].context[<[current_turn]>|<player>]> went past the turn timer." targets:<[turns.players]> per_player
                - run turn_cmd_gonext def.id:<[id]>
