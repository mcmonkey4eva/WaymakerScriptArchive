item_movement_log:
    type: world
    debug: false
    events:
        on player drops item priority:100:
        - announce to_console "<&7>ITEM LOG PLAYER <player.name> at <player.location.simple||?> drops item: <proc[item_loggable_proc].context[<context.item>]>"
        on player picks up item priority:100:
        - announce to_console "<&7>ITEM LOG PLAYER <player.name> at <player.location.simple||?> picks up item: <proc[item_loggable_proc].context[<context.item>]>"
        on player clicks in inventory priority:100:
        - announce to_console "<&7>ITEM LOG PLAYER <player.name> at <player.location.simple||?> clicks in inventory <context.clicked_inventory.inventory_type||?> at <context.raw_slot>, cursor: <proc[item_loggable_proc].context[<context.cursor_item>]>, slot: <proc[item_loggable_proc].context[<context.item>]>"
        on player drags in inventory priority:100:
        - announce to_console "<&7>ITEM LOG PLAYER <player.name> at <player.location.simple||?> drags in inventory <context.clicked_inventory.inventory_type> at <context.raw_slots.comma_separated>, item: <proc[item_loggable_proc].context[<context.item>]>"
        on player breaks held item priority:100:
        - announce to_console "<&7>ITEM LOG PLAYER <player.name> at <player.location.simple||?> broke their held item: <proc[item_loggable_proc].context[<context.item>]>"
        on player consumes item priority:100:
        - announce to_console "<&7>ITEM LOG PLAYER <player.name> at <player.location.simple||?> consumes item: <proc[item_loggable_proc].context[<context.item>]>"
        on player crafts item priority:100:
        - announce to_console "<&7>ITEM LOG PLAYER <player.name> at <player.location.simple||?> crafts x<context.amount> item: <proc[item_loggable_proc].context[<context.item>]> made from recipe <context.recipe.parse_tag[<proc[item_loggable_proc].context[<[parse_value]>]>].formatted>"
        on player fishes priority:100:
        - if <context.item||null> == null:
            - stop
        - announce to_console "<&7>ITEM LOG PLAYER <player.name> at <player.location.simple||?> fishes: <proc[item_loggable_proc].context[<context.item>]>"
        on player places block priority:100:
        - if <context.item||null> == null:
            - stop
        - announce to_console "<&7>ITEM LOG PLAYER <player.name> at <player.location.simple||?> places block: <proc[item_loggable_proc].context[<context.item_in_hand>]>"
        on item enchanted priority:100:
        - if <player||null> == null:
            - stop
        - announce to_console "<&7>ITEM LOG PLAYER <player.name> at <player.location.simple||?> enchants item: <proc[item_loggable_proc].context[<context.item>]>"
        on item merges priority:100:
        - announce to_console "<&7>ITEM LOG at <context.location.simple||?> items merge: <proc[item_loggable_proc].context[<context.item>]>"
        on item moves from inventory priority:100:
        - ratelimit <context.origin.location.simple>_<context.item.material.name> 10s
        - announce to_console "<&7>ITEM LOG hopper-move at <context.origin.location.simple||?> from <context.origin.inventory_type> to <context.destination.inventory_type> for item: <proc[item_loggable_proc].context[<context.item>]>"
        on item spawns priority:100:
        - announce to_console "<&7>ITEM LOG at <context.location.simple||?> item spawns: <proc[item_loggable_proc].context[<context.item>]>"
        on item despawns priority:100:
        - announce to_console "<&7>ITEM LOG at <context.location.simple||?> item despawns: <proc[item_loggable_proc].context[<context.item>]>"
        on block drops item from breaking priority:100:
        - if <context.drop_entities.is_empty>:
            - stop
        - announce to_console "<&7>ITEM LOG at <context.location.simple||?> block of type <context.material.name> broke and dropped: <context.drop_entities.parse_tag[<proc[item_loggable_proc].context[<[parse_value].item>]>].formatted>"

item_loggable_proc:
    type: procedure
    debug: false
    definitions: item
    script:
    - if <[item].material.name> == air:
        - determine air
    - define output "<[item].quantity>x <[item].material.name>"
    - if <[item].has_display>:
        - define output "<[output]> (name: <[item].display>)"
    - if <[item].durability||0> != 0:
        - define output "<[output]> (dura: <[item].durability>)"
    - determine <[output]>
