enderchest_command:
    type: command
    debug: false
    permission: dscript.enderchest
    name: enderchest
    usage: /enderchest (player)
    description: Views your enderchest.
    aliases:
    - ec
    script:
    - if <context.args.is_empty>:
        - define target <player>
        - narrate "<&[base]>Opening your enderchest."
    - else:
        - if !<player.has_permission[dscript.enderchest_other]>:
            - narrate "<&[error]>You do not have permission to view the enderchest of other players."
            - stop
        - define target <server.match_offline_player[<context.args.first>]||null>
        - if <[target]> == null:
            - narrate "<&[error]>Unknown target player."
            - stop
        - narrate "<&[base]>Opening enderchest of <proc[proc_format_name].context[<[target]>|<player>]>"
    - inventory open d:<[target].enderchest>
