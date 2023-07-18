grappling_hook_item:
    type: item
    debug: false
    material: shears
    display name: <&color[#FFAAAA]>Grappling Hook
    enchantments:
    - sharpness:5
    mechanisms:
        hides: all
    lore:
    - <&7>Grapples real nice.

grappling_hook_world:
    type: world
    debug: false
    events:
        on player clicks block with:grappling_hook_item:
        - if !<player.has_permission[dscript.sandblast]||false>:
            - stop
        - determine passively cancelled
        - if <player.has_flag[is_grappling]>:
            - stop
        - itemcooldown shears duration:1s
        - flag player is_grappling duration:5s
        - shoot arrow o:<player> speed:2 save:grapple
        - flag <entry[grapple].shot_entity> is_grapple
        - spawn slime[size=0;invulnerable=true;has_ai=false;forced_no_persist=true] <player.eye_location> save:slime
        #- invisible <entry[slime].spawned_entity> state:true
        - flag <entry[grapple].shot_entity> grappleslime:<entry[slime].spawned_entity>
        - leash <entry[slime].spawned_entity> holder:<player>
        - attach <entry[slime].spawned_entity> to:<entry[grapple].shot_entity> offset:0,-1,0
        - wait 30s
        - if <entry[slime].spawned_entity.is_spawned||false>:
            - remove <entry[slime].spawned_entity>
        on arrow hits block:
        - if <context.projectile.has_flag[is_grapple]>:
            - define slime <context.projectile.flag[grappleslime]>
            - define shooter <context.projectile.shooter>
            - if <[shooter].is_spawned||false>:
                - ~push <[shooter]> speed:2 duration:5s no_rotate destination:<context.projectile.location>
            - flag <[shooter]> is_grappling:!
            - if <[slime].is_spawned||false>:
                - remove <[slime]>

spiderman_item:
    type: item
    material: cobweb
    display name: <&color[#EE0000]>Spider<&color[#550000]>man <&color[#EE0000]>Hand<&color[#550000]>webs
    enchantments:
    - sharpness:5
    mechanisms:
        hides: all
    lore:
    - <&7>Sticky at range.

spiderman_world:
    type: world
    debug: false
    events:
        on player clicks block with:spiderman_item:
        - if !<player.has_permission[dscript.sandblast]||false>:
            - stop
        - determine passively cancelled
        - define target <player.cursor_on[200]||null>
        - if <[target]> == null:
            - stop
        - spawn slime[size=0;invulnerable=true;has_ai=false;forced_no_persist=true] <[target]> save:slime
        #- invisible <entry[slime].spawned_entity> state:true
        - leash <entry[slime].spawned_entity> holder:<player>
        - flag player spiderlines:++
        - define line <player.flag[spiderlines].add[1]>
        - while <player.is_spawned> && <player.flag[spiderlines]||99999> <= <[line]> && <player.location.distance[<[target]>]> < 100:
            - define dir <[target].sub[<player.location>].normalize>
            - define new_vel <player.velocity.add[<[dir].mul[0.2]>]>
            - if <[new_vel].vector_length> > 2:
                - define new_vel <[new_vel].normalize.mul[2]>
            - adjust <player> velocity:<[new_vel]>
            - if <player.velocity.normalize.add[<[dir]>].vector_length> < 1.0:
                - while stop
            - wait 1t
        - if <entry[slime].spawned_entity.is_spawned||false>:
            - remove <entry[slime].spawned_entity>
        on player starts sneaking flagged:spiderlines:
        - flag player spiderlines:!
