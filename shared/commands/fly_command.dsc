fly_command:
    type: command
    name: fly
    debug: false
    usage: /fly (player)
    description: Gives you flight.
    permission: dscript.fly
    script:
    - define player <player>
    - if !<context.args.is_empty>:
        - define player <server.match_player[<context.args.first>]||null>
        - if <[player]> == null:
            - narrate "<&[error]>Unknown target player."
            - stop
    - if <[player].can_fly>:
        - adjust <[player]> can_fly:false
        - narrate "<&[base]>Flight disabled for <proc[proc_format_name].context[<[player]>|<player>]>."
    - else:
        - adjust <[player]> can_fly:true
        - narrate "<&[base]>Flight enabled for <proc[proc_format_name].context[<[player]>|<player>]>."

fly_world:
    type: world
    debug: false
    events:
        after player joins:
        - if <player.can_fly> && <player.gamemode> == survival:
            - adjust <player> can_fly:false
