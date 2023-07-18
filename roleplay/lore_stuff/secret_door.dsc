secret_door_world:
    type: world
    debug: false
    events:
        on player right clicks lever location_flagged:secretleverdoor:
        - if <context.location.switched>:
            - modifyblock <context.location.flag[secretleverdoor].blocks> air no_physics
        - else:
            - foreach <context.location.flag[secretleverdoor].blocks> as:block:
                - if <[block].flag[secretdoor_material].name> != air:
                    - modifyblock <[block]> <[block].flag[secretdoor_material]>
        on player right clicks block location_flagged:secretdoor_cuboid:
        - if <context.location||null> == null:
            - stop
        - if <context.location.has_flag[secretdoor_noclick]>:
            - stop
        - modifyblock <context.location.flag[secretdoor_cuboid].blocks> air no_physics
        - foreach <context.location.flag[secretdoor_cuboid].blocks> as:block:
            - flag <[block]> secretdoor_noreset duration:<context.location.flag[secretdoor_time].as[duration].add[10t]>
            - chunkload <[block]> duration:<context.location.flag[secretdoor_time].as[duration].add[10s]>
        - wait <context.location.flag[secretdoor_time]>
        - foreach <context.location.flag[secretdoor_cuboid].blocks> as:block:
            - if <[block].flag[secretdoor_material].name> != air:
                - modifyblock <[block]> <[block].flag[secretdoor_material]>

secretleverdoorify:
    type: command
    name: secretleverdoorify
    debug: false
    usage: /secretleverdoorify
    description: Secret-door-ifies a secret door with a lever what you're facing at.
    permission: dscript.secretdoorify
    script:
    - if !<player.has_flag[seltool_selection]>:
        - narrate "<&[error]>You must select an area with <&[warning]>/seltool <&[error]>to use this command."
        - stop
    - if <player.cursor_on.material.name> != lever:
        - narrate "<&[error]>You must be facing a lever."
        - stop
    - foreach <player.flag[seltool_selection].blocks> as:block:
        - flag <[block]> secretdoor_cuboid:<player.flag[seltool_selection]>
        - flag <[block]> secretdoor_noclick
        - flag <[block]> secretdoor_material:<[block].material>
        - flag <[block]> secretdoor_lever:<player.cursor_on.block>
    - flag <player.cursor_on.block> secretleverdoor:<player.flag[seltool_selection]>
    - narrate <&[base]>Secretleverdoorified!

secretdoorify:
    type: command
    name: secretdoorify
    debug: false
    usage: /secretdoorify [time]
    description: Secret-door-ifies a secret door.
    permission: dscript.secretdoorify
    script:
    - if <context.args.is_empty>:
        - narrate "<&[error]>/secretdoorify [time] <&[warning]>- use /seltool to select a door region"
        - stop
    - if <duration[<context.args.first>]||null> == null:
        - narrate "<&[error]>That duration is not valid."
        - stop
    - if !<player.has_flag[seltool_selection]>:
        - narrate "<&[error]>You must select an area with <&[warning]>/seltool <&[error]>to use this command."
        - stop
    - foreach <player.flag[seltool_selection].blocks> as:block:
        - flag <[block]> secretdoor_cuboid:<player.flag[seltool_selection]>
        - flag <[block]> secretdoor_time:<context.args.get[1]>
        - flag <[block]> secretdoor_material:<[block].material>
    - narrate <&[base]>Secretdoorified!

deletesecretdoor_command:
    type: command
    name: deletesecretdoor
    debug: false
    usage: /deletesecretdoor
    description: Deletes a secret door near you.
    permission: dscript.secretdoorify
    script:
    - define cuboid <player.location.flag[secretdoor_cuboid]||<player.cursor_on.flag[secretdoor_cuboid]||null>>
    - if <[cuboid]> == null:
        - narrate "<&[error]>You are neither inside of nor aiming at a secret door."
        - stop
    - foreach <[cuboid].blocks> as:block:
        - flag <[block]> secretdoor_cuboid:!
        - flag <[block]> secretdoor_time:!
        - flag <[block]> secretdoor_material:!
        - if <[block].has_flag[secretdoor_lever]>:
            - flag <[block].flag[secretdoor_lever]> secretleverdoor:!
    - narrate "<&[base]>Secret door <&[emphasis]>from <[cuboid].bounding_box.min.simple> to <[cuboid].bounding_box.max.simple><&[base]> deleted."
