statistics_top_command:
    type: command
    name: stattop
    debug: false
    usage: /stattop [stat]
    description: Shows the players with the top value in a specified statistic.
    permission: dscript.stattop
    tab completions:
        1: <server.statistic_types[untyped].parse[to_lowercase]>
    script:
    - if <context.args.is_empty>:
        - narrate "<&[error]>/stattop [statistic name]"
        - stop
    - if !<server.statistic_types[untyped].contains[<context.args.first>]>:
        - narrate "<&[error]>Unrecognized statistic type. Accepted statistic types: <&[warning]><server.statistic_types[untyped].parse[to_lowercase].formatted>"
        - stop
    - define statname <context.args.first.to_lowercase>
    - narrate "<&[base]>Your <&translate[stat.minecraft.<[statname]>]> (<[statname]>) value: <&[emphasis]><proc[format_statistic].context[<[statname]>|<player.statistic[<[statname]>]||0>]>"
    - narrate "<&[base]>==== Top players for statistic <&[emphasis]><&translate[stat.minecraft.<[statname]>]> <&[base]>===="
    - foreach <server.players.highest[statistic[<[statname]>]].count[10]> as:player:
        - narrate "<&[emphasis]><[loop_index]>) <proc[proc_format_name].context[<[player]>|<player>]><&f>: <&[emphasis]><proc[format_statistic].context[<[statname]>|<[player].statistic[<[statname]>]||0>]>"

format_statistic:
    type: procedure
    debug: false
    definitions: stat|value
    script:
    - if <[stat].ends_with[_one_cm]>:
        - if <[value]> > 500000:
            - determine <[value].div_int[100000]>km
        - else if <[value]> > 500:
            - determine <[value].div_int[500]>m
        - else:
            - determine <[value]>cm
    - choose <[stat]>:
        - case play_one_minute time_since_death time_since_rest:
            - determine <duration[<[value]>t].formatted>
        - default:
            - determine <[value]>
