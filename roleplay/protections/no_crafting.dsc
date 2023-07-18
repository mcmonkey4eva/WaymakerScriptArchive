crafting_disable:
    type: world
    debug: false
    events:
        on server start:
        - define allowed <server.recipe_ids.filter[starts_with[denizen]]>
        - define allowed:|:<server.recipe_ids.exclude[<[allowed]>].filter[ends_with[from_campfire_cooking]]>
        #- define allowed:|:minecraft:crafting_table|minecraft:chest
        #- foreach spruce|oak|dark_oak|birch|jungle|acacia as:wood:
        #    - foreach stairs|button|slab|trapdoor|door|planks|pressure_plate|fence|wood|sign|fence_gate as:part:
        #        - define allowed:->:minecraft:<[wood]>_<[part]>
        #- define allowed:|:minecraft:stick
        - adjust server remove_recipes:<server.recipe_ids.exclude[<[allowed]>]>
