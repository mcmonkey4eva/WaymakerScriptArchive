getitem_command:
    type: command
    debug: false
    name: getitem
    usage: /getitem [item]
    description: Gets you an item.
    permission: dscript.getitem
    aliases:
    - itemget
    tab completions:
        1: <server.material_types.filter[is_item].parse[name].include[<util.list_numbers_to[15].parse_tag[light[level=<[parse_value]>]]>]>
    script:
    - if <context.args.is_empty>:
        - narrate "<&[error]>/getitem [item]"
        - narrate "<&[warning]>For example: <&[error]>/getitem stick"
        - narrate "<&[warning]>Or: <&[error]>/getitem light[level=10]"
        - stop
    - define item <context.args.first>
    - if <[item].contains_text[<&lb>]>:
        - choose <[item].before[<&lb>]>:
            - case light:
                - if !<[item].starts_with[light<&lb>level=]> || !<[item].ends_with[<&rb>]>:
                    - narrate "<&[error]>Invalid LIGHT item input. Should be like <&[warning]>light[level=10]"
                    - stop
                - define level <[item].after[=].before_last[<&rb>]>
                - if !<[level].is_integer> || <[level]> < 1 || <[level]> > 15:
                    - narrate "<&[error]>Invalid light level - not a number, out of range 1-15."
                    - stop
                - define item <item[light[block_material=light[level=<[level]>]]]>
            - default:
                - narrate "<&[error]>Material name given is invalid or does not support extra properties."
                - stop
    - else:
        - define item <[item].as[item]||null>
        - if <[item]> == null:
            - narrate "<&[error]>Invalid item name."
            - stop
    - run give_safe_item def.item:<[item]>
    - narrate "<&[base]>Here's your <[item].material.translated_name.on_hover[<[item]>].type[show_item].custom_color[emphasis]>!"
