placeable_item_command:
    type: command
    debug: false
    permission: dscript.placeableitem
    name: placeableitem
    usage: /placeableitem [material] [id] [name]
    description: Creates a new placeable item.
    tab completions:
        1: <server.material_types.parse[name]>
        2: <util.list_numbers_to[50]>
    script:
    - if <context.args.size> < 3:
        - narrate "<&[error]>/placeableitem [material] [id] [name]"
        - narrate "<&[error]>For example: <&[warning]>/placeableitem book 7 Game Set"
        - stop
    - if !<material[<context.args.first>].exists>:
        - narrate "<&[error]>That material name doesn't exist."
        - stop
    - define material <context.args.first>
    - define id <context.args.get[2]>
    - if !<[id].is_integer>:
        - narrate "<&[error]>ID must be a number."
        - stop
    - if <[id]> < 1 || <[id]> > 1000:
        - narrate "<&[error]>That ID number looks wrong or is out of range."
        - stop
    - define name <&f><context.args.get[3].to[last].space_separated.parse_color>
    - definemap data:
        display: <[name]>
        custom_model_data: <[id].add[100000]>
        hides: all
    - define item <item[<[material]>].with_flag[placeable_item_model].with_map[<[data]>]||null>
    - if <[item]> == null:
        - narrate "<&[error]>Something went wrong."
        - stop
    - run give_safe_item def.item:<[item]>
    - narrate "<&[base]>Here's your <[item].display.on_hover[<[item]>].type[show_item]><&[base]>!"
