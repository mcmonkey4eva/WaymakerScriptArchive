invisibility_command:
    type: command
    name: invisible
    debug: false
    aliases:
    - invis
    usage: /invisible
    description: Gives you invisibility (not to be confused with /vanish).
    permission: dscript.invisibility
    script:
    - define player <player>
    - if !<context.args.is_empty>:
        - define player <server.match_offline_player[<context.args.first>]||null>
        - if <[player]> == null:
            - narrate "<&[error]>Unknown target player."
            - stop
    - if <[player].has_flag[invisibility]>:
        - flag <[player]> invisibility:!
        - if <[player].is_online>:
            - cast invisibility <[player]> remove
        - narrate "<&[base]>Invisibility disabled for <proc[proc_format_name].context[<[player]>|<player>]>."
    - else:
        - flag <[player]> invisibility
        - if <[player].is_online>:
            - cast invisibility <[player]> hide_particles duration:30m no_icon
        - narrate "<&[base]>Invisibility enabled for <proc[proc_format_name].context[<[player]>|<player>]>."
    - wait 1t
    - run name_suffix_character_card player:<[player]>

invisibility_world:
    type: world
    debug: false
    events:
        on delta time minutely:
        - cast invisibility <server.online_players_flagged[invisibility]> duration:30m hide_particles no_icon
