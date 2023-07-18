loreitems_command:
    type: command
    debug: false
    permission: dscript.loreitems
    name: loreitems
    usage: /loreitems [name]
    description: Changes lore on your held item.
    tab completions:
        1: <server.flag[lore_items_sets].keys.parse[unescaped].include[new|rename|delete|edit|category|list]||new>
        2: <context.args.first.equals[list].if_true[<server.flag[lore_items_sets].values.parse[get[category]].include[all].deduplicate||all>].if_false[<server.flag[lore_items_sets].keys.parse[unescaped]||<list>>]||<list>>
        3: <server.flag[lore_items_sets].values.parse[get[category]].deduplicate||<list>>
    script:
    - if <context.args.is_empty>:
        - narrate "<&[error]>/loreitems new [name]"
        - narrate "<&[error]>/loreitems delete [name]"
        - narrate "<&[error]>/loreitems edit [name]"
        - narrate "<&[error]>/loreitems category [name] [category]"
        - narrate "<&[error]>/loreitems rename [old] [new]"
        - narrate "<&[error]>/loreitems list [category] <&[warning]>or <&[error]>/loreitems list all"
        - narrate "<&[error]>/loreitems [name]"
        - narrate "<&[base]>Available categories: <server.flag[lore_items_sets].values.parse[get[category]].deduplicate.parse_tag[<[parse_value].custom_color[emphasis].on_hover[Click To List Category <[parse_value]>].on_click[/loreitems list <[parse_value]>]>].formatted||None>"
        - stop
    - flag player loreitems_edit_allowed:!
    - define first_arg <context.args.first>
    - if <[first_arg]> == new && <context.args.size> == 2 && <player.has_permission[dscript.loreitems_fullstaff]>:
        - define name <context.args.get[2].escaped>
        - if <server.flag[lore_items_sets].contains[<[name]>]>:
            - narrate "<&[error]>That set already exists."
            - stop
        - flag player loreitems_edit_allowed
        - flag server lore_items_sets.<[name]>.category:uncategorized
        - note <inventory[loreitems_inventory]> as:lore_items_set_<[name]>
        - adjust <inventory[lore_items_set_<[name]>]> "title:<&[base]>Lore Items: <&[emphasis]><[name].unescaped>"
        - narrate <&[base]>Created.
        - if <player.cursor_on.has_inventory> && <player.cursor_on.inventory.stacks> > 0:
            - inventory copy o:<player.cursor_on.inventory> d:lore_items_set_<[name]>
            - narrate "<&[base]>... and pre-filled items from the inventory you're facing."
        - inventory set origin:loreitems_make_next_page_button slot:45 destination:lore_items_set_<[name]>
        - flag <inventory[lore_items_set_<[name]>]> loreitems_page:1
        - flag <inventory[lore_items_set_<[name]>]> loreitems_name:<[name]>
        - inventory open d:lore_items_set_<[name]>
        - stop
    - else if <[first_arg]> == delete && <context.args.size> == 2 && <player.has_permission[dscript.loreitems_fullstaff]>:
        - define name <context.args.get[2].escaped>
        - if !<server.flag[lore_items_sets].contains[<[name]>]>:
            - narrate "<&[error]>That set doesn't exist."
            - stop
        - flag server lore_items_sets.<[name]>:!
        - note remove as:lore_items_set_<[name]>
        - define page 2
        - while <inventory[lore_items_set_<[name]>___page___<[page]>].exists>:
            - note remove as:lore_items_set_<[name]>___page___<[page]>
            - define page:++
        - narrate <&[base]>Deleted.
        - stop
    - else if <[first_arg]> == category && <context.args.size> == 3 && <player.has_permission[dscript.loreitems_fullstaff]>:
        - define name <context.args.get[2].escaped>
        - if !<server.flag[lore_items_sets].contains[<[name]>]>:
            - narrate "<&[error]>That set doesn't exist."
            - stop
        - flag server lore_items_sets.<[name]>.category:<context.args.get[3]>
        - narrate "<&[base]>Category updated."
    - else if <[first_arg]> == rename && <context.args.size> == 3 && <player.has_permission[dscript.loreitems_fullstaff]>:
        - define name <context.args.get[2].escaped>
        - if !<server.flag[lore_items_sets].contains[<[name]>]>:
            - narrate "<&[error]>That set doesn't exist."
            - stop
        - define new_name <context.args.get[3].escaped>
        - if <server.flag[lore_items_sets].contains[<[new_name]>]>:
            - narrate "<&[error]>That new set already exists."
            - stop
        - define old_data <server.flag[lore_items_sets.<[name]>]>
        - flag server lore_items_sets.<[name]>:!
        - flag server lore_items_sets.<[new_name]>:<[old_data]>
        - note <inventory[loreitems_inventory]> as:lore_items_set_<[new_name]>
        - adjust <inventory[lore_items_set_<[new_name]>]> "title:<&[base]>Lore Items: <&[emphasis]><[new_name].unescaped>"
        - inventory set d:lore_items_set_<[new_name]> o:lore_items_set_<[name]>
        - flag <inventory[lore_items_set_<[new_name]>]> loreitems_page:1
        - flag <inventory[lore_items_set_<[new_name]>]> loreitems_name:<[new_name]>
        - note remove as:lore_items_set_<[name]>
        - define page 2
        - while <inventory[lore_items_set_<[name]>___page___<[page]>].exists>:
            - note <inventory[loreitems_inventory]> as:lore_items_set_<[new_name]>___page___<[page]>
            - inventory set d:lore_items_set_<[new_name]>___page___<[page]> o:lore_items_set_<[name]>___page___<[page]>
            - flag <inventory[lore_items_set_<[new_name]>___page___<[page]>]> loreitems_page:<[page]>
            - flag <inventory[lore_items_set_<[new_name]>___page___<[page]>]> loreitems_name:<[new_name]>
            - adjust <inventory[lore_items_set_<[new_name]>___page___<[page]>]> "title:<&[base]>Lore Items: <&[emphasis]><[new_name]><&[base]> Page #<&[emphasis]><[page]>"
            - note remove as:lore_items_set_<[name]>___page___<[page]>
            - define page:++
        - narrate "<&[base]>Loreitems set renamed."
        - stop
    - else if <[first_arg]> == list:
        - if <context.args.size> == 2:
            - define sets <server.flag[lore_items_sets].filter_tag[<[filter_value].get[category].equals[<context.args.get[2]>].or[<context.args.get[2].equals[all]>]>]>
            - if <[sets].is_empty>:
                - narrate "<&[error]>No such category exists."
                - stop
            - narrate "<&[base]>Available sets in category '<context.args.get[2].custom_color[emphasis]>': <[sets].keys.parse[unescaped].parse_tag[<[parse_value].custom_color[emphasis].on_hover[Click To View <[parse_value]>].on_click[/loreitems <[parse_value]>]>].formatted||None>"
        - else:
            - narrate "<&[base]>Available categories: <server.flag[lore_items_sets].values.parse[get[category]].deduplicate.parse_tag[<[parse_value].custom_color[emphasis].on_hover[Click To List Category <[parse_value]>].on_click[/loreitems list <[parse_value]>]>].formatted||None>"
        - stop
    - else if <[first_arg]> == edit && <context.args.size> == 2 && <player.has_permission[dscript.loreitems_fullstaff]>:
        - define name <context.args.get[2].escaped>
        - flag player loreitems_edit_allowed
        - define first_arg <[name]>
    - if <[name]||> == <empty>:
        - define name <context.args.first.escaped>
    - if !<server.flag[lore_items_sets].contains[<[name]>]>:
        - narrate "<&[error]>That set doesn't exist."
        - stop
    - if !<player.has_permission[dscript.loreitems_fullstaff]> && !<player.has_permission[dscript.loreitems_category.<server.flag[lore_items_sets.<[name]>.category]>]>:
        - narrate "<&[error]>You don't have permission for that."
        - stop
    - inventory open d:lore_items_set_<[name]>

loreitems_safe_world:
    type: world
    debug: false
    events:
        on player drags in loreitems_inventory:
        - if !<player.has_flag[loreitems_edit_allowed]>:
            - determine cancelled
        on player clicks in loreitems_inventory:
        - if !<player.has_flag[loreitems_edit_allowed]>:
            - if <context.item.material.name||air> != air && <context.clicked_inventory.script.name||null> == loreitems_inventory:
                - run give_safe_item def.item:<context.item>
            - determine cancelled
        on player clicks loreitems_back_button in loreitems_inventory priority:-5:
        - determine passively cancelled
        - define page <context.inventory.flag[loreitems_page]>
        - define name <context.inventory.flag[loreitems_name]>
        - wait 1t
        - if <[page]> == 2:
            - inventory open d:lore_items_set_<[name]>
        - else:
            - inventory open d:lore_items_set_<[name]>___page___<[page].sub[1]>
        on player clicks loreitems_make_next_page_button in loreitems_inventory priority:-5:
        - determine passively cancelled
        - if !<player.has_flag[loreitems_edit_allowed]>:
            - narrate "<&[error]>Cannot generate new pages except when editing."
            - stop
        - define page <context.inventory.flag[loreitems_page]>
        - define name <context.inventory.flag[loreitems_name]>
        - define inv <context.inventory.note_name>
        - wait 1t
        - define new_name lore_items_set_<[name]>___page___<[page].add[1]>
        - if <inventory[<[new_name]>]||null> == null:
            - announce to_console "Lore items <[name]> page <[page]> generated by <player.name>"
            - note <inventory[loreitems_inventory]> as:<[new_name]>
            - adjust <inventory[<[new_name]>]> "title:<&[base]>Lore Items: <&[emphasis]><[name]><&[base]> Page #<&[emphasis]><[page].add[1]>"
            - flag <inventory[<[new_name]>]> loreitems_page:<[page].add[1]>
            - flag <inventory[<[new_name]>]> loreitems_name:<[name]>
            - inventory set origin:loreitems_back_button slot:37 destination:<[new_name]>
            - inventory set origin:loreitems_make_next_page_button slot:45 destination:<[new_name]>
            - inventory set origin:loreitems_next_button slot:45 destination:<[inv]>
        - inventory open d:<[new_name]>
        on player clicks loreitems_next_button in loreitems_inventory priority:-5:
        - determine passively cancelled
        - define page <context.inventory.flag[loreitems_page]>
        - define name <context.inventory.flag[loreitems_name]>
        - wait 1t
        - inventory open d:lore_items_set_<[name]>___page___<[page].add[1]>

loreitems_back_button:
    type: item
    debug: false
    material: player_head
    display name: <&a>Previous Page
    mechanisms:
        skull_skin: 5fecc571-bcbb-4aaa-b53c-b5d8715dbe37|eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvMzdhZWU5YTc1YmYwZGY3ODk3MTgzMDE1Y2NhMGIyYTdkNzU1YzYzMzg4ZmYwMTc1MmQ1ZjQ0MTlmYzY0NSJ9fX0=

loreitems_next_button:
    type: item
    debug: false
    material: player_head
    display name: <&a>Next Page
    mechanisms:
        skull_skin: 79f13daf-4884-40ab-8e35-95e472463321|eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvNjgyYWQxYjljYjRkZDIxMjU5YzBkNzVhYTMxNWZmMzg5YzNjZWY3NTJiZTM5NDkzMzgxNjRiYWM4NGE5NmUifX19

loreitems_make_next_page_button:
    type: item
    debug: false
    material: player_head
    display name: <&a>Generate Next Page
    mechanisms:
        skull_skin: 86324d7a-d1ae-4682-bf77-c1c272fc3523|eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvNjBiNTVmNzQ2ODFjNjgyODNhMWMxY2U1MWYxYzgzYjUyZTI5NzFjOTFlZTM0ZWZjYjU5OGRmMzk5MGE3ZTcifX19

loreitems_inventory:
    type: inventory
    debug: false
    size: 45
    inventory: chest
    title: Unnamed Loreitems
