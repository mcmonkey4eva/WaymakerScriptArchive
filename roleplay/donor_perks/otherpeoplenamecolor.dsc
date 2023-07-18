
custom_name_colors_world:
    type: world
    debug: false
    events:
        after player joins:
        - wait 5s
        - if !<player.is_online>:
            - stop
        - if <player.has_permission[dscript.donor_setnamecolors]>:
            - flag player can_use_altnamecolor
        - else:
            - flag player can_use_altnamecolor:!
        - if <player.has_permission[dscript.donor_setplayernamecolors]>:
            - flag player can_use_playernamecolor
        - else:
            - flag player can_use_playernamecolor:!
