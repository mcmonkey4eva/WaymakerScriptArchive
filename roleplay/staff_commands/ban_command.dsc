ban_command:
    type: command
    debug: false
    name: ban
    usage: /ban [player] [duration] [reason]
    description: Bans a player for a given duration and given reason.
    permission: dscript.ban
    script:
    - if <context.args.size> < 3:
        - narrate "<&[error]>/ban [player] [duration] [reason]"
        - narrate "<&[error]>Duration can be like <&[emphasis]>5m<&[error]> for 5 minutes, or <&[emphasis]>2d<&[error]> for 2 days, etc."
        - stop
    - define target <server.match_offline_player[<context.args.get[1]>]||null>
    - if <[target]> == null:
        - narrate "<&[error]>Unknown target player."
        - stop
    - if <[target].name> != <context.args.get[1]>:
        - narrate "<&[error]>Please type the exact player name to avoid mistakes with the warning command."
        - stop
    - define duration <context.args.get[2].as[duration]||null>
    - if <[duration]> == null || <[duration].in_seconds> < 1:
        - narrate "<&[error]>Invalid ban duration."
        - stop
    - define reason <context.raw_args.after[ ].after[ ]>
    - define embed_reason "BANNED for <[duration].formatted>: <[reason]>"
    - flag <[target]> warnings:->:<map.with[reason].as[<[embed_reason]>].with[creator].as[<player||Server>].with[date].as[<util.time_now>].with[type].as[<bold>Ban]>
    - define banner <player||server>
    - narrate "<proc[proc_format_name].context[<[banner]>|<player>]><bold> BANNED <proc[proc_format_name].context[<[target]>|<player>]> for <&[emphasis]><[duration].formatted><&[base]> with reason: <&f><[reason]>" targets:<server.online_players.filter[has_permission[dscript.ban]]> per_player
    - ban add <[target]> reason:<[reason]> duration:<[duration]> "source:Staff Ban Command"

unban_command:
    type: command
    debug: false
    name: unban
    usage: /unban [player]
    description: unban a banned player.
    permission: dscript.ban
    script:
    - if <context.args.is_empty>:
        - narrate "<&[error]>/unban [player]"
        - stop
    - define target <server.match_offline_player[<context.args.get[1]>]||null>
    - if <[target]> == null:
        - narrate "<&[error]>Unknown target player."
        - stop
    - if !<[target].is_banned>:
        - narrate "<proc[proc_format_name].context[<[target]>]> is not banned."
        - stop
    - define unbanner <player||server>
    - narrate "<proc[proc_format_name].context[<[unbanner]>|<player>]> unbanned <proc[proc_format_name].context[<[target]>]>." targets:<server.online_players.filter[has_permission[dscript.ban]]> per_player
    - ban remove <[target]>
