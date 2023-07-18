speed_command:
    type: command
    name: speed
    debug: false
    usage: /speed [speed] (player)
    description: Sets your flight or walking speed.
    permission: dscript.speed
    script:
    - if <context.args.is_empty>:
        - narrate "<&[error]>/speed [speed] (player)"
        - stop
    - if !<context.args.first.is_decimal> || <context.args.first> < 0 || <context.args.first> > 5:
        - narrate "<&[error]>Speed must be a number from 0 to 5."
        - stop
    - define target <player>
    - if <context.args.size> >= 2:
        - define target <server.match_player[<context.args.get[2]>]||null>
        - if <[target]> == null:
            - narrate "<&[error]>Unknown target player."
            - stop
    - if <[target].is_flying>:
        - adjust <[target]> fly_speed:<context.args.get[1].div[5]>
        - flag <[target]> fly_speed:<context.args.get[1].div[5]>
        - narrate "<&[base]>Set <&[emphasis]>fly<&[base]> speed to <&[emphasis]><context.args.get[1]><&[base]> for <proc[proc_format_name].context[<[target]>|<player>]>."
    - else:
        - adjust <[target]> walk_speed:<context.args.get[1].div[5]>
        - flag <[target]> walk_speed:<context.args.get[1].div[5]>
        - narrate "<&[base]>Set <&[emphasis]>walk<&[base]> speed to <&[emphasis]><context.args.get[1]><&[base]> for <proc[proc_format_name].context[<[target]>|<player>]>."

speed_world:
    type: world
    debug: false
    events:
        after player joins flagged:walk_speed:
        - adjust <player> walk_speed:<player.flag[walk_speed]>
        after player joins flagged:fly_speed:
        - adjust <player> fly_speed:<player.flag[fly_speed]>
