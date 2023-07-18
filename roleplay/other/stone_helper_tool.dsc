stone_helper_tool_item:
    type: item
    debug: false
    material: netherite_sword
    display name: <&b>Block Type Swapper
    enchantments:
    - luck_of_the_sea:1
    mechanisms:
        hides: all

stone_helper_tool_world:
    type: world
    debug: false
    events:
        on player right clicks block with:stone_helper_tool_item:
        - if !<player.has_permission[dscript.blockswapper]>:
            - stop
        - define loc <context.location||<player.cursor_on[15]||null>>
        - if <[loc]> == null:
            - stop
        - define match_types <context.item.flag[swapper_match_types]||null>
        - define new_types <context.item.flag[swapper_new_types]||null>
        - if <[match_types]> == null || <[new_types]> == null:
            - stop
        - foreach <[loc].find_blocks[<[match_types]>].within[5]> as:block:
            - if <[block].material.property_map.is_empty||true>:
                - modifyblock <[block]> <[new_types].random> no_physics
            - else:
                - modifyblock <[block]> <[new_types].random>[<[block].material.after[<&lb>]> no_physics

block_swapper_command:
    type: command
    debug: false
    name: blockswapper
    permission: dscript.blockswapper
    usage: /blockswapper [matcher] [replacement list]
    description: Gets a block swapper tool.
    tab complete:
    - define arg <context.args.last||>
    - if <context.raw_args.ends_with[ ]>:
        - define arg <empty>
    - define piped <[arg].replace_text[|].with[,]>
    - if !<[piped].contains_text[,]>:
        - determine <server.material_types.parse[name].filter[starts_with[<[arg]>]]>
    - define last_pipe <[piped].last_index_of[,]>
    - define before <[arg].substring[0,<[last_pipe]>]>
    - define after <[arg].substring[<[last_pipe].add[1]>]>
    - determine <server.material_types.parse[name].filter[starts_with[<[after]>]].parse_tag[<[before]><[parse_value]>]>
    script:
    - if <context.args.size> < 2:
        - narrate "<&[error]>/blockswapper [find matcher] [replacement matcher]"
        - narrate "<&[warning]>Example: to randomize stone stair type: <&[error]>/blockswapper *stone*stairs cobblestone*stairs|stone*stairs|*andesite*stairs"
        - stop
    - define match_types <server.material_types.filter[is_block].filter[advanced_matches[<context.args.get[1].replace_text[,].with[|]>]].parse[name]>
    - define new_types <server.material_types.filter[is_block].filter[advanced_matches[<context.args.get[2].replace_text[,].with[|]>]].parse[name]>
    - if <[match_types].is_empty||true>:
        - narrate "<&[error]>Find matcher doesn't match any block types."
        - stop
    - if <[new_types].is_empty||true>:
        - narrate "<&[error]>Replacement matcher doesn't match any block types."
        - stop
    - define item <item[stone_helper_tool_item].with_flag[swapper_match_types:<[match_types]>]>
    - define item <[item].with_flag[swapper_new_types:<[new_types]>]>
    - adjust def:item lore:<list[<&6>Does automatic block type swapping].include_single[<&6>Matches <[match_types].size>: <&f><context.args.get[1]>].include_single[<&6>Replaces to <[new_types].size>: <&f><context.args.get[2]>]>
    - run give_safe_item def.item:<[item]>
    - narrate "<&[base]>Here's your replacer!"
