generic_inv_shop_inv:
    type: inventory
    inventory: chest
    size: 54

generic_inv_shop_editing_inv:
    type: inventory
    inventory: chest
    size: 54

generic_inv_shop_open_command:
    type: command
    debug: false
    name: openshopinv
    usage: /openshopinv [name]
    description: Opens a shop inventory by name.
    permission: dscript.openshopinv
    tab completions:
        1: <server.flag[generic_shop].keys||<list>>
    script:
    - if <context.args.is_empty>:
        - narrate "<&[error]>/openshopinv [name]"
        - stop
    - define shopname <context.args.first.escaped>
    - if !<server.has_flag[generic_shop.<[shopname]>]>:
        - narrate "<&[error]>No known shop by that name."
        - stop
    - inventory open d:generic_shop_<[shopname]>

generic_inv_shop_edit_command:
    type: command
    debug: false
    name: editshopinv
    usage: /editshopinv [name]
    description: Edit a shop inventory by name.
    permission: dscript.editshopinv
    tab completions:
        1: <list[<server.flag[generic_shop].keys||<list>>].include[new|delete]>
    script:
    - if <context.args.is_empty>:
        - narrate "<&[error]>/editshopinv [name]"
        - narrate "<&[error]>/editshopinv new [name] [price]"
        - narrate "<&[error]>/editshopinv delete [name]"
        - stop
    - define shopname <context.args.first.escaped>
    - if <[shopname]> == new && <context.args.size> == 3:
        - if !<context.args.get[3].is_integer> || <context.args.get[3]> < 1 || <context.args.get[3].length> > 6:
            - narrate "<&[error]>Item price must be an integer number above 0."
            - stop
        - define shopname <context.args.get[2].escaped>
        - flag server generic_shop.<[shopname]>.price:<context.args.get[3]>
        - note <inventory[generic_inv_shop_editing_inv]> as:generic_shop_editor_<[shopname]>
        - note <inventory[generic_inv_shop_inv]> as:generic_shop_<[shopname]>
    - else if <[shopname]> == delete && <context.args.size> == 2:
        - define shopname <context.args.get[2].escaped>
        - if !<server.has_flag[generic_shop.<[shopname]>]>:
            - narrate "<&[error]>No known shop by that name."
            - stop
        - flag server generic_shop.<[shopname]>:!
        - note remove as:generic_shop_editor_<[shopname]>
        - note remove as:generic_shop_<[shopname]>
        - narrate "<&[base]>Shop deleted."
        - stop
    - if !<server.has_flag[generic_shop.<[shopname]>]>:
        - narrate "<&[error]>No known shop by that name."
        - stop
    - flag player editing_shop:<[shopname]>
    - inventory open d:generic_shop_editor_<[shopname]>

generic_inv_shop_world:
    type: world
    debug: false
    events:
        on player drags in generic_inv_shop_inv priority:100:
        - determine cancelled
        on player clicks in generic_inv_shop_inv priority:100:
        - determine cancelled
        on player closes generic_inv_shop_editing_inv flagged:editing_shop:
        - define shopname <player.flag[editing_shop]>
        - define price <server.flag[generic_shop.<[shopname]>.price]||0>
        - if <[price]> > 0:
            - inventory clear d:generic_shop_<[shopname]>
            - foreach <context.inventory.list_contents> as:item:
                - if <[item].material.name||air> != air:
                    - inventory set d:generic_shop_<[shopname]> o:<proc[buyable_item_proc].context[<list_single[<[item]>].include[<[price]>]>]> slot:<[loop_index]>
        - flag player editing_shop:!


######################
##### OUR SHOPS
######################


library_command:
    type: command
    debug: false
    name: library
    usage: /library
    description: Opens the library shop.
    permission: dscript.library
    script:
    - inventory open d:generic_shop_library

buybook_command:
    type: command
    debug: false
    name: buybook
    usage: /buybook
    description: Opens the writable book shop.
    permission: dscript.buybook
    script:
    - inventory open d:generic_shop_writable_books
