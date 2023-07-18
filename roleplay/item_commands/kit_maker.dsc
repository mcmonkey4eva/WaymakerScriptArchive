kit_maker_task:
    type: task
    debug: false
    definitions: kit_name|file_name
    script:
    - define target <player.cursor_on.inventory||null>
    - if <[target]> == null || <[file_name]||null> == null:
        - narrate <&c>Nope.
        - stop
    - if <util.has_file[kitthing/<[file_name]>.yml]>:
        - yaml load:kitthing/<[file_name]>.yml id:kit_maker
    - else:
        - yaml create id:kit_maker
    - define items <list>
    - foreach <[target].list_contents> as:item:
        - if <[item].material.name||air> != air && <[item].has_lore>:
            - define name <[item].display.strip_color.to_lowercase.replace_text[ ].with[_]||null>
            - if <[name]> == null:
                - narrate "bork item <[item]>"
                - foreach next
            - define name kit_item_<[name]>
            - yaml id:kit_maker set <[name]>.debug:false
            - yaml id:kit_maker set <[name]>.type:item
            - yaml id:kit_maker set "<[name]>.display name:<[item].display>"
            - yaml id:kit_maker set <[name]>.material:<[item].material.name>
            - yaml id:kit_maker set <[name]>.lore:!|:<[item].lore>
            - if !<[item].hides.is_empty||true>:
                - yaml id:kit_maker set <[name]>.mechanisms.hides:<[item].hides>
            - foreach <[item].list_flags> as:flag:
                - yaml id:kit_maker set <[name]>.flag.<[flag]>:<[item].flag[<[flag]>]>
            - if <[item].material.name> == player_head:
                - yaml id:kit_maker set <[name]>.mechanisms.skull_skin:<[item].skull_skin>
            - if <[item].quantity> == 1:
                - define items:->:<[name]>
            - else:
                - define items:->:<[name]>[quantity=<[item].quantity>]
    - yaml id:kit_maker set kit_list.type:data
    - yaml id:kit_maker set kit_list.<[kit_name]>:!|:<[items]>
    - yaml id:kit_maker savefile:kitthing/<[file_name]>.yml
    - yaml id:kit_maker unload
