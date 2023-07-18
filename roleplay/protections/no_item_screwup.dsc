lore_item_block_table:
    type: data
    debug: false
    types:
        dark_oak_log: mine_item_bundle_of_dark_oak_wood
        mossy_cobblestone: mine_item_pile_of_mossy_stones
        gravel: mine_item_pile_of_gravel
        basalt: mine_item_basalt_chunk
        cobblestone: mine_item_stack_of_stones
        oak_log: mine_item_bundle_of_oak_wood
        granite: mine_item_block_of_granite
        acacia_log: mine_item_bundle_of_acacia_wood
        jungle_log: mine_item_bundle_of_jungle_wood
        andesite: mine_item_block_of_andesite
        spruce_log: mine_item_bundle_of_spruce_wood
        diorite: mine_item_block_of_diorite
        birch_log: mine_item_bundle_of_birch_wood
    allowed_place:
        mine_item_pile_of_mossy_stones: true
        mine_item_block_of_andesite: true
        mine_item_block_of_diorite: true
        mine_item_stack_of_stones: true
        mine_item_block_of_granite: true
        mine_item_basalt_chunk: true
        mine_item_pile_of_gravel: true
        mine_item_bundle_of_oak_wood: true
        mine_item_bundle_of_spruce_wood: true
        mine_item_bundle_of_dark_oak_wood: true
        mine_item_bundle_of_jungle_wood: true
        mine_item_bundle_of_birch_wood: true
        mine_item_bundle_of_acacia_wood: true
        custom_juke_box_item: true
        mailbox_item: true
        half_bed_top_item: true
        half_bed_bottom_item: true

    #- yaml create id:blocktable
    #- foreach mine_item_pile_of_mossy_stones|mine_item_block_of_andesite|mine_item_block_of_diorite|mine_item_stack_of_stones|mine_item_block_of_granite|mine_item_basalt_chunk|mine_item_pile_of_gravel|mine_item_bundle_of_oak_wood|mine_item_bundle_of_spruce_wood|mine_item_bundle_of_dark_oak_wood|mine_item_bundle_of_jungle_wood|mine_item_bundle_of_birch_wood|mine_item_bundle_of_acacia_wood:
    #    - yaml set id:blocktable <item[<[value]>].material.name>:<[value]>
    #- yaml savefile:kitthing/blocktable.yml id:blocktable

no_item_screwup_world:
    type: world
    debug: false
    events:
        on player right clicks block priority:-3:
        - if <player.item_in_hand.has_display> && <player.item_in_hand.has_lore>:
            - if <player.item_in_hand.material.advanced_matches[*_spawn_egg]>:
                - actionbar "<&[error]>Can't place a lore item."
                - determine cancelled
        on player places block priority:-3:
        - if <context.item_in_hand.has_display> && <context.item_in_hand.has_lore> && <context.item_in_hand.flag[rarity]||null> != decoration:
            - if !<script[lore_item_block_table].data_key[allowed_place.<context.item_in_hand.script.name||null>]||false>:
                - actionbar "<&[error]>Can't place a lore item."
                - determine cancelled
        on player places item_flagged:custom_model_item priority:-2:
        - actionbar "<&[error]>Can't place a custom block directly, use an item frame."
        - determine cancelled
        on block drops item from breaking:
        - foreach <context.drop_entities> as:ent:
            - define type <script[lore_item_block_table].data_key[types.<[ent].item.material.name||air>]||air>
            - if <[type]> != air:
                - adjust <[ent]> item:<[type]>
        on player places item_flagged:rarity priority:15:
        - if <context.item_in_hand.flag[rarity]> == decoration:
            - flag <context.location> original_item:<context.item_in_hand.with_single[quantity=1]>
        after player breaks block priority:100 location_flagged:original_item:
        - flag <context.location> original_item:!
        on block drops item from breaking location_flagged:original_item:
        - foreach <context.drop_entities> as:ent:
            - define type <[ent].item.material.name||air>
            - if <[type]> == <context.location.flag[original_item].material.name>:
                - adjust <[ent]> item:<context.location.flag[original_item]>
        - flag <context.location> original_item:!
