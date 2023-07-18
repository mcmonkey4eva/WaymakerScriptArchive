time_command:
    type: command
    name: time
    debug: false
    usage: /time [time] [global/player]
    description: Changes the time.
    permission: dscript.time
    tab completions:
        1: day|night|dawn|dusk|reset
        2: <server.online_players.filter[has_flag[vanished].not].parse[name].include[global]>
    script:
    - if <context.args.size> != 2:
        - narrate "<&[error]>/time day/night/dawn/dusk global"
        - narrate "<&[warning]>Or, <&[error]>/time [hour]h global"
        - narrate "<&[warning]>Or, <&[error]>/time [time] playernamehere <&[warning]>to only change the time for that player."
        - narrate "<&[warning]>Or, <&[error]>/time reset playernamehere <&[warning]>to reset time for that player."
        - stop
    - choose <context.args.first>:
        - case noon day:
            - define time 12000
            - define time_format noon
        - case night midnight:
            - define time 0
            - define time_format midnight
        - case dawn morning:
            - define time 6000
            - define time_format dawn
        - case dusk afternoon evening:
            - define time 18000
            - define time_format dusk
        - case reset:
            - if <context.args.size> != 2:
                - narrate "<&[error]>Can only reset time for a player."
                - stop
            - define time reset
        - default:
            - if <context.args.first.ends_with[t]> && <context.args.first.before_last[t].is_integer>:
                - define time <context.args.first.before_last[t].add[6000]>
                - define time_format "<[time].sub[6000]> ticks"
            - else if <context.args.first.ends_with[h]> && <context.args.first.before_last[h].is_decimal>:
                - define time <context.args.first.before_last[h].mul[1000]>
                - define time_format <[time].div[1000]>:00
            - else if <context.args.first.contains[:]> && <context.args.first.before[:].is_integer> && <context.args.first.after[:].is_integer>:
                - define hours <context.args.first.before[:]>
                - define minutes <context.args.first.after[:]>
                - define time <[hours].add[<[minutes].div[60]>].mul[1000]>
                - define time_format <[hours]>:<[minutes].pad_left[2].with[0]>
            - else if <context.args.first.is_decimal>:
                - define time <context.args.first.mul[1000]>
                - define time_format <[time].div[1000]>:00
            - else:
                - narrate "<&[error]>Unknown time input."
                - stop
    - if <context.args.get[2]||global> != global:
        - define player <server.match_player[<context.args.get[2]>]||null>
        - if <[player]> == null:
            - narrate "<&[error]>Unknown target player."
            - stop
        - if <[time]> == reset:
            - time player player:<[player]> reset
            - narrate "<&[base]>Reset time to default for <proc[proc_format_name].context[<[player]>|<player>]><&[base]>."
            - stop
        - time player player:<[player]> <[time].sub[6000]>t freeze
        - narrate "<&[base]>Time for <proc[proc_format_name].context[<[player]>|<player>]> set to <&[emphasis]><[time_format]><&[base]>."
        - stop
    - if !<player.has_permission[dscript.globaltime]>:
        - narrate "<&[error]>You do not have permission to set global time, you must specify a single player to change time for."
        - stop
    - time global <[time].sub[6000]>t world:<player.world>
    - narrate "<&[base]>Time set to <&[emphasis]><[time_format]><&[base]>."
