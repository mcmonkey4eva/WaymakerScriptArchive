lock_pick_world:
    type: world
    debug: false
    events:
        on player right clicks block flagged:lockpicking priority:-100:
        - determine passively cancelled
        on player left clicks block flagged:lockpicking priority:-100:
        - flag player lock_pressing:0
        - determine passively cancelled
        on player right clicks *door with:lockpick_item:
        - determine passively cancelled
        - flag player lockpicking
        - flag player lockpick_yaw:0
        - flag player lockpick_pitch:<util.random.decimal[-180].to[180]>
        #- define loc <player.eye_location.forward[1].with_yaw[<player.location.yaw.add[180]>].with_pitch[0]>
        - define loc <player.eye_location.ray_trace.add[<player.eye_location.ray_trace[return=normal].mul[0.5]>].face[<player.eye_location>].with_pitch[0]>
        - fakespawn lock_body_entity <[loc].below[1.8]> save:lockent d:0
        - fakespawn lock_pick_entity <[loc].below[1.8]> save:pickent d:0
        - define lock <entry[lockent].faked_entity>
        - define pick <entry[pickent].faked_entity>
        - define start <util.time_now>
        - adjust <player> item_slot:5
        - title "title:<&[base]>Picking lock..." "subtitle:<&[warn]>Scroll your mouse wheel to align, and click to use" fade_in:1t stay:2s
        - while true:
            - if !<player.has_flag[lockpicking]> || !<player.is_online>:
                - narrate "<&7><&o>You give up on the picking the lock."
                - inject lock_pick_end_task
            - if <[start].from_now.in_seconds> > 30:
                - narrate "<&7><&o>You struggle valiantly against the lock but simply can't figure it out."
                - flag player lockpicking:!
                - inject lock_pick_end_task
            - repeat 9:
                - fakeitem air slot:<[value]> players:<player>
            - define pitch:0.1
            - define shake 0
            - if <player.has_flag[lock_pressing]>:
                - flag player lock_pressing:++
                - define pitch <player.flag[lock_pressing].to_radians.mul[5]>
                - define closeness <player.flag[lockpick_pitch].sub[<player.flag[lockpick_yaw]>].div[30].abs>
                - announce to_console "lockpick <[closeness]> for <player.flag[lockpick_pitch]> and <player.flag[lockpick_yaw]>"
                - define shake <util.random.decimal[-<[closeness]>].to[<[closeness]>]>
                - if <player.flag[lock_pressing]> > 10:
                    - flag player lock_pressing:!
                    - if <[closeness]> < 0.5:
                        - while stop
            - adjust <[pick]> armor_pose:head|<[pitch]>,<[shake].mul[<[pitch]>]>,<player.flag[lockpick_yaw].add[<[shake]>].to_radians>
            - adjust <[lock]> armor_pose:head|0,0,<player.flag[lockpick_pitch].to_radians>
            - wait 2t
        - switch <context.location>
        - animate <player> animation:totem_resurrect
        - narrate "<&7><&o>Your lockpick makes short work of this silly medieval lock!"
        - title "title:<&[emphasis]>Lock Picking Successful"
        - inject lock_pick_end_task
        on player steps on block flagged:lockpicking:
        - flag player lockpicking:!
        #on player walks flagged:lockpicking:
        #- determine passively cancelled
        #- if <context.new_location.distance[<context.old_location>]> > 0.01:
        #    - flag player lockpicking:!
        #    - stop
        #- define yaw <context.new_location.yaw.sub[<context.old_location.yaw>]>
        #- define pitch <context.new_location.pitch.sub[<context.old_location.pitch>]>
        #- define yaw <context.new_location.x.sub[<context.old_location.x>].mul[30]>
        #- define pitch <context.new_location.z.sub[<context.old_location.z>].mul[30]>
        #- flag player lockpick_yaw:+:<[yaw]>
        #- flag player lockpick_pitch:+:<[pitch]>
        on player scrolls their hotbar flagged:lockpicking:
        - determine passively cancelled
        - flag <player> lockpick_yaw:+:<context.new_slot.sub[<context.previous_slot>].mul[3]>
        - if <player.flag[lockpick_yaw]> < -180:
            - flag player lockpick_yaw:+:360
        - if <player.flag[lockpick_yaw]> > 180:
            - flag player lockpick_yaw:-:360

lock_pick_end_task:
    type: task
    debug: false
    definitions: lock|pick
    script:
    - flag player lockpicking:!
    - flag player lockpick_yaw:!
    - flag player lockpick_pitch:!
    - flag player lock_pressing:!
    - repeat 9:
        - fakeitem air slot:<[value]> players:<player> duration:1t
    - remove <[lock]>|<[pick]>
    - stop

lock_pick_entity:
    type: entity
    entity_type: armor_stand
    mechanisms:
        invincible: false
        marker: true
        visible: false
        equipment:
            helmet: lever[enchantments=sharpness,5]

lock_body_entity:
    type: entity
    entity_type: armor_stand
    mechanisms:
        invincible: false
        marker: true
        visible: false
        equipment:
            helmet: clock

lockpick_item:
    type: item
    debug: false
    material: name_tag
    display name: <&[base]>Lockpick
    enchantments:
    - sharpness:5
    mechanisms:
        hides: all
    lore:
    - <&7>Can be used to pick any lock with ease.
