back_handler_world:
    type: world
    debug: false
    events:
        on player teleports:
        - if <context.origin.world.name> == <context.destination.world.name> && <context.origin.distance[<context.destination>]> < 10:
            - stop
        - flag player back_location:<context.origin>
        - flag player back_time:<util.time_now>
        on player death:
        - flag player back_location:<player.location>
        - flag player back_time:<util.time_now>

back_command:
    type: command
    debug: false
    name: back
    usage: /back
    description: Teleports to your last location before teleporting.
    permission: dscript.back
    script:
    - if !<player.has_flag[back_location]>:
        - narrate "<&[error]>Nowhere to go back to."
        - stop
    - narrate "<&[base]>Going back <&[emphasis]><util.time_now.duration_since[<player.flag[back_time]>].formatted><&[base]>..."
    - define loc <player.location>
    - teleport <player> <player.flag[back_location]>
    - flag player back_Location:<[loc]>
    - flag player back_time:<util.time_now>
