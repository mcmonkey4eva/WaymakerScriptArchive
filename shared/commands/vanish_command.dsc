vanish_command:
    type: command
    name: vanish
    aliases:
    - v
    usage: /vanish
    debug: false
    description: Hides yourself from people.
    permission: dscript.vanish
    script:
    - define player <player>
    - if !<context.args.is_empty>:
        - define player <server.match_offline_player[<context.args.first>]||null>
        - if <[player]> == null:
            - narrate "<&[error]>Unknown target player."
            - stop
    - if <[player].has_flag[in_disguise]> && !<[player].has_flag[vanished]>:
        - narrate "<&[error]>Cannot vanish while disguised."
        - stop
    - if <[player].has_flag[vanished]>:
        - if <[player].is_online>:
            - adjust <[player]> show_to_players
        - flag <[player]> vanished:!
        - narrate "<&[base]>Unvanished <proc[proc_format_name].context[<[player]>|<player>]>!"
    - else:
        - if <[player].is_online>:
            - adjust <[player]> hide_from_players
        - narrate "<&[base]>Vanished <proc[proc_format_name].context[<[player]>|<player>]>!"
        - flag <[player]> vanished
    - wait 1t
    - run name_suffix_character_card player:<[player]>

vanish_world:
    type: world
    debug: false
    events:
        on player joins:
        - if <player.has_flag[vanished]>:
            - adjust <player> hide_from_players
            - narrate "<&[base]>Joining silently, you are vanished."
            - determine none
        - else:
            - adjust <player> show_to_players
        on player quits:
        - if <player.has_flag[vanished]>:
            - determine none
        on server list ping:
        - determine exclude_players:<server.online_players_flagged[vanished]>
