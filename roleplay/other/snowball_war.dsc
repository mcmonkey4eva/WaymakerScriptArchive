
better_snow_ball_weapon:
    type: item
    debug: false
    material: snowball
    display name: <&f>Better Snowball
    enchantments:
    - sharpness:5
    mechanisms:
        hides: all
    lore:
    - <&[base]>Contains a rock inside.
    - <&7><&o><&dq>Bit's competitive spirit.<&dq>

better_snow_ball_weapon_world:
    type: world
    debug: false
    events:
        on player right clicks block with:better_snow_ball_weapon permission:dscript.sandblast:
        - if !<player.has_permission[dscript.sandblast]||false>:
            - stop
        - determine passively cancelled
        - announce to_console "<player.name> uses better_snow_ball_weapon at <player.location.simple>"
        - repeat 5:
            - wait 1t
            - if <player.is_spawned>:
                - shoot snowball origin:<player> destination:<player.eye_location.forward[5].random_offset[0.5]> speed:2 save:snowball
                - flag <entry[snowball].shot_entity> deadly_snowball
        on player damaged by snowball:
        - if <context.projectile.has_flag[deadly_snowball]>:
            - announce to_console "<context.projectile.shooter.name> hit <context.entity.name> with a deadly snowball"
            - determine 20

best_snow_ball_weapon:
    type: item
    debug: false
    material: snowball
    display name: <&color[#CCDDFF]>Best Snowball
    enchantments:
    - sharpness:5
    mechanisms:
        hides: all
    lore:
    - <&[base]>Contains a shard of hardened steel inside.
    - <&c>Also contains a touch of gunpowder.
    - <&7><&o><&dq>Monkey's vengeance.<&dq>

best_snow_ball_weapon_world:
    type: world
    debug: false
    events:
        on player right clicks block with:best_snow_ball_weapon permission:dscript.sandblast:
        - if !<player.has_permission[dscript.sandblast]||false>:
            - stop
        - determine passively cancelled
        - announce to_console "<player.name> uses best_snow_ball_weapon at <player.location.simple>"
        - repeat 8:
            - wait 1t
            - if <player.is_spawned>:
                - repeat 3:
                    - shoot snowball[item=best_snow_ball_weapon] origin:<player> destination:<player.eye_location.forward[5].random_offset[<[value].div[6]>]> speed:3 save:snowball
                    - flag <entry[snowball].shot_entity> deadly_snowball
                    - if <util.random.int[1].to[20]> == 3:
                        - flag <entry[snowball].shot_entity> grenade_snowball
        on snowball hits block:
        - if <context.projectile.has_flag[grenade_snowball]>:
            - define src <context.projectile.shooter>
            - explode <context.location> power:2 source:<[src]>
            - define loc <context.location.add[<context.hit_face>]>
            - wait 1t
            - repeat 6:
                - shoot snowball origin:<[loc]> shooter:<[src]> destination:<[loc].above[3].random_offset[4]> speed:1 save:snowball
                - flag <entry[snowball].shot_entity> deadly_snowball

bouncy_ball_weapon:
    type: item
    debug: false
    material: heart_of_the_sea
    display name: <&color[#FFAAAA]>Bouncy Snowball
    enchantments:
    - sharpness:5
    mechanisms:
        hides: all
    lore:
    - <&[base]>Made out of rubber.
    - <&7><&o><&dq>That's just literally not snow.<&dq>

bouncy_ball_weapon_world:
    type: world
    debug: false
    events:
        on player right clicks block with:bouncy_ball_weapon permission:dscript.sandblast:
        - if !<player.has_permission[dscript.sandblast]||false>:
            - stop
        - determine passively cancelled
        - announce to_console "<player.name> uses bouncy_ball_weapon at <player.location.simple>"
        - shoot snowball[item=bouncy_ball_weapon] origin:<player> speed:1.5 save:snowball
        - flag <entry[snowball].shot_entity> deadly_snowball
        - flag <entry[snowball].shot_entity> bouncy_snowball:10
        on snowball hits block:
        - if <context.projectile.has_flag[bouncy_snowball]>:
            - define src <context.projectile.shooter||null>
            - if <[src]> == null:
                - stop
            - define loc <context.projectile.location>
            - define dir <context.projectile.velocity>
            - define count <context.projectile.flag[bouncy_snowball].sub[1]>
            - if <context.hit_face.y.abs> > 0.5:
                - define dir <[dir].with_y[<[dir].y.mul[-1]>]>
            - else if <context.hit_face.x.abs> > 0.5:
                - define dir <[dir].with_x[<[dir].x.mul[-1]>]>
            - else:
                - define dir <[dir].with_z[<[dir].z.mul[-1]>]>
            - wait 1t
            - shoot snowball[item=bouncy_ball_weapon] origin:<[loc]> shooter:<[src]> destination:<[loc].add[<[dir]>]> speed:<[dir].vector_length.mul[0.8]> save:snowball
            - flag <entry[snowball].shot_entity> deadly_snowball
            #- flag <entry[snowball].shot_entity> offset:<context.projectile.flag[offset]>
            - flag server balls:<-:<context.projectile>
            - flag server balls:->:<entry[snowball].shot_entity>
            - if <[count]> > 0 && <[dir].vector_length> > 0.05:
                - flag <entry[snowball].shot_entity> bouncy_snowball:<[count]>

bouncy_ball_effect_task:
    type: task
    debug: false
    script:
    - flag server balls:!
    - repeat 30:
        - define loc <player.location.add[<location[2,0,0].rotate_around_y[<[value].mul[12].to_radians>]>]>
        - shoot snowball[item=bouncy_ball_weapon] origin:<[loc]> shooter:<player> destination:<[loc].above[2]> speed:0.2 save:snowball
        - flag <entry[snowball].shot_entity> deadly_snowball
        - flag <entry[snowball].shot_entity> bouncy_snowball:5
        - flag <entry[snowball].shot_entity> offset:<location[2,0,0].rotate_around_y[<[value].mul[12].to_radians>]>
        - flag server balls:->:<entry[snowball].shot_entity>
    #- define loc <player.location>
    - repeat 360:
        - wait 1t
        - foreach <server.flag[balls].filter[is_spawned]> as:entity:
            - define velocity <[entity].velocity>
            - define velocity <[velocity].with_x[<[velocity].x.mul[0.05]>].with_z[<[velocity].z.mul[0.05]>]>
            - define velocity <[velocity].add[<player.location.sub[<[entity].location.sub[<[entity].flag[offset]>]>].with_y[0].mul[0.5]>]>
            - adjust <[entity]> velocity:<[velocity]>
        #- define loc <player.location>


splitty_ball_weapon:
    type: item
    debug: false
    material: prismarine_crystals
    display name: <&color[#AAFFAA]>Splitting Snowball
    enchantments:
    - sharpness:5
    mechanisms:
        hides: all
    lore:
    - <&[base]>Made out of splitting.
    - <&7><&o><&dq>That's not how that word even-<&dq>

splitty_ball_weapon_world:
    type: world
    debug: false
    events:
        on player right clicks block with:splitty_ball_weapon permission:dscript.sandblast:
        - if !<player.has_permission[dscript.sandblast]||false>:
            - stop
        - determine passively cancelled
        #- ratelimit <player> 2s
        #- itemcooldown prismarine_crystals duration:2s
        - announce to_console "<player.name> uses splitty_ball_weapon at <player.location.simple>"
        - shoot snowball[item=splitty_ball_weapon] origin:<player> speed:1.5 save:snowball
        - flag <entry[snowball].shot_entity> deadly_snowball
        - flag <entry[snowball].shot_entity> splitty_snowball:4
        on snowball hits block:
        - if <context.projectile.has_flag[splitty_snowball]>:
            - define src <context.projectile.shooter||null>
            - if <[src]> == null:
                - stop
            - define loc <context.projectile.location>
            - define dir <context.projectile.velocity>
            - define count <context.projectile.flag[splitty_snowball].sub[1]>
            - wait 1t
            - foreach 1,0,0|-1,0,0|0,0,1|0,0,-1 as:angle:
                - shoot snowball[item=splitty_ball_weapon] origin:<[loc]> shooter:<[src]> destination:<[loc].above[3].add[<[angle]>]> speed:<[count].div[5]> save:snowball
                - flag <entry[snowball].shot_entity> deadly_snowball
                - if <[count]> > 0:
                    - flag <entry[snowball].shot_entity> splitty_snowball:<[count]>

fire_ball_weapon:
    type: item
    debug: false
    material: fire_charge
    display name: <&color[#FF7700]>Burning <&color[#FF0000]>Snowball
    enchantments:
    - sharpness:5
    mechanisms:
        hides: all
    lore:
    - <&[base]>Burning hot snow.
    - <&7><&o><&dq>Dragon's understanding of physics.<&dq>

fire_ball_weapon_world:
    type: world
    debug: false
    events:
        on player right clicks block with:fire_ball_weapon permission:dscript.sandblast:
        - if !<player.has_permission[dscript.sandblast]||false>:
            - stop
        - determine passively cancelled
        - announce to_console "<player.name> uses fire_ball_weapon at <player.location.simple>"
        - shoot small_fireball origin:<player> speed:3 save:fireball
        - repeat 5:
            - wait 1t
            - if <player.is_spawned>:
                - shoot small_fireball origin:<player> destination:<player.eye_location.forward[5].random_offset[0.5]> speed:2 save:fireball
                - flag <entry[fireball].shot_entity> deadly_fireball
        on fireball explodes:
        - flag server fireball_boom duration:2t
        - determine <list>
        on block ignites server_flagged:fireball_boom:
        #- if <context.entity.entity_type.contains[fireball]||false>:
            - determine cancelled
        on small_fireball hits block:
        - flag server fireball_boom duration:2t
        - if <context.projectile.has_flag[deadly_fireball]>:
            - define loc <context.projectile.location||null>
            - define src <context.projectile.shooter||null>
            - if <[src]> == null || <[loc]> == null:
                - stop
            - wait 1t
            - explode  <[loc]> power:1 source:<[src]>
        on player damaged by player:
        - if <context.damager.item_in_hand.script.name||null> == fire_ball_weapon:
            - announce to_console "<context.damager.name> hit <context.entity.name> with a deadly fireball"
            - determine 20

snow_totem_weapon:
    type: item
    debug: false
    material: totem_of_undying
    display name: <&color[#00FF99]>Magic <&color[#0099FF]>Snowball
    enchantments:
    - sharpness:5
    mechanisms:
        hides: all
    lore:
    - <&[base]>Definitely just an ordinary snowball.
    - <&7><&o><&dq>I am a genie please free me I'll give you wishes.<&dq>

snow_totem_weapon_world:
    type: world
    debug: false
    events:
        on player right clicks block with:snow_totem_weapon permission:dscript.sandblast:
        - if !<player.has_permission[dscript.sandblast]||false>:
            - stop
        - determine passively cancelled
        #- ratelimit <player> 1s
        #- itemcooldown totem_of_undying duration:1s
        - announce to_console "<player.name> uses snow_totem_weapon at <player.location.simple>"
        - repeat 2:
            - wait 1t
            - if <player.is_spawned>:
                - shoot snowball[item=snow_totem_weapon] origin:<player> destination:<player.eye_location.forward[5].random_offset[0.7]> speed:3 save:snowball
                - flag <entry[snowball].shot_entity> magic_snowball:3
                - flag <entry[snowball].shot_entity> deadly_snowball
        on snowball hits block:
        - if <context.projectile.has_flag[magic_snowball]>:
            - define src <context.projectile.shooter||null>
            - if <[src]> == null:
                - stop
            - define loc <context.projectile.location>
            - define dir <context.projectile.velocity>
            - define count <context.projectile.flag[magic_snowball].sub[1]>
            - wait 1t
            - repeat <[count].mul[3]>:
                - repeat 10:
                    - playeffect effect:dragon_breath at:<[loc]> velocity:<location[0,0,0].random_offset[1]> visibility:50
                - shoot snowball[item=snow_totem_weapon] origin:<[loc]> shooter:<[src]> destination:<[loc].above[3].add[<location[0,1,0].random_offset[1]>]> speed:<[count].div[2]> save:snowball
                - flag <entry[snowball].shot_entity> deadly_snowball
                - if <[count]> > 0:
                    - flag <entry[snowball].shot_entity> magic_snowball:<[count]>

crossbow_of_doom:
    type: item
    material: crossbow
    debug: false
    display name: <&color[#8c4800]>M249 Bravo
    enchantments:
    - sharpness:5
    mechanisms:
        hides: all
        charged_projectiles: arrow
    lore:
    - <&[base]>Not a snowball at all, clearly a military machine gun.
    - <&7><&o><&dq>This was stolen from a United States Marine Corps base.
    - <&7><&o>how the hell did you get it?<&dq>

crossbow_of_peace:
    type: item
    material: crossbow
    debug: false
    display name: <element[Illegal Flare Gun].rainbow>
    enchantments:
    - sharpness:5
    mechanisms:
        hides: all
        charged_projectiles: firework_rocket
    lore:
    - <&[base]>Belt-fed freedom tubes.
    - <&7><&o><&dq>How is this illegal but the machine gun isn't?<&dq>

crossbow_of_doom_world:
    type: world
    debug: false
    events:
        on player right clicks block with:crossbow_of_doom permission:dscript.sandblast:
        - if !<player.has_permission[dscript.sandblast]||false>:
            - stop
        - determine passively cancelled
        - announce to_console "<player.name> uses crossbow_of_doom at <player.location.simple>"
        - repeat 5:
            - wait 1t
            - if <player.is_spawned>:
                - repeat 5:
                    - shoot arrow[critical=true] origin:<player> destination:<player.eye_location.forward[5].random_offset[0.7]> speed:3 save:bullet
                    - flag <entry[bullet].shot_entity> magic_gunshot
        on player right clicks block with:crossbow_of_peace permission:dscript.sandblast:
        - if !<player.has_permission[dscript.sandblast]||false>:
            - stop
        - determine passively cancelled
        - announce to_console "<player.name> uses crossbow_of_peace at <player.location.simple>"
        - repeat 5:
            - wait 1t
            - if <player.is_spawned>:
                - repeat 5:
                    - define type <list[ball|ball_large|star|burst|creeper].random>
                    - shoot firework[firework_item=firework_rocket[firework=true,false,<[type]>,<util.random.int[0].to[255]>,<util.random.int[0].to[255]>,<util.random.int[0].to[255]>,<util.random.int[0].to[255]>,<util.random.int[0].to[255]>,<util.random.int[0].to[255]>]] origin:<player> destination:<player.eye_location.forward[5].random_offset[0.7]> speed:3 save:bullet
                    - flag <entry[bullet].shot_entity> magic_gunshot
        after arrow hits block:
        - if <context.projectile.has_flag[magic_gunshot]||false>:
            - remove <context.projectile>
        on player picks up launched arrow:
        - if <context.arrow.has_flag[magic_gunshot]>:
            - determine cancelled
