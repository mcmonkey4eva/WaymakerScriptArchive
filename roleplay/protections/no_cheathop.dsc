anti_cheathop_world:
    type: world
    debug: false
    events:
        on player places block bukkit_priority:monitor ignorecancelled:true:
        - if <context.cancelled> && !<player.is_on_ground> && !<player.can_fly> && <player.gamemode> != creative:
            - if <player.location.below[0.2].material.name||unknown> == air || <player.location.below.block> == <context.location>:
                - teleport <player> <player.location.below[0.2]>
                - define message "] <&lt>**`<player.name>`** **MIGHT BE EXPLOITING GLITCH HOPS** at `<context.location.simple>`"
                - run discord_send_message def:<list[<server.flag[discord_logs_channel]>].include_single[<[message]>]>
            - else:
                - teleport <player> <player.location>
