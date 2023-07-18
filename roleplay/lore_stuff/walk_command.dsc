walk_command:
    type: command
    name: walk
    debug: false
    usage: /walk (speed)
    description: Walk slower than normal.
    permission: dscript.walk
    script:
    - if <player.walk_speed.round_to[2]> == 0.2:
        - define speed <context.args.first||0.75>
    - else:
        - define speed <context.args.first||1>
    - if !<[speed].is_decimal> || <[speed]> < 0 || <[speed]> > 1:
        - narrate "<&[error]>Speed must be a number from 0.0 to 1.0."
        - stop
    - adjust <player> walk_speed:<[speed].div[5]>
    - narrate "<&[base]>Now walking at speed <&[emphasis]><[speed]><&[base]>."

walk_speed_cmd_world:
    type: world
    debug: false
    events:
        after player joins:
        - wait 5s
        - if !<player.is_online>:
            - stop
        - if !<player.has_permission[dscript.walk]> && !<player.has_permission[dscript.walk]> && <player.walk_speed> != 0.2:
            - adjust <player> walk_speed:0.2
