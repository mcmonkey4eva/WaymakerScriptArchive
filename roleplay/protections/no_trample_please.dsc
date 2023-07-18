no_trample_world:
    type: world
    debug: false
    events:
        on entity changes farmland:
        - determine cancelled
        on hanging breaks:
        - if <context.cause> != entity:
            - determine cancelled
        - if <context.entity.entity_type||unknown> != player:
            - determine cancelled
        on hanging damaged:
        - if <context.damager.entity_type||unknown> != player || <context.projectile.exists>:
            - determine cancelled
