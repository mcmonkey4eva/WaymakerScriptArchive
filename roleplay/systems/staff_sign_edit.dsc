staff_sign_edit_world:
    type: world
    debug: false
    events:
        on player right clicks *_sign permission:dscript.staff_sign_edit:
        - if <player.item_in_hand.material.name> != air:
            - stop
        - if <player.gamemode> != creative:
            - stop
        - adjust <player> edit_sign:<context.location>
        on player changes sign permission:dscript.staff_sign_edit:
        - if <player.gamemode> != creative:
            - stop
        - determine <context.new.parse[parse_color]>
