inventory_auto_reformat:
    type: world
    debug: false
    events:
        after player joins:
        - run update_legacy_items def:<player.inventory>
        - wait 1t
        - run update_legacy_items def:<player.enderchest>
        on player opens chest:
        - run update_legacy_items def:<context.inventory>

update_legacy_items:
    type: task
    debug: false
    definitions: inventory
    script:
    - adjust <[inventory]> reformat:scripts
    - repeat <[inventory].size> as:slot:
        - define item <[inventory].slot[<[slot]>]>
        - if <[item].script.data_key[data.should_update]||false> && !<[item].has_flag[buyable]> && !<[item].has_flag[sellable]>:
            - inventory set d:<[inventory]> slot:<[slot]> o:<item[<[item].script.name>].with[quantity=<[item].quantity>]>
