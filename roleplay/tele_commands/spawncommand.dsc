spawn_command:
    type: command
    debug: false
    name: spawn
    usage: /spawn
    description: Teleports to spawn.
    permission: dscript.spawn
    script:
    - narrate "<&[base]>Teleporting to spawn."
    - teleport <player> aurum_spawn_center
