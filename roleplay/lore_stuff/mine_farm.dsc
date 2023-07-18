mine_farm_data:
    type: data
    debug: false
    types:
    - wood
    - stone
    fatigue_rate:
        stone: 2
        wood: 1
    blocktype:
        oak_log: wood
        spruce_log: wood
        birch_log: wood
        jungle_log: wood
        acacia_log: wood
        dark_oak_log: wood
        stripped_oak_log: wood
        stripped_spruce_log: wood
        stripped_birch_log: wood
        stripped_jungle_log: wood
        stripped_acacia_log: wood
        stripped_dark_oak_log: wood
        stone: stone
        iron_ore: stone
        coal_ore: stone
    drops:
        wood_extra:
        - 1/mine_item_leaf
        - 0.01/mine_item_animal_poop
        oak_log: mine_item_bundle_of_oak_wood
        spruce_log: mine_item_bundle_of_spruce_wood
        birch_log: mine_item_bundle_of_birch_wood
        jungle_log: mine_item_bundle_of_jungle_wood
        acacia_log: mine_item_bundle_of_acacia_wood
        dark_oak_log: mine_item_bundle_of_dark_oak_wood
        stripped_oak_log: mine_item_bundle_of_oak_wood
        stripped_spruce_log: mine_item_bundle_of_spruce_wood
        stripped_birch_log: mine_item_bundle_of_birch_wood
        stripped_jungle_log: mine_item_bundle_of_jungle_wood
        stripped_acacia_log: mine_item_bundle_of_acacia_wood
        stripped_dark_oak_log: mine_item_bundle_of_dark_oak_wood
        stone:
        - 100/mine_item_stack_of_stones
        - 50/mine_item_stack_of_stones
        - 5/mine_item_chunk_of_coal
        - 10/mine_item_basalt_chunk
        - 10/mine_item_block_of_granite
        - 10/mine_item_block_of_diorite
        - 10/mine_item_block_of_andesite
        - 10/mine_item_pile_of_mossy_stones
        - 10/mine_item_pile_of_gravel
        - 0.01/trade_penny_item
        - 0.001/trade_stater_item
        - 0.001/mine_item_unusual_blue_gemstones
        - 0.001/mine_item_ferrozene_crystals
        - 0.001/mine_item_silverfish_bone
        - 0.001/mine_item_small_pebble
        iron_ore:
        - 100/mine_item_chunk_of_iron_ore
        - 10/mine_item_chunk_of_iron_ore
        - 5/mine_item_chunk_of_gold_ore
        - 1/mine_item_ferrozene_crystals
        - 0.001/mine_item_unusual_blue_gemstones
        #- 0.001/mine_item_handsome_pebble
        coal_ore:
        - 100/mine_item_chunk_of_coal
        - 50/mine_item_chunk_of_coal
        - 25/mine_item_chunk_of_coal
        - 10/mine_item_chunk_of_coal
        - 10/mine_item_basalt_chunk
        - 0.0001/mine_item_coal_diamond
    respawn_rate:
        default: <util.random.decimal[3].to[8]>m
        iron_ore: <util.random.decimal[20].to[45]>m
        coal_ore: <util.random.decimal[20].to[50]>m

mine_farm_world:
    type: world
    debug: false
    events:
        on system time 04:00:
        - foreach <server.players> as:player:
            - flag <[player]> mined_recently:!
            - wait 1t
        on player clicks block in:danary:
        - if !<player.item_in_hand.has_flag[lore_breaker_item]>:
            - stop
        - ratelimit <player> 30s
        - foreach <context.location.find_blocks_flagged[must_respawn_by].within[32].filter[flag[must_respawn_by].is_before[<util.time_now>]]||<list>> as:needed:
            - modifyblock <[needed]> <[needed].flag[must_respawn_as_type]>
            - flag <[needed]> must_respawn_by:!
            - flag <[needed]> must_respawn_as_type:!
        on player breaks block in:danary:
        - if !<context.location.has_flag[mine_block]>:
            - stop
        - if !<player.item_in_hand.has_flag[lore_breaker_item]>:
            - actionbar "<&[error]>You cannot mine blocks without the appropriate tool."
            - determine cancelled
        - if <player.flag[mined_recently]||0> > 640:
            - narrate "<&[error]>You're fatigued from too much mining. You need to rest <&[emphasis]><util.time_now.sub[4h].start_of_day.add[28h].from_now.formatted> <&[error]>before you can mine more."
            - determine cancelled
        - define material <context.material>
        - define type <script[mine_farm_data].data_key[blocktype.<[material].name>]||null>
        - if <[type]> == null:
            - actionbar "<&[error]>Error with minable block, contact staff."
            - debug error "<context.location> is minable but unrecognized type <[material].name>"
        - flag player mined_recently:+:<script[mine_farm_data].data_key[fatigue_rate.<[type]>]> duration:24h
        - if <[material].name> == air:
            - determine cancelled
            - determine cancelled
        - if <player.item_in_hand.flag[lore_breaker_item]> != <[type]>:
            - actionbar "<&[error]>You cannot mine <[type]> with your current tool type (<player.item_in_hand.flag[lore_breaker_item]>)."
            - determine cancelled
        - if <player.gamemode> == creative:
            - define message "] <&lt>**`<player.name>`** **IS CREATIVE FARMING** block of type `<[material].name>` at `<context.location.simple>`"
            - run discord_send_message def:<list[<server.flag[discord_logs_channel]>].include_single[<[message]>]>
        - define block <context.location>
        - define respawn_rate <script[mine_farm_data].parsed_key[respawn_rate.<[material].name>]||<script[mine_farm_data].parsed_key[respawn_rate.default]>>
        - flag <[block]> must_respawn_as_type:<[material]>
        - flag <[block]> must_respawn_by:<util.time_now.add[<[respawn_rate]>].add[10m]>
        - determine passively nothing
        - define drops_extra <script[mine_farm_data].data_key[drops.<[type]>_extra]||<list>>
        - define drops <script[mine_farm_data].data_key[drops.<[material].name>]||null>
        - announce to_console "<&7>ITEM LOG PLAYER <player.name> at <context.location.simple||?> mines minefarm block of type <[material].name>"
        - if <[drops]> != null:
            - foreach <[drops_extra].include[<[drops]>]> as:item:
                - if <[item].contains[/]>:
                    - if <util.random.decimal[0].to[100]> < <[item].before[/]>:
                        - if <[item].before[/]> < 0.1:
                            - define message "] <&lt>**`<player.name>`** **GOT RARE ITEM DROP** `<[item].display.strip_color||<[item].material.name>>` from block of type `<[material].name>` at `<context.location.simple>`"
                            - run discord_send_message def:<list[<server.flag[discord_logs_channel]>].include_single[<[message]>]>
                        - drop <[item].after[/]> <context.location.center> speed:0.5
                - else:
                    - drop <[item]> <context.location.center> speed:0.5
        - wait 1t
        - inventory update
        - wait <[respawn_rate]>
        - chunkload <[block]> d:1s
        - if <[block].material.name> == air:
            - modifyblock <[block]> <[material]>
            - flag <[block]> must_respawn_by:!
            - flag <[block]> must_respawn_as_type:!
        on player left clicks block with:minefarm_tool priority:-10:
        - determine passively cancelled
        - if <context.location||null> == null:
            - stop
        - wait 1t
        - if <context.location.has_flag[mine_block]>:
            - narrate "<&[error]>That block is already a mine-farm."
            - stop
        - define type <script[mine_farm_data].data_key[blocktype.<context.location.material.name>]||null>
        - if <[type]> == null:
            - narrate "<&[error]>That block type cannot be mine-farmed."
            - stop
        - flag <context.location> mine_block
        - narrate "<&[base]>Enabled minefarming for the <&[emphasis]><context.location.material.translated_name><&[base]> at <&[emphasis]><context.location.simple><&[base]>."
        on player right clicks block with:minefarm_tool priority:-10:
        - determine passively cancelled
        - if <context.location||null> == null:
            - stop
        - wait 1t
        - if !<context.location.has_flag[mine_block]>:
            - narrate "<&[error]>That block is already not a mine farm."
            - stop
        - flag <context.location> mine_block:!
        - flag <context.location> must_respawn_by:!
        - flag <context.location> must_respawn_as_type:!
        - narrate "<&[base]>Disabled minefarming for the <&[emphasis]><context.location.material.translated_name><&[base]> at <&[emphasis]><context.location.simple><&[base]>."
        # Prevent misuse
        on player drops minefarm_tool:
        - remove <context.entity>
        on player clicks in inventory with:minefarm_tool:
        - inject <script> path:abuse_prevention_click
        on player drags minefarm_tool in inventory:
        - inject <script> path:abuse_prevention_click
    abuse_prevention_click:
        - if <context.inventory.inventory_type> == player:
            - stop
        - if <context.inventory.inventory_type> == crafting:
            - if <context.raw_slot||<context.raw_slots.numerical.first>> >= 6:
                - stop
        - determine passively cancelled
        - inventory update

minefarm_command:
    type: command
    name: minefarm
    debug: false
    usage: /minefarm
    description: Gives you a minefarm tool.
    permission: dscript.minefarm
    script:
    - run give_safe_item def.item:minefarm_tool
    - narrate "<&[base]>Gave a <&[emphasis]><element[MineFarm Tool].on_hover[<script[minefarm_tool].parsed_key[lore].separated_by[<n>]>]><&[base]>."

loreminetooltype_command:
    type: command
    name: loreminetooltype
    debug: false
    usage: /loreminetooltype [type]
    description: Makes your held item be the relevant lore-compliant minefarm tool type.
    permission: dscript.loreminetooltype
    tab completions:
        1: <script[mine_farm_data].data_key[types]>
    script:
    - if !<script[mine_farm_data].data_key[types].contains[<context.args.first||null>]>:
        - narrate "<&[error]>/loreminetoolitem [type]"
        - narrate "<&[warning]>types: <script[mine_farm_data].data_key[types].formatted>"
        - if <player.item_in_hand.has_flag[lore_breaker_item]>:
            - narrate "<&[base]>Your held item is a lore miner of type: <&[emphasis]><player.item_in_hand.flag[lore_breaker_item]>"
        - stop
    - if !<player.item_in_hand.has_display>:
        - narrate "<&[error]>Only lore-compliant tools can be made into lore miners (set a display name at least)."
        - stop
    - inventory flag slot:<player.held_item_slot> lore_breaker_item:<context.args.first>
    - narrate "<&[base]>Set held item's mining type to <&[emphasis]><context.args.first><&[base]>."

minefarm_tool:
    type: item
    material: golden_hoe
    display name: <&[emphasis]>Minefarm Tool
    lore:
    - <&[emphasis]>Left click<&[base]> a block to make it a mine-farm block.
    - <&[emphasis]>Right click<&[base]> a block to disable mine-farming.
    enchantments:
    - luck_of_the_sea:1
    mechanisms:
        hides: all
