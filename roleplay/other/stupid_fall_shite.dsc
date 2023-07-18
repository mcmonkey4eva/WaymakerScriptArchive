stupid_fall_shite:
    type: world
    debug: false
    events:
        on player starts sneaking flagged:dumbfall:
        - adjust <player> gliding:true
        on player stops sneaking flagged:dumbfall:
        - adjust <player> gliding:false
        on player stops gliding flagged:dumbfall:
        - determine cancelled

glideshift_command:
    type: command
    debug: false
    permission: dscript.glideshift
    name: glideshift
    usage: /glideshift
    description: Glides when you press shift.
    script:
    - if <player.has_flag[dumbfall]>:
        - flag player dumbfall:!
        - narrate "<&[base]>Disabled glide-shift."
    - else:
        - flag player dumbfall
        - narrate "<&[base]>Enabled glide-shift. Hold shift to fall flat on ya face."

crawl_magic_world:
    type: world
    debug: false
    events:
        on player starts sneaking flagged:crawlshift:
        - flag player crawlshift_active
        - adjust <player> swimming:true
        - flag <player> crawlshift_lastsafe:<player.location>
        - inject crawlshift_showbarrier_task
        on player stops sneaking flagged:crawlshift_active:
        - flag player crawlshift_active:!
        - adjust <player> swimming:false
        - if <player.has_flag[crawlshift_last]>:
            - showfake cancel <player.flag[crawlshift_last].sub[1,1,1].to_cuboid[<player.flag[crawlshift_last].add[1,0,1]>].blocks>
            - flag player crawlshift_last:!
        - if <player.location.above[1.5].center.find_blocks.within[1.42].filter[material.is_solid].any> && <player.has_flag[crawlshift_lastsafe]>:
            - teleport <player> <player.flag[crawlshift_lastsafe].block.add[0.5,0,0.5]>
        - flag <player> crawlshift_lastsafe:!
        on player stops swimming flagged:crawlshift_active:
        - determine cancelled
        after player steps on block flagged:crawlshift_active:
        - if !<player.swimming>:
            - stop
        - inject crawlshift_showbarrier_task
        on player quits flagged:crawlshift_active:
        - flag player crawlshift_active:!
        - flag player crawlshift_last:!
        after player joins flagged:crawlshift:
        - wait 5s
        - if <player.is_online> && !<player.has_permission[dscript.crawlshift]>:
            - flag player crawlshift:!

crawlshift_showbarrier_task:
    type: task
    debug: false
    script:
    - if <player.has_flag[crawlshift_last]>:
        - showfake cancel <player.flag[crawlshift_last].sub[1,1,1].to_cuboid[<player.flag[crawlshift_last].add[1,0,1]>].blocks>
    - flag player crawlshift_last:<player.location.above>
    - define cuboid <player.location.above.sub[1,0,1].to_cuboid[<player.location.above.add[1,0,1]>]>
    - showfake barrier <[cuboid].blocks[air]> d:0
    - showfake barrier <[cuboid].blocks[!air].parse[below].filter[material.name.equals[air]]> d:0
    - if !<player.location.above[1.5].material.is_solid>:
        - flag <player> crawlshift_lastsafe:<player.location>

crawlshift_command:
    type: command
    debug: false
    permission: dscript.crawlshift
    name: crawlshift
    usage: /crawlshift
    description: Crawls when you press shift.
    script:
    - if <player.has_flag[crawlshift]>:
        - flag player crawlshift:!
        - flag player crawlshift_active:!
        - narrate "<&[base]>Disabled crawl-shift."
        - if <player.has_flag[crawlshift_last]>:
            - showfake cancel <player.flag[crawlshift_last].sub[1,0,1].to_cuboid[<player.flag[crawlshift_last].add[1,0,1]>].blocks>
            - flag <player> crawlshift_last:!
    - else:
        - flag player crawlshift
        - narrate "<&[base]>Enabled crawl-shift. Hold shift to fall flat on ya face."
