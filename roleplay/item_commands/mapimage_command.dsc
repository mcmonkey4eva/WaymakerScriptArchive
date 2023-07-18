map_image_command:
    type: command
    name: mapimage
    usage: /mapimage [link]
    description: Generates a map item from an image.
    debug: false
    permission: dscript.mapimage
    script:
    - if <context.args.is_empty>:
        - narrate "<&[error]>/mapimage [link]"
        - stop
    - if !<context.args.first.ends_with[.png]>:
        - if !<context.args.first.ends_with[.gif]> || !<player.has_permission[dscript.gifmap]>:
            - narrate "<&[error]>Must be a direct link to a <&[emphasis]>.png<&[error]> image!"
            - stop
    - map new:<player.world> image:<context.args.first> resize save:image
    - run give_safe_item def.item:filled_map[map=<entry[image].created_map>]
