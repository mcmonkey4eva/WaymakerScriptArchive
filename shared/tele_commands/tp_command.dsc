tp_command:
    type: command
    debug: false
    name: tp
    aliases:
    - teleport
    - tpto
    usage: /tp [name]
    description: Teleports you to places.
    permission: dscript.tp
    script:
    - if <context.args.is_empty>:
        - narrate "<&[error]>/tp [name]"
        - stop
    - define first <server.match_offline_player[<context.args.first>]||null>
    - if <[first]> == null:
        - narrate "<&[error]>Unknown player '<&[emphasis]><context.args.first><&[error]>'."
        - stop
    - if <context.args.size> == 1:
        - narrate "<&[base]>Teleporting you to <proc[proc_format_name].context[<[first]>|<player>]>."
        - define location <[first].location.with_yaw[<[first].location.yaw.add[180]>].with_pitch[0]>
        - define location <[location].ray_trace[range=3]||<[location].forward[3]>>
        - define location <[location].with_yaw[<[location].yaw.add[180]>]>
        - if <[location].distance[<[first].location>]> < 0.2 || <[location].distance[<[first].location>]> > 3.5:
            - define location <[first].location>
        - teleport <player> <[location]>
    - else if <context.args.size> == 2:
        - define second <server.match_offline_player[<context.args.get[2]>]||null>
        - if <[second]> == null:
            - narrate "<&[error]>Unknown player '<&[emphasis]><context.args.get[2]><&[error]>'."
            - stop
        - if !<[first].has_flag[waymaker_verified]> && !<[second].location.is_within[aurum_spawn_safezone]>:
            - narrate "<&[error]>That player is not yet verified."
            - stop
        - narrate "<&[base]>Teleporting <proc[proc_format_name].context[<[first]>|<player>]> to <proc[proc_format_name].context[<[second]>|<player>]>."
        - if !<[first].is_online>:
            - adjust <[first]> location:<[second].location>
        - else:
            - teleport <[first]> <[second].location>
    - else:
        - narrate "<&[error]>Unknown teleport command input."
        - stop
