no_staff_flykick_world:
    type: world
    debug: false
    events:
        on player kicked for flying permission:dscript.staffnoflykick:
        - if <player.has_permission[dscript.staffnoflykick]>:
            - determine cancelled
