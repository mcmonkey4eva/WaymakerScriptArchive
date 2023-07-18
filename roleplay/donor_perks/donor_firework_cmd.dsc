donor_firework_command:
    type: command
    debug: false
    name: firework
    description: Launches a firework at your location.
    usage: /firework
    permission: dscript.donor_firework
    script:
    - if <player.has_flag[donor_firework_cooldown]>:
        - narrate "<&[error]>You must wait <&[emphasis]><player.flag_expiration[donor_firework_cooldown].from_now.formatted><&[error]> before you can launch another firework display."
        - stop
    - flag player donor_firework_cooldown duration:1h
    - define count <util.random.int[1].to[3]>
    - if <player.has_permission[dscript.donor_firework_extra]>:
        - define count <util.random.int[4].to[6]>
    - repeat <[count]>:
        - firework <player.eye_location.random_offset[2]> power:<util.random.int[1].to[2]> random primary:random fade:random flicker trail save:firework
        - adjust <entry[firework].launched_firework> velocity:<util.random.decimal[-0.03].to[0.03]>,0.2,<util.random.decimal[-0.03].to[0.03]>
        - wait 7t
