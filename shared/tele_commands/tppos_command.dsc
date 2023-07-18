tppos_command:
    type: command
    name: tppos
    debug: false
    aliases:
    - tpcoordinates
    - tpto
    - tpposition
    - telepos
    - teleposition
    description: Teleports you to coordinates.
    usage: /tppos [x] [y] [z] (world)
    permission: dscript.tppos
    script:
    - if <context.args.size> < 3:
        - narrate "<&[error]>/tppos [x] [y] [z] (world)"
        - stop
    - if !<context.args.get[1].is_decimal> || !<context.args.get[2].is_decimal> || !<context.args.get[3].is_decimal>:
        - narrate "<&[error]>X, Y, and Z must be numbers."
        - stop
    - if <context.args.size> == 4 && <world[<context.args.get[4]||null>]||null> == null:
        - narrate "<&[error]>Invalid world name."
        - stop
    - define location <location[<context.args.get[1]>,<context.args.get[2]>,<context.args.get[3]>,<context.args.get[4]||<player.world.name>>]>
    - narrate "<&[base]>Teleporting to <&[emphasis]><[location].simple||<&[error]>ERROR><&[base]>..."
    - teleport <player> <[location]>
