sand_blaster_tool_item:
    type: item
    debug: false
    material: golden_sword
    display name: <yellow>Sand Blaster
    enchantments:
    - sharpness:5
    mechanisms:
        hides: all
    lore:
    - <&[base]>Blasts a ton of sand.

sand_blaster_world:
    type: world
    debug: false
    events:
        on player right clicks block with:sand_blaster_tool_item permission:dscript.sandblast:
        - if !<player.has_permission[dscript.sandblast]||false>:
            - stop
        #- ratelimit <player> 5t
        - announce to_console "<player.name> uses sand_blaster at <player.location.simple>"
        - define loc <player.cursor_on[200]||null>
        - if <[loc]> == null:
            - stop
        - modifyblock <[loc].to_ellipsoid[15,15,15].blocks[air]> sand no_physics

physics_tool_item:
    type: item
    debug: false
    material: diamond_sword
    display name: <&b>GMod Physics Gun
    enchantments:
    - sharpness:5
    mechanisms:
        hides: all
    lore:
    - <&[base]>Makes sand fall n stuff.

physics_tool_world:
    type: world
    debug: false
    events:
        on player right clicks block with:physics_tool_item permission:dscript.sandblast:
        - if !<player.has_permission[dscript.sandblast]||false>:
            - stop
        - ratelimit <player> 5t
        - announce to_console "<player.name> uses physics_tool at <player.location.simple>"
        - define loc <player.cursor_on[200]||null>
        - if <[loc]> == null:
            - stop
        - foreach <[loc].with_y[<[loc].y.max[5]>].to_ellipsoid[5,5,5].blocks> as:block:
            - define mat <[block].material>
            - modifyblock <[block]> air
            - modifyblock <[block]> <[mat]>

sand_cannon_tool_item:
    type: item
    debug: false
    material: sand
    display name: <gold>Sand Cannon
    enchantments:
    - sharpness:5
    mechanisms:
        hides: all
    lore:
    - <&[base]>Blasts a lil bit of sand.

sand_cannon_world:
    type: world
    debug: false
    events:
        on player right clicks block with:sand_cannon_tool_item permission:dscript.sandblast:
        - if !<player.has_permission[dscript.sandblast]||false>:
            - stop
        - announce to_console "<player.name> uses sand_cannon at <player.location.simple>"
        #- shoot falling_block[fallingblock_type=<list[sand|gravel|stone|grass_block|dirt|bedrock|warped_hyphae|oak_log|gold_block|nether_gold_ore|blue_wool|green_concrete|bricks|pumpkin|emerald_block|glowstone].random>] origin:<player> speed:1.5
        - shoot falling_block[fallingblock_type=sand] origin:<player> speed:1.5
