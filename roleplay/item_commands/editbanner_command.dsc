editbanner_command:
    type: command
    debug: false
    name: editbanner
    usage: /editbanner (reset)
    description: Edits a banner creatively.
    permission: dscript.editbanner
    script:
    - define item <player.item_in_hand>
    - if !<context.args.is_empty>:
        - if <context.args.first||> == reset:
            - if !<[item].has_flag[editbanner_id]>:
                - narrate "<&[error]>This banner has never been edited by editbanner, and therefore the patterns cannot be reset."
                - stop
            - adjust def:item patterns:<list>
            - narrate "<&[base]>Banner item patterns reset to blank."
            - adjust def:item flag:editbanner_id:!
            - if <[item].has_flag[bound_to]>:
                - adjust def:item flag:bound_sources:<-:editbanner
                - if <[item].flag[bound_sources].if_null[<list>].is_empty>:
                    - adjust def:item flag:bound_sources:!
                    - adjust def:item flag:bound_to:!
                    - narrate "<&[base]>This banner item is no longer bound to you, and may now be given to other players if desired."
            - inventory set d:<player.inventory> slot:hand o:<[item]>
            - stop
        - else:
            - narrate "<&[error]>/editbanner <&[base]>- to edit your held banner. This will bind the item to you."
            - narrate "<&[error]>/editbanner reset <&[base]>- to remove the banner patterns, and unbind it from you."
            - stop
    - if !<[item].material.name.ends_with[_banner]>:
        - narrate "<&[error]>Must be holding a banner."
        - stop
    - if !<[item].proc[bound_can_hold_proc].context[<player>]>:
        - narrate "<&[error]>This item is bound to <&[base]><[item].flag[bound_to].proc[proc_format_name].context[<player>]><&[error]>. You must return it at once."
        - stop
    - if !<player.has_permission[dscript.staff_bound_override]>:
        - if !<[item].has_flag[bound_to]>:
            - adjust def:item flag:bound_to:<player>
            - narrate "<&[base]>This banner item is now bound to you. You cannot give it to other players unless you use <&[error]>/editbanner reset"
        - if !<[item].flag[bound_sources].if_null[<list>].contains[editbanner]>:
            - adjust def:item flag:bound_sources:->:editbanner
    - flag server editbanner_id_ticker:++
    - flag player editbanner_id:<server.flag[editbanner_id_ticker]>
    - adjust def:item flag:editbanner_id:<server.flag[editbanner_id_ticker]>
    - inventory set d:<player.inventory> slot:hand o:<[item]>
    - flag player held_banner:<[item]>
    - inventory open d:banner_edit_gui_color

editbanner_world:
    type: world
    debug: false
    events:
        on player clicks *_dye in banner_edit_gui_color:
        - flag <player> banner_edit_gui_color:<context.item.material.name.before_last[_]>
        - determine passively cancelled
        #- wait 1t
        - inventory open d:banner_edit_gui_pattern
        on player clicks banner_gui_back_button in inventory:
        - determine passively cancelled
        - wait 1t
        - inventory open d:banner_edit_gui_color
        on player clicks banner_gui_cancel_button in inventory:
        - determine passively cancelled
        - wait 1t
        - inventory close
        on player clicks *banner in banner_edit_gui_pattern:
        - define pattern <context.item.flag[pattern]>
        - determine passively cancelled
        #- wait 1t
        - define item <player.item_in_hand>
        - if !<[item].material.name.ends_with[_banner]> || <[item].flag[editbanner_id]> != <player.flag[editbanner_id]>:
            - inventory close
            - stop
        - define patterns <[item].patterns||<list>>
        - define color <player.flag[banner_edit_gui_color]||white>
        - inventory adjust slot:hand patterns:<[patterns].include[<[color]>/<[pattern]>]>
        - flag player held_banner:<player.item_in_hand>
        - inventory open d:banner_edit_gui_color

editbanner_data:
    type: data
    patterns: BASE|BORDER|BRICKS|CIRCLE_MIDDLE|CREEPER|CROSS|CURLY_BORDER|DIAGONAL_LEFT|DIAGONAL_LEFT_MIRROR|DIAGONAL_RIGHT|DIAGONAL_RIGHT_MIRROR|FLOWER|GLOBE|GRADIENT|GRADIENT_UP|HALF_HORIZONTAL|HALF_HORIZONTAL_MIRROR|HALF_VERTICAL|HALF_VERTICAL_MIRROR|MOJANG|PIGLIN|RHOMBUS_MIDDLE|SKULL|SQUARE_BOTTOM_LEFT|SQUARE_BOTTOM_RIGHT|SQUARE_TOP_LEFT|SQUARE_TOP_RIGHT|STRAIGHT_CROSS|STRIPE_BOTTOM|STRIPE_CENTER|STRIPE_DOWNLEFT|STRIPE_DOWNRIGHT|STRIPE_LEFT|STRIPE_MIDDLE|STRIPE_RIGHT|STRIPE_SMALL|STRIPE_TOP|TRIANGLE_BOTTOM|TRIANGLE_TOP|TRIANGLES_BOTTOM|TRIANGLES_TOP
    dyes: BLACK|BLUE|BROWN|CYAN|GRAY|GREEN|LIGHT_BLUE|LIGHT_GRAY|LIME|MAGENTA|ORANGE|PINK|PURPLE|RED|WHITE|YELLOW

banner_edit_gui_color:
    type: inventory
    debug: false
    inventory: chest
    size: 54
    title: Select New Pattern Color
    gui: true
    procedural items:
    - determine <script[editbanner_data].data_key[dyes].as[list].parse_tag[<[parse_value]>_dye]>
    slots:
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] [banner_gui_cancel_button]

banner_edit_gui_pattern:
    type: inventory
    debug: false
    inventory: chest
    size: 54
    title: Select New Pattern
    gui: true
    procedural items:
    - define item <player.flag[held_banner]||<item[white_banner]>>
    - define patterns <[item].patterns||<list>>
    - define color <player.flag[banner_edit_gui_color]||white>
    - define list <list>
    - foreach <script[editbanner_data].data_key[patterns]> as:pattern:
        - define "list:->:<[item].with_single[display=<&f>Pattern: <[pattern].replace[_].with[ ].to_titlecase>].with_single[patterns=<[patterns].include[<[color]>/<[pattern]>]>].with_flag[pattern:<[pattern]>]>"
    - determine <[list]>
    slots:
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [banner_gui_back_button] [] [] [] [] [] [] [] [banner_gui_cancel_button]

banner_gui_back_button:
    type: item
    debug: false
    material: player_head
    display name: <&c>Back
    mechanisms:
        skull_skin: 5fecc571-bcbb-4aaa-b53c-b5d8715dbe37|eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvMzdhZWU5YTc1YmYwZGY3ODk3MTgzMDE1Y2NhMGIyYTdkNzU1YzYzMzg4ZmYwMTc1MmQ1ZjQ0MTlmYzY0NSJ9fX0=

banner_gui_cancel_button:
    type: item
    debug: false
    material: barrier
    display name: <&c>Cancel / Done
