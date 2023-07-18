mute_command:
    type: command
    debug: false
    name: mute
    usage: /mute [player] [duration] [reason]
    description: Mutes a player for a given duration and given reason.
    permission: dscript.mute
    script:
    - if <context.args.size> < 3:
        - narrate "<&[error]>/mute [player] [duration] [reason]"
        - narrate "<&[error]>Duration can be like <&[emphasis]>5m<&[error]> for 5 minutes, or <&[emphasis]>2d<&[error]> for 2 days, etc."
        - stop
    - define target <server.match_offline_player[<context.args.get[1]>]||null>
    - if <[target]> == null:
        - narrate "<&[error]>Unknown target player."
        - stop
    - if <[target].name> != <context.args.get[1]>:
        - narrate "<&[error]>Please type the exact player name to avoid mistakes with the mute command."
        - stop
    - define duration <context.args.get[2].as[duration]||null>
    - if <[duration]> == null || <[duration].in_seconds> < 1:
        - narrate "<&[error]>Invalid mute duration."
        - stop
    - define reason <context.raw_args.after[ ].after[ ]>
    - define embed_reason "MUTED for <[duration].formatted>: <[reason]>"
    - flag <[target]> warnings:->:<map.with[reason].as[<[embed_reason]>].with[creator].as[<player>].with[date].as[<util.time_now>].with[type].as[Mute]>
    - narrate "<proc[proc_format_name].context[<player>]> muted <proc[proc_format_name].context[<[target]>]> for <&[emphasis]><[duration].formatted><&[base]> with reason: <&f><[reason]>" targets:<server.online_players.filter[has_permission[denizen.mute]]>
    - narrate "<&[warning]>You have been muted by staff for <&[emphasis]><[duration].formatted> <&[warning]>with reason: <&f><[reason]>" player:<[target]>
    - flag <[target]> muted duration:<[duration]>

unmute_command:
    type: command
    debug: false
    name: unmute
    usage: /unmute [player]
    description: Unmutes a muted player.
    permission: dscript.mute
    script:
    - if <context.args.is_empty>:
        - narrate "<&[error]>/unmute [player]"
        - stop
    - define target <server.match_offline_player[<context.args.get[1]>]||null>
    - if <[target]> == null:
        - narrate "<&[error]>Unknown target player."
        - stop
    - if !<[target].has_flag[muted]>:
        - narrate "<&[emphasis]><[target].name><&[error]> is not muted."
        - stop
    - narrate "<proc[proc_format_name].context[<player>]> unmuted <proc[proc_format_name].context[<[target]>]>." targets:<server.online_players.filter[has_permission[denizen.mute]]>
    - narrate "<&[warning]>You have been unmuted by staff." player:<[target]>
    - flag <[target]> muted:!

mute_world:
    type: world
    debug: false
    events:
        on player chats priority:-100 flagged:muted:
        - narrate "<&[error]>Can't speak, you're muted!"
        - determine cancelled
