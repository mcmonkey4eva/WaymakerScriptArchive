sit_command:
    type: command
    debug: false
    permission: dscript.sit
    name: sit
    usage: /sit
    description: Sits down wherever you are.
    script:
    - if <list[ocelot].contains[<player.disguised_type.entity_type||null>]>:
        - define sitting <player.has_flag[ocelot_sitting]>
        - if <player.disguise_to_self||null> == null && <player.disguise_to_others||null> == null:
            - narrate "<&[error]>Cannot sit in current disguise due to nobody being able to see the disguise."
            - stop
        - define health 9
        - if <[sitting]>:
            - define health 20
        - if <player.disguise_to_self||null> != null:
            - adjust <player.disguise_to_self> max_health:<[health]>
            - adjust <player.disguise_to_self> health:<[health]>
            - adjust <player> fake_entity_health:[entity=<player.disguise_to_self>;health=<[health]>]
        - if <player.disguise_to_others||null> != null:
            - adjust <player.disguise_to_others> max_health:<[health]>
            - adjust <player.disguise_to_others> health:<[health]>
            - adjust <player.location.find_players_within[50]> fake_entity_health:[entity=<player.disguise_to_others>;health=<[health]>]
        - if <[sitting]>:
            - actionbar "<&[base]>Stood up (disguise)."
            - flag player ocelot_sitting:!
        - else:
            - actionbar "<&[base]>Now sitting (disguise)."
            - flag player ocelot_sitting expire:1d
        - stop
    - if <player.has_flag[sitting]> && <player.vehicle.script.name||null> == temporary_chair_stand_entity:
        - remove <player.vehicle>
        - actionbar "<&[base]>Stood up."
        - teleport <player> <player.flag[sitting]>
        - flag player sitting:!
        - stop
    - if !<player.is_on_ground> && !<player.can_fly>:
        - narrate "<&[error]>You can only sit on ground."
        - stop
    - if <list[cat|wolf|fox|parrot].contains[<player.disguised_type.entity_type||null>]>:
        - if <player.disguise_to_self||null> != null:
            - define sitting <player.disguise_to_self.sitting>
        - else if <player.disguise_to_others||null> != null:
            - define sitting <player.disguise_to_others.sitting>
        - else:
            - narrate "<&[error]>Cannot sit in current disguise due to nobody being able to see the disguise."
            - stop
        - if <player.disguise_to_self||null> != null:
            - adjust <player.disguise_to_self> sitting:<[sitting].not>
        - if <player.disguise_to_others||null> != null:
            - adjust <player.disguise_to_others> sitting:<[sitting].not>
        - if <[sitting]>:
            - actionbar "<&[base]>Stood up (disguise)."
        - else:
            - actionbar "<&[base]>Now sitting (disguise)."
        - stop
    - run sit_task def:<player.location.below[0.2]>
