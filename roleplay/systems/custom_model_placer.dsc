custom_model_placer_world:
    type: world
    debug: false
    events:
        on player right clicks block type:!air with:item_flagged:placeable_item_model priority:10:
        - inject build_protect_task
        on player right clicks block type:!air with:item_flagged:placeable_item_model priority:15:
        - define normal <player.eye_location.ray_trace[return=normal]>
        - define loc <player.eye_location.ray_trace.add[<[normal].mul[0.03]>]>
        - if <player.gamemode> != creative || !<[loc].material.advanced_matches[air]||false> || <[loc].center.find_entities[item_frame].within[0.5].any>:
            - stop
        - determine passively cancelled
        - choose <[normal].block.xyz>:
            - case 1,0,0:
                - define rotation east
            - case -1,0,0:
                - define rotation west
            - case 0,0,1:
                - define rotation south
            - case 0,0,-1:
                - define rotation north
            - case 0,-1,0:
                - define rotation down
            - default:
                - define rotation up
        - spawn <entity[item_frame[rotation=<[rotation]>;visible=false]].with_map[<map.with[framed].as[<context.item.with[display=]>]>]> <[loc]> save:new_frame
        - flag <entry[new_frame].spawned_entity> special_frame_item:<context.item>
        #- adjust <entry[new_frame].spawned_entity> framed:<context.item.with[display=]>
        - playsound <entry[new_frame].spawned_entity.location> sound:block_glass_place volume:0.5
        on player damages item_frame priority:10:
        - if !<context.entity.has_flag[special_frame_item]>:
            - stop
        - inject build_protect_task
        on player damages item_frame priority:15:
        - if !<context.entity.has_flag[special_frame_item]>:
            - stop
        - if <player.gamemode> != creative:
            - stop
        - if <context.entity.framed_item> matches book:
            - if <context.entity.flag[special_frame_item].display.advanced_matches[*Cheese*]||false>:
                - playsound <context.entity.location> sound:block_honey_block_break volume:0.5
            - else if <context.entity.flag[special_frame_item].display.advanced_matches[*Stool*]||false>:
                - playsound <context.entity.location> sound:block_wood_break volume:0.5
            - else:
                - playsound <context.entity.location> sound:item_book_page_turn volume:0.5
        - else if <context.entity.framed_item> matches *_wool:
            - playsound <context.entity.location> sound:block_wool_break volume:0.5
        - else if <context.entity.framed_item> matches *mushroom:
            - playsound <context.entity.location> sound:block_ancient_debris_place volume:0.5
        - else:
            - playsound <context.entity.location> sound:block_glass_break volume:0.5
        - remove <context.entity>
        on item_frame breaks:
        - if !<context.hanging.visible> && <context.cause> != entity:
            - determine cancelled

openable_book_helper_world:
    type: world
    debug: false
    events:
        on player right clicks item_frame:
        - if !<context.entity.has_flag[special_frame_item]> || <player.is_sneaking>:
            - stop
        - if <context.entity.framed_item> !matches book:
            - stop
        - define model <context.entity.framed_item.custom_model_data||0>
        - if <[model]> in 100001|100006:
            - if !<context.entity.framed_item.has_flag[openable_book]>:
                - stop
            - if <[model]> == 100001:
                - define model 100006
            - else:
                - define model 100001
            - determine passively cancelled
            - wait 1t
            - adjust <context.entity> framed:<context.entity.framed_item.with[custom_model_data=<[model]>]>
        - else if <[model]> == 100013:
            - determine passively cancelled
            - wait 1t
            - run sit_task def:<context.entity.location.above[0.35].with_pitch[0].with_yaw[<player.location.yaw>]>
