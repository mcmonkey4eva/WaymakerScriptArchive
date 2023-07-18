warn_command:
    type: command
    debug: false
    name: warn
    usage: /warn [player] [reason]
    description: Warns a player for doing a bad thing.
    permission: dscript.warn
    script:
    - if <context.args.size> < 2:
        - narrate "<&[error]>/warn [player] [reason]"
        - stop
    - define target <server.match_offline_player[<context.args.get[1]>]||null>
    - if <[target]> == null:
        - narrate "<&[error]>Unknown target player."
        - stop
    - if <[target].name> != <context.args.get[1]>:
        - narrate "<&[error]>Please type the exact player name to avoid mistakes with the warning command."
        - stop
    - define reason <context.raw_args.after[ ]>
    - flag <[target]> warnings:->:<map.with[reason].as[<[reason]>].with[creator].as[<player||Server>].with[date].as[<util.time_now>].with[type].as[Warning]>
    - narrate "<&[emphasis]><player.name||Server><&[base]> warned <proc[proc_format_name].context[<[target]>]> with reason: <&f><[reason]>" targets:<server.online_players.filter[has_permission[dscript.warn]]>
    - if <[target].is_online>:
        - narrate "<&[warning]>You have been warned by staff with reason: <&f><[reason]>" target:<[target]>
    - else:
        - flag <[target]> "to_show_warnings:->:<&[warning]>You have been warned by staff with reason: <&f><[reason]>"

warnings_world_message:
    type: world
    debug: false
    events:
        after player joins flagged:to_show_warnings:
        - wait 1s
        - if !<player.is_online>:
            - stop
        - foreach <player.flag[to_show_warnings]>:
            - narrate <[value]>
        - wait 10s
        - if !<player.is_online>:
            - stop
        - flag player to_show_warnings:!

removewarning_command:
    type: command
    name: removewarning
    debug: false
    usage: /removewarning [name]
    description: Removes warnings from history.
    permission: dscript.removewarning
    script:
    - if <context.args.is_empty>:
        - narrate "<&[error]>/removewarning [name]"
        - stop
    - define player <server.match_offline_player[<context.args.first>]||null>
    - if <[player]> == null:
        - narrate "<&[error]>Unknown target player."
        - stop
    - if <[player].name> != <context.args.first>:
        - narrate "<&[error]>Please verify that you typed in the EXACT username to avoid typos."
        - stop
    - if <[player].flag[warnings].is_empty||true>:
        - narrate "<&[error]>No warnings to remove."
        - stop
    - if <context.args.size> == 2:
        - define id <context.args.get[2]>
        - if !<[id].is_integer> || <[id]> < 1 || <[id]> > <[player].flag[warnings].size>:
            - narrate "<&[error]>Invalid warning ID (must be an integer from 1 to <[player].flag[warnings].size>)."
            - stop
        - narrate "<&[error]>Removing warning <[id]>: <&f><[player].flag[warnings].get[<[id]>].get[reason]>"
        - flag <[player]> warnings[<[id]>]:<-
    - foreach <[player].flag[warnings]> as:warning:
        - narrate "<&[warning]>/removewarning <[player].name> <[loop_index]><&f>: from <&[emphasis]><[warning].get[creator].name><&[warning]>: <&f><[warning].get[reason]>"
