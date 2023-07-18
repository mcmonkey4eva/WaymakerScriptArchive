easter_egg_world:
    type: world
    debug: false
    events:
        on player right clicks *_button location_flagged:pumpkinbutton:
        - determine passively cancelled
        - ratelimit <player>/<context.location> 1m
        - repeat 2:
            - playsound <player> entity_player_breath pitch:0.5 volume:2 sound_category:players
        - wait 2s
        - toast "<&[base]>Scary scarecrow scared you!" icon:jack_o_lantern
        - repeat 2:
            - playsound <player> BLOCK_PUMPKIN_CARVE pitch:0.1
        - announce to_console "<player.name> hits a scarecrow"
        after player right clicks *_button location_flagged:crane_button:
        - ratelimit <player>/<context.location> 1m
        - toast "<&[base]>Crane operator!" icon:oak_log
        - repeat 2:
            - playsound <player> BLOCK_WOODEN_DOOR_OPEN pitch:0.01
        - announce to_console "<player.name> hits a crane"
        after player right clicks *_button location_flagged:shrine_athiel:
        - ratelimit <player> 1m
        - toast "<&[base]>Prayed to Athiel." icon:anvil
        - repeat 3:
            - wait 1t
            - playsound <player> entity_dolphin_swim pitch:0.3
        - announce to_console "<player.name> hits the shrine of athiel"
        after player right clicks *_button location_flagged:loudbell:
        - ratelimit <player> 5s
        - repeat 2:
            - playsound <context.location> block_bell_resonate pitch:0.5 volume:17 sound_category:players
        - wait 2.5s
        - repeat 2:
            - playsound <context.location> block_bell_use pitch:0.01 volume:17 sound_category:players
        - announce to_console "<player.name> hits the town bell"
        after player right clicks spruce_button location_flagged:ballistaegg:
        - ratelimit <player> 1s
        - shoot firework o:<context.location.flag[ballistaegg]> d:<context.location.flag[ballistaegg].forward[10]> speed:0.8
        - ratelimit <player>/<context.location> 1m
        - toast "<&[base]>Terrorized the town with heavy weaponry." icon:arrow
        after player right clicks *_button location_flagged:honkbutton:
        - ratelimit <player> 1m
        - announce to_console "<player.name> hits honk_button easter egg"
        - toast <&[base]>Honked. icon:bell
        - repeat 10:
            - playsound <player> sound:block_beacon_activate pitch:0.5
        on player death cause:contact in:gallows priority:-5:
        - announce to_console "<player.name> hits gallow death"
        - determine "<player.name> was hanged to death"
        after player enters gallowtop:
        - announce to_console "<player.name> enters gallowtop"
        - while <player.is_online> && <player.is_spawned> && <player.location.is_within[gallowtop]>:
            - define offset <cuboid[gallowtop].center.sub[<player.location>].with_y[0]>
            - if <[offset].vector_length> > 0.05 && <player.velocity.vector_length> < 0.5:
                - adjust <player> velocity:<[offset].normalize.mul[<[offset].vector_length.min[0.05]>]>
            - wait 2s
        after player enters dragon_butt:
        - ratelimit <player> 1m
        - announce to_console "<player.name> hits dragon_butt easter egg"
        - toast "<&color[#a64607]>Feeling Shitty" frame:challenge icon:cocoa_beans
        - repeat 2:
            - repeat 4:
                - wait 1t
                - playsound <player> block_basalt_fall
                - playsound <player> block_fungus_step
                - playsound <player> block_honey_block_step
            - wait 4t
        after player starts sneaking:
        - if <player.is_flying>:
            - stop
        - flag player sneak_spam:++ duration:2s
        - if <player.flag[sneak_spam]> == 10 && <util.random.int[1].to[2]> == 2:
            - announce to_console "<player.name> hits sneak_spam easter egg"
            - random:
                - narrate "<&8><&o>[Windows Sticky Keys is now activated]"
                - narrate "<&8><&o><proc[proc_format_name].context[<player>|<player>]><&8><&o> is bad at dancing."
        after arrow hits target:
        - if !<context.projectile.shooter.is_player||false>:
            - stop
        - define x <context.projectile.location.x.mod[1]>
        - define y <context.projectile.location.y.mod[1]>
        - define z <context.projectile.location.z.mod[1]>
        - choose <context.hit_face.xyz>:
            - case 1,0,0 -1,0,0:
                - define a <[z]>
                - define b <[y]>
            - case 0,0,1 0,0,-1:
                - define a <[x]>
                - define b <[y]>
            - case 0,1,0 0,-1,0:
                - define a <[x]>
                - define b <[z]>
        - if <[a]> > 0.45 && <[a]> < 0.65 && <[b]> > 0.45 && <[b]> < 0.65:
            - define __player <context.projectile.shooter>
            - if <player.location.distance[<context.projectile.location>]> > 8:
                - announce to_console "<player.name> gets a bullseye easter egg"
                - ratelimit <player> 5m
                - toast "<&[base]>Bullseye! Mastered the skill of archery." icon:arrow frame:challenge

magic_rainbow:
    type: task
    definitions: word
    debug: false
    script:
    - define players <player.location.find_players_within[40]>
    - define stands <list>
    - repeat 15:
        - fakespawn hologram_entity[custom_name=<&color[<color[<util.random.int[1].to[255]>,<util.random.int[1].to[255]>,<util.random.int[1].to[255]>]>]><[word]>;velocity=<location[0,0,0].random_offset[0.3]>] <player.eye_location> save:stand duration:10s players:<[players]>
        - define stands:->:<entry[stand].faked_entity>
    - repeat 100:
        - foreach <[stands].filter[is_spawned]> as:stand:
            - adjust <[stand]> move:<[stand].velocity>
        - wait 1t

gross_noise:
    type: task
    debug: false
    script:
    - repeat 100:
        - playsound sound:item_honey_bottle_drink volume:1 <player.location> pitch:<[value].div[50]>
        - playsound sound:item_honey_bottle_drink volume:1 <player.location> pitch:<element[2].sub[<[value].div[50]>]>
        - wait 1t

escalator:
    type: world
    debug: false
    events:
        on player enters escalator_zone:
        - wait 1t
        - while <cuboid[escalator_zone].contains[<player.location>]>:
            - adjust <player> velocity:-0.3,0.3,0
            - wait 1t
        on player enters escalator_zone2:
        - wait 1t
        - while <cuboid[escalator_zone2].contains[<player.location>]>:
            - adjust <player> velocity:0.1,-0.3,0
            - wait 1t

goat_horn_world:
    type: world
    debug: false
    events:
        on player right clicks block with:goat_horn permission:goathorn.bypass:
        - itemcooldown goat_horn duration:0t
        - wait 1t
        - itemcooldown goat_horn duration:0t

staffseals_world:
    type: world
    debug: false
    events:
        on player enters staffseal_1_undercove:
        - if <player.flag[character_mode]> not in working|spectator:
            - teleport <player> staffseal_1_undercove_returnpoint
            - narrate "<&[error]><&o>Abandon hope, all ye who enter here in beta. Thy soul might return 'pon release of The Undercove."
        on player enters staffseal_2_undercove:
        - if <player.flag[character_mode]> not in working|spectator:
            - teleport <player> staffseal_2_undercove_returnpoint
            - narrate "<&[error]><&o>Abandon hope, all ye who enter here in beta. Thy soul might return 'pon release of The Undercove."

