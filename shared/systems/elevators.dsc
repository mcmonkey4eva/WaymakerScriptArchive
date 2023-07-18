
# +=====
# + monkey's elevator test script thingy
# + version 0.1
# + for Denizen REL-1779
# +
# + This is not a completed script, the `elevator_move_task` is the important part if you want to yoink my elevators
# + The rest is just demo data/usage
# + for real world usage you'll want to automate it somewayhow
# + probably also make a command to make adding elevators user-friendly idk
# + not my problem i just need like one elevator in a world for dum reasons
# +
# + WARNING: if you lag you might fall or something so be careful
# + If intending to use this script for real you should probably, yknow, resolve that part.
# +
# + Also this isn't currently protected for like, server restarts n crashes n stuff.
# + It can end up with duplicated elevator platforms in some cases.
#
#
# + TLDR: Use at your own risk.

# example dataset of an elevator
testevator:
    type: data
    a:
        schematic: elevator_test
        area: <polygon[elevator_test_region]>
        floors:
        - <location[1620,-59,4214,superflat]>
        - <location[1620,-49,4214,superflat]>
        - <location[1620,-39,4214,superflat]>
        speed: 0.2
    aurum_dockside:
        schematic: elevator_test
        area: <polygon[aurum_dockside_elevator]>
        speed: 0.2
        floors:
        - <location[754,76,560,danary]>
        - <location[754,86,560,danary]>
        - <location[754,96,560,danary]>

# this task can be manually `/ex run run_testevator` to have it cycle through 3 floors
run_testevator:
    type: task
    debug: false
    definitions: key
    script:
    - define pattern <list[1|2|3|2]>
    - define from_id <[pattern].get[<server.flag[testevator_floor_id].mod[<[pattern].size>].add[1]>]>
    - flag server testevator_floor_id:++
    - define to_id <[pattern].get[<server.flag[testevator_floor_id].mod[<[pattern].size>].add[1]>]>
    - run elevator_move_task def.data:<script[testevator].parsed_key[<[key]>]> def.from_id:<[from_id]> def.to_id:<[to_id]>

elevator_world:
    type: world
    debug: false
    events:
        on entity_flagged:elevator_fallprotect damaged by fall:
        - determine cancelled
        on player kicked for flying flagged:elevator_fallprotect:
        - determine passively fly_cooldown:10s
        - determine cancelled

# ELEVATOR DATA KEYS:
# schematic (a name)
# floors (a list of locations)
# speed (a decimal number, must be positive, blocks per tick)
# area (an AreaObject, relative to floor 1)
elevator_move_task:
    type: task
    debug: false
    definitions: data|from_id|to_id
    script:
    ### PREP
    - if !<schematic[<[data.schematic]>].exists>:
        - ~schematic load name:<[data.schematic]>
    - if !<schematic[<[data.schematic]>].exists>:
        - debug error "elevator_move_task given schematic name <[data.schematic]> which does not exist. Failing."
        - stop
    - define chunks <list>
    - foreach <[data.floors]> as:loc:
        - define chunks <[chunks].include[<schematic[<[data.schematic]>].cuboid[<[loc]>].chunks>].deduplicate>
    - chunkload add <[chunks]>
    - define floor_1 <[data.floors].get[1].as[location]>
    - define start_loc <[data.floors].get[<[from_id]>].as[location]>
    - define end_loc <[data.floors].get[<[to_id]>].as[location]>
    - define area <[data.area].shift[<[start_loc].sub[<[floor_1]>]>]>
    - define move_vec <[end_loc].sub[<[start_loc]>].normalize>
    - define move <[move_vec].mul[<[data.speed]>]>
    - define dist <[end_loc].distance[<[start_loc]>]>
    ### DELETE OLD ELEVATOR BLOCKS AND SPAWN ENTS
    - define origin <schematic[<[data.schematic]>].origin>
    - define start_cuboid <schematic[<[data.schematic]>].cuboid[<[origin].xyz>,<[start_loc].world.name>]>
    - define block_ents <list>
    - define extra_ents <list>
    - foreach <[start_cuboid].blocks> as:rel_loc:
        - define mat <schematic[<[data.schematic]>].block[<[rel_loc]>]>
        - if <[mat]> !matches air|*_air|structure_void:
            - define blockloc <[start_loc].add[<[rel_loc]>].sub[<[origin]>].block>
            - modifyblock <[blockloc]> air
            - define loc <[blockloc].add[0.5,0.5,0.5]>
            - spawn elevator_block[fallingblock_type=<[mat]>] <[loc]> save:ent
            - define block_ents:->:<entry[ent].spawned_entity>
            #- spawn elevator_stand <[loc]> save:stand
            #- define block_ents:->:<entry[stand].spawned_entity>
            #- spawn elevator_shulker <[loc]> save:shulker
            #- define extra_ents:->:<entry[shulker].spawned_entity>
            #- mount <entry[shulker].spawned_entity>|<entry[stand].spawned_entity>
    ### MOVE PREP
    - define current <[start_loc]>
    - define start_area <schematic[<[data.schematic]>].cuboid[<[start_loc]>].expand[0,10,0]>
    - define riders <[area].entities[player|npc|mob]>
    - foreach <[riders]> as:rider:
        - flag <[rider]> ele_temp_offset:<[rider].location.sub[<[start_loc]>]> expire:1h
        - flag <[rider]> ele_temp_loc:<[rider].location> expire:1s
        - adjust <[rider]> gravity:false
        - if <[move_vec].y> > 0.1:
            - teleport <[rider]> <[rider].location.above[1]> relative
        - else if <[move_vec].y> < -0.1:
            - teleport <[rider]> <[rider].location.above[0.5]> relative
    - define full_move <location[0,0,0]>
    ### MOVE
    - repeat <[dist].div[<[data.speed]>]>:
        - define current <[current].add[<[move]>]>
        - define full_move <[full_move].add[<[move]>]>
        - define current_area <[area].shift[<[full_move]>]>
        - foreach <[riders]> as:old_rider:
            - if !<[old_rider].is_spawned||false>:
                - define riders:<-:<[old_rider]>
                - flag <[old_rider]> ele_temp_offset:!
            - else if !<[current_area].contains[<[old_rider].location>]>:
                - adjust <[old_rider]> gravity:true
                - define riders:<-:<[old_rider]>
                - flag <[old_rider]> ele_temp_offset:!
        - define new_riders <[current_area].entities[player|npc|mob].exclude[<[riders]>]>
        - adjust <[new_riders]> gravity:false
        - define riders:|:<[new_riders]>
        - foreach <[riders]> as:rider:
            - flag <[rider]> elevator_fallprotect expire:5s
            - if <[rider].object_type> != player:
                - define y_extra <[move].y.is_more_than[0].if_true[1].if_false[0.5]>
                - teleport <[rider]> <[current].add[<[rider].flag[ele_temp_offset]>].above[<[y_extra]>].with_pose[<[rider]>]>
                - adjust <[rider]> velocity:<[move]>
            - else:
                - if <[move_vec].y.abs> > 0.95:
                    - define rel <[rider].location.sub[<[rider].flag[ele_temp_loc]||<[rider].location>>]>
                    - define y_off <[rider].has_flag[ele_temp_offset].if_true[<[current].y.add[<[rider].flag[ele_temp_offset].y>].sub[<[rider].location.y>]>].if_false[0]>
                    - define y <[move].y.add[<[y_off].is_less_than[-0.1].if_true[0.5].if_false[0]>]>
                    - adjust <[rider]> velocity:<[rel].mul[0.8].with_y[<[move].y>]>
                    #- teleport <[rider]> <[rider].location.with_y[<[rider].location.y.add[<[rel].y>]>]> relative
                    - flag <[rider]> ele_temp_loc:<[rider].location> expire:1s
                - else:
                    - adjust <[rider]> velocity:<[move]>
        - foreach <[block_ents]> as:ent:
            - adjust <[ent]> velocity:<[move]>
        - wait 1t
    ### WRAP UP
    - schematic paste <[end_loc]> noair name:<[data.schematic]>
    - remove <[block_ents]>
    - remove <[extra_ents]>
    - foreach <[riders]> as:rider:
        - if <[rider].has_flag[ele_temp_offset]>:
            - teleport <[rider]> <[rider].location.with_y[<[end_loc].y.add[<[rider].flag[ele_temp_offset].y>]>]>
            - flag <[rider]> ele_temp_offset:!
        - adjust <[rider]> gravity:true
    - chunkload remove <[chunks]>

elevator_block:
    type: entity
    debug: false
    entity_type: falling_block
    mechanisms:
        force_no_persist: true
        gravity: false
        fallingblock_drop_item: false
        fallingblock_hurt_entities: false
        time_lived: -2147483648t
        auto_expire: false
        velocity: 0,0,0
        invulnerable: true

elevator_shulker:
    type: entity
    debug: false
    entity_type: shulker
    mechanisms:
        force_no_persist: true
        #has_ai: false
        visible: false
        #gravity: false
        velocity: 0,0,0
        #invulnerable: true

elevator_stand:
    type: entity
    debug: false
    entity_type: armor_stand
    mechanisms:
        force_no_persist: true
        #gravity: false
        visible: false
        is_small: true
        velocity: 0,0,0
        #invulnerable: true
