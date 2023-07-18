nightvision_command:
    type: command
    name: nightvision
    debug: false
    aliases:
    - nv
    usage: /nightvision (player)
    description: Gives you nightvision.
    permission: dscript.nightvision
    script:
    - define player <player>
    - if !<context.args.is_empty>:
        - define player <server.match_offline_player[<context.args.first>]||null>
        - if <[player]> == null:
            - narrate "<&[error]>Unknown target player."
            - stop
    - if <[player].has_flag[nightvision]>:
        - flag <[player]> nightvision:!
        - if <[player].is_online>:
            - cast night_vision remove <[player]>
        - narrate "<&[base]>Nightvision disabled for <proc[proc_format_name].context[<[player]>|<player>]>."
    - else:
        - flag <[player]> nightvision
        - if <[player].is_online>:
            - cast night_vision hide_particles duration:30m no_icon <[player]>
        - narrate "<&[base]>Nightvision enabled for <proc[proc_format_name].context[<[player]>|<player>]>."

nightvision_world:
    type: world
    debug: false
    events:
        on delta time minutely:
        - cast night_vision <server.online_players_flagged[nightvision]> duration:30m hide_particles no_icon
