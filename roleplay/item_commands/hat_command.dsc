hat_command:
    type: command
    name: hat
    debug: false
    usage: /hat
    description: Wears a hat.
    permission: dscript.hat
    script:
    - define hat <player.item_in_hand>
    - if <[hat].material.name> == air:
        - narrate "<&[error]>You must hold an item to put it on your head."
        - stop
    - if !<player.has_permission[dscript.any_hat]>:
        - if <[hat].material.advanced_matches[*banner]>:
            - if !<player.has_permission[dscript.banner_hat]>:
                - narrate "<&[base]>You cannot hat a banner."
                - stop
        - if !<[hat].material.advanced_matches[*helmet|*head|*skull|jack_*|melon|dirt|grass_block|stone|*log|*planks|*wood|*wool|*glass|shield]>:
            - narrate "<&[base]>You cannot hat that item type."
            - stop

    - define helmet <player.equipment_map.get[helmet]||<item[air]>>
    - take iteminhand
    - equip <player> helmet:<[hat]>
    - if <[helmet].material.name> != air:
        - run give_safe_item def.item:<[helmet]>
    - narrate "<&[base]>The hatter hats you with a hat."
