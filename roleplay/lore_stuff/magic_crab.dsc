
crab_stand:
    type: entity
    debug: false
    entity_type: armor_stand
    mechanisms:
        #marker: true
        visible: false
        gravity: false
        invulnerable: true
        equipment: air|air|air|<list[white|red|black|blue|lime|yellow|magenta|orange].random>_concrete

crab_sturdy:
    type: entity
    entity_type: shulker
    mechanisms:
        has_ai: false

spawn_crab_part:
    type: task
    debug: false
    definitions: item|location|head
    script:
    - spawn crab_stand[equipment=air|air|air|<[item]>] <[location].with_yaw[0].with_pitch[0]> save:x
    #- spawn dolphin[has_ai=false;gravity=false] <[location].with_yaw[0].with_pitch[0]> save:x
    - flag server crab_parts:->:<entry[x].spawned_entity>
    - flag <entry[x].spawned_entity> head:<[head]>
    - flag <[head]> parts:->:<entry[x].spawned_entity>
    - attach <entry[x].spawned_entity> to:<[head]> offset:<entry[x].spawned_entity.location.sub[<[head].location>]> relative sync_server
    #- spawn crab_sturdy <[location].with_yaw[0].with_pitch[0].above[1.8].add[-0.5,0,-0.5]> save:y
    #- attach <entry[y].spawned_entity> to:<[head]> offset:<entry[y].spawned_entity.location.sub[<[head].location>]> relative sync_server

magic_crab:
    type: task
    debug: false
    script:
    - stop
    - if <server.has_flag[crab_parts]>:
        - remove <server.flag[crab_parts]>
        - flag server crab_parts:!
    - spawn crab_stand[equipment=air|air|air|red_concrete] <player.location.above[9]> save:x
    - flag <entry[x].spawned_entity> head:<entry[x].spawned_entity>
    - flag server crab_head:<entry[x].spawned_entity>
    - stop
    - foreach 2,0,2|2,0,0|2,0,-2|-2,0,2|-2,0,0|-2,0,-2 as:offset:
        - repeat 10 as:height:
            - run spawn_crab_part def:<player.location.add[<location[<[offset]>].mul[<[height].mul[0.2]>]>].above[6].below[<[height].mul[0.4]>]>
    - foreach <location[0,0,0,waymakerland].to_ellipsoid[5,5,5].shell> as:loc:
        - run spawn_crab_part def:<player.location.above[6].add[<[loc].mul[0.6]>]>
    - foreach 0.5|-0.5 as:x:
        - foreach <[x].mul[0.5]>,0.1,1|<[x].mul[0.5]>,-0.1,1 as:offset:
            - repeat 10 as:length:
                - run spawn_crab_part def:<player.location.add[<[x].mul[4]>,0,0].add[<location[<[offset]>].mul[<[length].mul[0.5].add[1]>]>].above[6]>

make_magic_crab:
    type: task
    debug: false
    definitions: schematic
    script:
    - if !<schematic[<[schematic]>].exists>:
        - stop
    - spawn crab_stand[equipment=air|air|air|red_concrete] <player.location.add[<schematic[<[schematic]>].width.mul[0.3]>,<schematic[<[schematic]>].height.mul[0.6]>,<schematic[<[schematic]>].length.mul[0.3]>].with_yaw[0].with_pitch[0]> save:x
    - flag <entry[x].spawned_entity> head:<entry[x].spawned_entity>
    - define head <entry[x].spawned_entity>
    - flag server crab_head:<entry[x].spawned_entity>
    - flag <[head]> height:<schematic[<[schematic]>].height.mul[0.6].sub[1.7]>
    - repeat <schematic[<[schematic]>].width> as:x:
        - repeat <schematic[<[schematic]>].height> as:y:
            - repeat <schematic[<[schematic]>].length> as:z:
                - define item <schematic[<[schematic]>].block[<location[<[x]>,<[y]>,<[z]>].sub[1,1,1]>].name>
                - if <[item]> != air:
                    - run spawn_crab_part def:<[item]>|<player.location.add[<location[<[x]>,<[y]>,<[z]>].mul[0.6]>].with_yaw[0].with_pitch[0]>|<[head]>

magic_crab_control:
    type: world
    debug: false
    events:
        on player right clicks crab_stand priority:-100:
        - determine passively cancelled
        - if <context.entity.flag[head].passenger.exists>:
            - stop
        - mount <player>|<context.entity.flag[head]>
        on player steers crab_stand:
        - define looking <player.location.direction.vector.with_y[0].div[3]>
        - define forward <[looking].mul[<context.forward>]>
        - define sideways <[looking].rotate_around_y[<element[90].to_radians>].mul[<context.sideways>]>
        - define speed 2
        #- flag player RideAllTheChickens.JumpingVelocity:<[upward].sub[0.06]>
        - flag player RideAllTheChickens.JumpingVelocity:<context.jump.if_true[0.5].if_false[-0.02]>
        - define upward <player.flag[RideAllTheChickens.JumpingVelocity]||0>
        - if <[upward]> <= 0 && <context.entity.location.sub[0,<context.entity.flag[height].add[0.01]>,0].material.is_solid>:
            - flag player RideAllTheChickens.JumpingVelocity:0
            - define upward 0
            - if <context.jump>:
                - flag player RideAllTheChickens.JumpingVelocity:0.5
        - if <context.dismount>:
            - determine passively cancelled
            - define speed 10
        - define speed <context.dismount.if_true[10].if_false[1]>
        - define velocity <[forward].add[<[sideways]>].mul[<[speed]>].add[0,<[upward]>,0]>
        - adjust <context.entity> move:<[velocity]>
        - if <[velocity].with_y[0].vector_length> > 0.01:
            - look <context.entity> <context.entity.eye_location.add[<[velocity].with_y[0]>]>
