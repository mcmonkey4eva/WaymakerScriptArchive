invis_frame_name_remover:
    type: world
    debug: false
    events:
        after player right clicks item_frame with:!air bukkit_priority:monitor:
        - if <context.entity.is_spawned> && !<context.entity.visible> && <context.entity.framed_item.display.exists> && <player.gamemode> == creative:
            - adjust <context.entity> framed:<context.entity.framed_item.with[display=]>
