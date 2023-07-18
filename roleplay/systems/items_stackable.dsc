items_stackable_world:
    type: world
    debug: false
    events:
        on server start:
        - announce to_console "item stackable disabled temporarily"
        #- adjust <material[potion]> max_stack_size:64
        #- adjust <material[mushroom_stew]> max_stack_size:64
        #- adjust <material[beetroot_soup]> max_stack_size:64
        #- adjust <material[rabbit_stew]> max_stack_size:64
        #- adjust <material[cake]> max_stack_size:64
