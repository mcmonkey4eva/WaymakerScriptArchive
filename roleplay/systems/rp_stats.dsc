rp_stats_cleanup_world:
    type: world
    debug: false
    events:
        after player joins:
        - ratelimit <player> 12h
        - run rp_stats_cleanup_task def:<list[<player>].include[rp_stats].include_single[<player.flag[rp_stats]||<map>>]>
        on system time 10:00:
        - foreach <server.flag[rentables].keys> as:area:
            - wait 1t
            - run rp_stats_cleanup_task def:<list[server].include_single[rentables.<[area]>.rp_stats].include_single[<server.flag[rentables.<[area]>.rp_stats]||<map>>]>

rp_stats_cleanup_task:
    type: task
    debug: false
    definitions: object|flag_path|stats
    script:
    - foreach <[stats].keys||<list>> as:date:
        - define time <time[<[date].replace[_].with[/]>_0:0:0:0]>
        - if <[time].add[90d].is_before[<util.time_now>]>:
            - flag <[object]> <[flag_path]>.<[date]>:!

rp_stats_describe_task:
    type: task
    debug: false
    definitions: stats
    script:
    - define three_months 0
    - define one_month 0
    - define one_week 0
    - define one_day 0
    - foreach <[stats].keys||<list>> as:date:
        - define time <time[<[date].replace[_].with[/]>_0:0:0:0_-8]>
        - if <[time].add[1d].is_after[<util.time_now>]>:
            - define one_day:+:<[stats].get[<[date]>]>
        - if <[time].add[7d].is_after[<util.time_now>]>:
            - define one_week:+:<[stats].get[<[date]>]>
        - if <[time].add[31d].is_after[<util.time_now>]>:
            - define one_month:+:<[stats].get[<[date]>]>
        - define three_months:+:<[stats].get[<[date]>]>
    - narrate "<&[base]>RP letters, last 3 months: <&[emphasis]><[three_months]>"
    - narrate "<&[base]>RP letters, last month: <&[emphasis]><[one_month]>"
    - narrate "<&[base]>RP letters, last week: <&[emphasis]><[one_week]>"
    - narrate "<&[base]>RP letters, last day: <&[emphasis]><[one_day]>"

rp_stats_command:
    type: command
    debug: false
    name: rpstats
    permission: dscript.rpstats
    usage: /rpstats [player]
    description: Shows roleplay statistics about a player.
    script:
    - if <context.args.is_empty>:
        - narrate "<&[error]>/rpstats [player]"
        - stop
    - define target <server.match_offline_player[<context.args.first>]||null>
    - if <[target]> == null:
        - narrate "<&[error]>Unknown player '<&[emphasis]><context.args.first><&[error]>'."
        - stop
    - narrate "<&[base]>RP stats for <proc[proc_format_name].context[<[target]>|<player>]>..."
    - run rp_stats_describe_task def:<list_single[<[target].flag[rp_stats]||<map>>]>

rp_stats_top_command:
    type: command
    debug: false
    name: rpstatstop
    permission: dscript.rpstats
    usage: /rpstatstop [days]
    description: Shows roleplay statistics.
    tab completions:
        1: 1|7|14|31|90
    script:
    - if <context.args.is_empty>:
        - narrate "<&[error]>/rpstatstop [days]"
        - stop
    - define days <context.args.first>
    - if !<[days].is_integer> || <[days]> < 1 || <[days]> > 90:
        - narrate "<&[error]>Day count must be an integer number, between 1 and 90."
        - stop
    - define end_time <util.time_now.sub[<[days]>d].start_of_day>
    - define mapping <map>
    - foreach <server.players_flagged[rp_stats].filter[flag[rp_stats].keys.is_empty.not]> as:player:
        - define player_count <[player].flag[rp_stats].keys.filter_tag[<time[<[filter_value].replace[_].with[/]>_0:0:0:0_-8].is_after[<[end_time]>]>].parse_tag[<[player].flag[rp_stats.<[parse_value]>]>].sum>
        - define mapping <[mapping].with[<[player]>].as[<[player_count]>]>
    - narrate "<&[base]>===== RP Stats Top For Past <[days]> Days ====="
    - foreach <[mapping].get_subset[<[mapping].sort_by_value.keys.reverse.get[1].to[10]>].filter_tag[<[filter_value].is[more].than[0]>]> key:player as:count:
        - narrate "<&[base]><[loop_index]>) <proc[proc_format_name].context[<[player]>|<player||server>]><&[base]>: <&[emphasis]><[count]>"
