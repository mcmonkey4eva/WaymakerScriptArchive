copypaste_waymakerfixes_world:
    type: world
    #debug: false
    events:
        after custom event id:selpaste_pasted:
        - foreach <context.selection_area.as[cuboid].entities[armor_stand].filter[visible.not].filter[has_flag[name_for]]||<list>> as:stand:
            - if <[stand].flag[name_for].flag[name_marker].filter[uuid.equals[<[stand].uuid>]].is_empty>:
                - remove <[stand]>
