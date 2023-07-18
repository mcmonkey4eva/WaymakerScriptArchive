fakeop_preserver_world:
    type: world
    debug: false
    events:
        after player joins:
        - wait 5s
        - if <player.is_online> && <player.has_permission[dscript.fakeop]>:
            - adjust <player> fake_op_level:4
        after player teleports:
        - if <player.is_online> && <player.has_permission[dscript.fakeop]>:
            - adjust <player> fake_op_level:4

