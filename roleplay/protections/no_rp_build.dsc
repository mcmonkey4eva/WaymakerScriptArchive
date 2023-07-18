no_rp_build_world:
    type: world
    debug: false
    events:
        on player places block priority:-5:
        - inject build_home_place_exception
        - inject build_protect_task
        on player empties bucket priority:-5:
        - if !<player.has_permission[dscript.canbuild]> || <player.gamemode> != creative:
            - actionbar "<&[error]>You are not allowed to use buckets."
            - determine cancelled
        on player fills bucket priority:-5:
        - if !<player.has_permission[dscript.canbuild]> || <player.gamemode> != creative:
            - actionbar "<&[error]>You are not allowed to use buckets."
            - determine cancelled
        on player breaks block priority:-5:
        - if !<context.location.has_flag[mine_block]>:
            - inject build_protect_task
        on player breaks hanging priority:-5:
        - define location <context.hanging.location>
        - inject build_protect_task
        on player places hanging priority:-5:
        - define location <context.hanging.location>
        - inject build_protect_task
        on player right clicks hanging priority:-5:
        - define location <context.entity.location||null>
        - if <[location]> == null:
            - stop
        - inject build_protect_task
        on player damages item_frame priority:-5:
        - define location <context.entity.location>
        - inject build_protect_task
        on player right clicks block with:bone_meal priority:-5:
        - if !<player.has_permission[dscript.canbuild]> || <player.gamemode> != creative:
            - actionbar "<&[error]>You are not allowed to use bonemeal."
            - determine cancelled
        on player right clicks block with:minecart|*_minecart|*_boat|armor_stand priority:-5:
        - if !<player.has_permission[dscript.canbuild]> || <player.gamemode> != creative:
            - actionbar "<&[error]>You are not allowed to place vehicles."
            - determine cancelled
        on player right clicks vehicle priority:-5:
        - if !<player.has_permission[dscript.canbuild]> || <player.gamemode> != creative:
            - actionbar "<&[error]>You are not allowed to interact with vehicles."
            - determine cancelled
        on player damages vehicle priority:-5:
        - if !<player.has_permission[dscript.canbuild]> || <player.gamemode> != creative:
            - actionbar "<&[error]>You are not allowed to damage vehicles."
            - determine cancelled
        on player right clicks armor_stand priority:-5:
        - define location <context.entity.location>
        - inject build_protect_task
        on player damages armor_stand priority:-5:
        - define location <context.entity.location>
        - inject build_protect_task
        on player right clicks anvil|chipped_anvil|damaged_anvil priority:-5:
        - if !<player.has_permission[dscript.canbuild]>:
            - actionbar "<&[error]>You are not allowed to use anvils."
            - determine cancelled
        #on player right clicks *_bed priority:-5:
        #- if <player.gamemode> == creative && <context.item.material.advanced_matches[*_sign|debug_stick]||false> && <player.is_sneaking>:
        #    - stop
        #- actionbar "<&[error]>You are not allowed to sleep in beds."
        #- determine cancelled
        on player right clicks enchanting_table|tnt|hopper|repeater|comparator|dropper|observer|dispenser|loom|end_portal_frame|smoker|blast_furnace|cartography_table|fletching_table|grindstone|lodestone|respawn_anchor|smithing_table|stonecutter|brewing_stand priority:-5:
        - if !<player.has_permission[dscript.canbuild]> || <player.gamemode> != creative:
            - actionbar "<&[error]>You are not allowed to use this block type."
            - determine cancelled
        on player right clicks flower_pot|potted_* priority:-5:
        - inject build_protect_task

home_no_touchy_world:
    type: world
    debug: false
    events:
        on player right clicks block priority:-10:
        - if <context.location||null> == null:
            - stop
        - if <script[rp_build_data].data_key[super_safe.<context.location.material.name||air>]||false>:
            - stop
        - if <context.location.has_flag[stool]>:
            - stop
        - if <context.location.has_flag[public_unlocked]>:
            - stop
        - if <context.location.material.advanced_matches[*door]>:
            - inject rentable_area_get
            - if <[area].length> > 0:
                - define area_data <server.flag[rentables.<[area]>]>
                - if <[area_data].get[owner]||null> == null:
                    - stop
        - inject homes_no_touchy
        on player takes item from lectern priority:-10:
        - inject homes_no_touchy
        on player places block priority:-10:
        - inject homes_no_touchy
        on player breaks block priority:-10:
        - if !<context.location.has_flag[mine_block]>:
            - inject homes_no_touchy
        on player breaks hanging priority:-10:
        - define location <context.hanging.location>
        - inject homes_no_touchy
        on player places hanging priority:-10:
        - define location <context.hanging.location>
        - inject homes_no_touchy
        on player right clicks hanging priority:-10:
        - define location <context.entity.location>
        - inject homes_no_touchy

build_home_place_exception:
    type: task
    debug: false
    script:
    - if <script[rp_build_data].data_key[in_home.<context.material.name||null>]||allowed> == never:
        - if <player.gamemode> == creative && <player.has_permission[dscript.canbuild]>:
            - stop
        - actionbar "<&[error]>You are not allowed to place this block type."
        - determine cancelled

homes_no_touchy:
    type: task
    debug: false
    script:
    - if <player.gamemode> == creative && <player.has_permission[dscript.canbuild]>:
        - stop
    - inject rentable_area_get
    - if <[area].length> > 0:
        - define area_data <server.flag[rentables.<[area]>]>
        #- if <[area_data].get[owner]||null> != null:
        - if !<proc[rent_is_owned_proc].context[<[area]>]> && !<[area_data].get[members].contains[<player.proc[cc_idpair]>]||false>:
            - actionbar "<&c>Only the owner and members of a home can edit it."
            - determine cancelled

build_protect_task:
    type: task
    debug: false
    script:
    - if <player.world.name> == superflat:
        - stop
    - inject rentable_area_get
    - if <[area].length> > 0:
        - define area_data <server.flag[rentables.<[area]>]>
        - if <proc[rent_is_owned_proc].context[<[area]>]>:
            #- actionbar "<&c>Building in your home will be enabled soon!"
            #- if !<player.has_permission[dscript.canbuild]> || <player.gamemode> != creative:
            #    - determine cancelled
            - stop
        - if <[area_data].get[members].contains[<player.proc[cc_idpair]>]||false>:
            #- actionbar "<&c>Building in your home will be enabled soon!"
            #- if !<player.has_permission[dscript.canbuild]> || <player.gamemode> != creative:
            #    - determine cancelled
            - stop
    - if !<player.has_permission[dscript.canbuild]>:
        - actionbar "<&[error]>You are not allowed to modify the world."
        - determine cancelled
    - if <player.gamemode> != creative:
        - actionbar "<&[error]>You cannot modify the world except in <&[emphasis]>creative<&[error]> mode."
        - determine cancelled

rp_build_data:
    type: data
    super_safe:
        air: true
        player_head: true
        stripped_dark_oak_log: true
        stripped_oak_log: true
        stripped_spruce_log: true
        stripped_birch_log: true
        stripped_jungle_log: true
        stripped_acacia_log: true
        stripped_dark_oak_wood: true
        stripped_oak_wood: true
        stripped_spruce_wood: true
        stripped_birch_wood: true
        stripped_jungle_wood: true
        stripped_acacia_wood: true
        dark_oak_log: true
        oak_log: true
        spruce_log: true
        birch_log: true
        jungle_log: true
        acacia_log: true
        dark_oak_wood: true
        oak_wood: true
        spruce_wood: true
        birch_wood: true
        jungle_wood: true
        acacia_wood: true
        dark_oak_planks: true
        oak_planks: true
        spruce_planks: true
        birch_planks: true
        jungle_planks: true
        acacia_planks: true
        dark_oak_slab: true
        oak_slab: true
        spruce_slab: true
        birch_slab: true
        jungle_slab: true
        acacia_slab: true
        dark_oak_stairs: true
        oak_stairs: true
        spruce_stairs: true
        birch_stairs: true
        jungle_stairs: true
        acacia_stairs: true
        dark_oak_fence: true
        oak_fence: true
        spruce_fence: true
        birch_fence: true
        jungle_fence: true
        acacia_fence: true
        polished_diorite: true
        white_concrete: true
        diorite: true
        stone: true
    in_home:
        tnt: never
        redstone: never
        hopper: never
        daylight_detector: never
        redstone_block: never
        repeater: never
        comparator: never
        target: never
        observer: never
        dropper: never
        heavy_weighted_pressure_plate: never
        light_weighted_pressure_plate: never
        trapped_chest: never
        piston: never
        sticky_piston: never
        note_block: never
        dispenser: never
        dragon_egg: never
        chorus_plant: never
        chorus_flower: never
        anvil: never
        chipped_anvil: never
        damaged_anvil: never
        beacon: never
        magma_block: never
        end_portal_frame: never
        end_crystal: never
        respawn_anchor: never
        ender_chest: never
        lava: never
        lava_bucket: never
        water: never
        water_bucket: never
        shulker_box: never
        white_shulker_box: never
        orange_shulker_box: never
        magenta_shulker_box: never
        light_blue_shulker_box: never
        yellow_shulker_box: never
        lime_shulker_box: never
        pink_shulker_box: never
        gray_shulker_box: never
        light_gray_shulker_box: never
        cyan_shulker_box: never
        purple_shulker_box: never
        blue_shulker_box: never
        brown_shulker_box: never
        green_shulker_box: never
        red_shulker_box: never
        black_shulker_box: never
