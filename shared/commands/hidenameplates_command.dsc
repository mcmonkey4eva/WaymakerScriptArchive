
hidenameplates_command:
    type: command
    debug: false
    name: hidenameplates
    permission: dscript.hidenameplates
    usage: /hidenameplates (player)
    description: Hides all nameplates for yourself or something else.
    script:
    - define player <player>
    - if !<context.args.is_empty> && <player.has_permission[dscript.hidenameplates_other]>:
        - define player <server.match_offline_player[<context.args.first>]||null>
        - if <[player]> == null:
            - narrate "<&[error]>Unknown target player."
            - stop
    - if <[player].has_flag[hidenameplates]>:
        - flag <[player]> hidenameplates:!
        - foreach <server.online_players_flagged[name_marker].exclude[<[player]>].parse[flag[name_marker]].combine.filter[is_spawned]> as:marker:
            - adjust <[player]> show_entity:<[marker]>
        - narrate "<&[base]>Nameplates reshown for <proc[proc_format_name].context[<[player]>|<player>]>."
    - else:
        - flag <[player]> hidenameplates
        - foreach <server.online_players_flagged[name_marker].exclude[<[player]>].parse[flag[name_marker]].combine.filter[is_spawned]> as:marker:
            - adjust <[player]> hide_entity:<[marker]>
        - narrate "<&[base]>Nameplates hidden for <proc[proc_format_name].context[<[player]>|<player>]>."

hidenameplates_world:
    type: world
    debug: false
    events:
        after player joins flagged:hidenameplates:
        - foreach <server.online_players_flagged[name_marker].exclude[<player>].parse[flag[name_marker]].combine.filter[is_spawned]> as:marker:
            - adjust <player> hide_entity:<[marker]>
