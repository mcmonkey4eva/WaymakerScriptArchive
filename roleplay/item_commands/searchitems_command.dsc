searchitems_command:
    type: command
    debug: false
    permission: dscript.searchitems
    name: searchitems
    usage: /searchitems [search term]
    aliases:
    - searchitem
    - itemsearch
    description: Searches item names and lores across the server for a search term.
    script:
    - if <context.args.is_empty>:
        - narrate "<&[error]>/searchitems [search term]"
        - stop
    - narrate "<&[base]>Please wait, searching..."
    - define name_matches <list>
    - define lore_matches <list>
    - foreach <server.flag[lore_items_sets].keys||<list>> as:lore_items:
        - define in <element[/loreitems <[lore_items].unescaped>].on_click[/loreitems <[lore_items].unescaped>].on_hover[(Click Here)]>
        - define inv <inventory[lore_items_set_<[lore_items]>]>
        - inject <script> path:search_inv
        - if <[loop_index].mod[10]> == 1:
            - wait 1t
    - foreach <server.players> as:player:
        - define in <element[/invsee <[player].name>].on_click[/invsee <[player].name>].on_hover[(Click Here)]>
        - define inv <[player].inventory>
        - inject <script> path:search_inv
        - define in <element[/enderchest <[player].name>].on_click[/enderchest <[player].name>]>
        - define inv <[player].enderchest>
        - inject <script> path:search_inv
        - if <inventory[gamemode_survival_inv_record_for_<[player].uuid>]||null> != null:
            - define in <element[/invsee <[player].name> survival].on_click[/invsee <[player].name> survival].on_hover[(Click Here)]>
            - define inv <inventory[gamemode_survival_inv_record_for_<[player].uuid>]>
            - inject <script> path:search_inv
        - if <inventory[gamemode_creative_inv_record_for_<[player].uuid>]||null> != null:
            - define in <element[/invsee <[player].name> creative].on_click[/invsee <[player].name> creative].on_hover[(Click Here)]>
            - define inv <inventory[gamemode_creative_inv_record_for_<[player].uuid>]>
            - inject <script> path:search_inv
        - if <[loop_index].mod[10]> == 1:
            - wait 1t
    - if <[name_matches].size.add[<[lore_matches].size>]> == 0:
        - narrate "<&[error]>No matches found."
        - stop
    - narrate "<&[base]>=== Search results for <&[emphasis]><context.raw_args> <&[base]>==="
    - if <[name_matches].size> > 0:
        - narrate "<&[base]>Matched by name: <[name_matches].separated_by[, ]>"
    - if <[lore_matches].size> > 0:
        - narrate "<&[base]>Matched by lore: <[lore_matches].separated_by[, ]>"
    search_inv:
    - define possible <[inv].list_contents.filter[has_display]>
    - define temp_name_matches <[possible].filter[display.strip_color.contains[<context.raw_args>]]>
    - define temp_lore_matches <[possible].filter[lore.separated_by[ ].strip_color.contains[<context.raw_args>]].exclude[<[temp_name_matches]>]>
    - foreach <[temp_name_matches]> as:match:
        - define "name_matches:->:<&[base]>In <&[emphasis]><[in]>: <&[base]>[<element[<&[emphasis]><[match].display||<[match].material.translated_name>>].on_hover[<[match]>].type[show_item]>]"
    - foreach <[temp_lore_matches]> as:match:
        - define "lore_matches:->:<&[base]>In <&[emphasis]><[in]>: <&[base]>[<element[<&[emphasis]><[match].display||<[match].material.translated_name>>].on_hover[<[match]>].type[show_item]>]"
    - if <[name_matches].size.add[<[lore_matches].size>]> > 80:
        - foreach stop
