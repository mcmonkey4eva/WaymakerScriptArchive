doubledoors_world:
    type: world
    debug: false
    events:
        # Use monitor to allow the event to be cancelled by any other scripts or plugins
        # But use 'on' to make the door move as immediately as possible
        on player right clicks *_door bukkit_priority:monitor:
        # Iron doors aren't opened on click
        - if <context.location.material.name> == iron_door:
            - stop
        - define doors <context.location.center.find_blocks[*_door].within[1.8].filter[material.advanced_matches[iron*].not].exclude[<context.location>].exclude[<context.location.other_block||null>]>
        - if <[doors].size> != 2:
            - stop
        - if <[doors].first.other_block> != <[doors].get[2]>:
            - stop
        - switch <[doors].first>
