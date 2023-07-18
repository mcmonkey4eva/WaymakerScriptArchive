float_world:
    type: world
    debug: false
    events:
        on player steps on water|seagrass|tall_seagrass|sand|sandstone|smooth_sandstone|horn_coral|fire_coral flagged:water_float:
        - if <player.has_flag[already_floating]>:
            - stop
        - define should_stop false
        - while true:
            - if !<player.has_flag[water_float]> || !<player.is_online> || !<player.is_spawned>:
                - stop
            - flag player already_floating duration:5t
            - define material <player.location.add[0,1,0].material>
            - if !<list[water|seagrass|tall_seagrass|].contains[<[material].name>]> && !<[material].waterlogged||false>:
                - define material2 <player.location.material>
                - if !<list[water|seagrass|tall_seagrass|].contains[<[material2].name>]> && !<[material2].waterlogged||false>:
                    - if <[should_stop]||false>:
                        - stop
                    - define should_stop true
            - else:
                - define should_stop false
                - if <player.velocity.y> < 0.05:
                    - adjust <player> velocity:<player.velocity.add[0,0.05,0]>
                    - if <player.eye_location.add[0,1,0]>:
                        - adjust <player> velocity:<player.velocity.add[0,0.15,0]>
            - wait 3t

float_command:
    type: command
    debug: false
    permission: dscript.float
    name: float
    usage: /float
    description: Lets you float.
    script:
    - if <player.has_flag[water_float]>:
        - flag player water_float:!
        - narrate "<&[base]>Disabled auto-floating in water."
    - else:
        - flag player water_float
        - narrate "<&[base]>Enabled auto-floating in water."
