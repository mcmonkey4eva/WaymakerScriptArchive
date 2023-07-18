flide_cmd:
    type: command
    debug: false
    name: flide
    description: Flide into the skyde!
    usage: /flide
    permission: denizen.flide
    script:
    - if !<player.has_permission[denizen.flide]||false>:
        - narrate <&[error]>Nope!
        - stop
    - actionbar "<gold>Launching! Hold sneak to land!"
    - adjust <player> velocity:0,2,0
    - wait 14t
    - adjust <player> gliding:true
    - while <player.is_online> && <player.is_spawned> && !<player.is_on_ground> && <player.gliding> && !<player.is_sneaking>:
        - adjust <player> velocity:<player.location.direction.vector.mul[2]>
        - wait 1t

flide2_cmd:
    type: command
    debug: false
    name: flide2
    description: Flide into the skyde! v2.0!
    usage: /flide2
    permission: denizen.flide2
    script:
    - if !<player.has_permission[denizen.flide2]||false>:
        - narrate <&[error]>Nope!
        - stop
    - actionbar "<gold>Launching! Hold sneak to land!"
    - adjust <player> velocity:0,2,0
    - wait 14t
    - adjust <player> gliding:true
    - while <player.is_online> && <player.is_spawned> && !<player.is_on_ground> && <player.gliding> && !<player.is_sneaking>:
        - define vel <player.velocity.add[<player.location.direction.vector.mul[0.05]>]>
        - if <[vel].vector_length> > 2.5:
            - define vel <[vel].normalize.mul[2.5]>
        - adjust <player> velocity:<[vel]>
        - wait 1t
