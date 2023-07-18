
custom_juke_box_data:
    type: data
    songs:
        MUSIC_DISC_11: MUSIC_DISC_11
        MUSIC_DISC_13: MUSIC_DISC_13
        MUSIC_DISC_BLOCKS: MUSIC_DISC_BLOCKS
        MUSIC_DISC_CAT: MUSIC_DISC_CAT
        MUSIC_DISC_CHIRP: MUSIC_DISC_CHIRP
        MUSIC_DISC_FAR: MUSIC_DISC_FAR
        MUSIC_DISC_MALL: MUSIC_DISC_MALL
        MUSIC_DISC_MELLOHI: MUSIC_DISC_MELLOHI
        MUSIC_DISC_PIGSTEP: MUSIC_DISC_PIGSTEP
        MUSIC_DISC_STAL: MUSIC_DISC_STAL
        MUSIC_DISC_STRAD: MUSIC_DISC_STRAD
        MUSIC_DISC_WAIT: MUSIC_DISC_WAIT
        MUSIC_DISC_WARD: MUSIC_DISC_WARD
        MUSIC_DRAGON: paper
        MUSIC_END: paper
        MUSIC_GAME: paper
        MUSIC_MENU: paper
        MUSIC_NETHER_BASALT_DELTAS: paper
        MUSIC_NETHER_CRIMSON_FOREST: paper
        MUSIC_NETHER_NETHER_WASTES: paper
        MUSIC_NETHER_SOUL_SAND_VALLEY: paper
        MUSIC_NETHER_WARPED_FOREST: paper
        MUSIC_UNDER_WATER: paper
        MUSIC_CREATIVE: paper
        MUSIC_CREDITS: paper

custom_juke_box_item:
    type: item
    debug: false
    material: jukebox
    display name: <&color[#FF0060]>Custom Jukebox
    lore:
    - <&f>A jukebox with customization options.
    enchantments:
    - luck:1
    mechanisms:
        hides: all

custom_juke_box_interface:
    type: inventory
    debug: false
    inventory: chest
    size: 54
    title: <&color[#FF0060]>Custom Jukebox

custom_juke_box_stop_item:
    type: item
    debug: false
    material: barrier
    display name: <&c>Stop Playing

custom_juke_box_range_item:
    type: item
    debug: false
    material: bow
    display name: <&f>Range<&co> 4 Chunks
    mechanisms:
        hides: all

custom_juke_box_add_range_item:
    type: item
    debug: false
    material: player_head
    display name: <&2>Increase Juke Box Range
    mechanisms:
        skull_skin: 86324d7a-d1ae-4682-bf77-c1c272fc3523|eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvNjBiNTVmNzQ2ODFjNjgyODNhMWMxY2U1MWYxYzgzYjUyZTI5NzFjOTFlZTM0ZWZjYjU5OGRmMzk5MGE3ZTcifX19

custom_juke_box_reduce_range_item:
    type: item
    debug: false
    material: player_head
    display name: <&c>Reduce Juke Box Range
    mechanisms:
        skull_skin: c24a86b3-162f-4ec9-827f-0f79bddec3d0|eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvYzNlNGI1MzNlNGJhMmRmZjdjMGZhOTBmNjdlOGJlZjM2NDI4YjZjYjA2YzQ1MjYyNjMxYjBiMjVkYjg1YiJ9fX0=

custom_juke_box_speed_item:
    type: item
    debug: false
    material: diamond_shovel
    display name: <&f>Playback Speed<&co> 1x
    mechanisms:
        hides: all

custom_juke_box_add_speed_item:
    type: item
    debug: false
    material: player_head
    display name: <&2>Increase Juke Box Playback Speed
    mechanisms:
        skull_skin: 86324d7a-d1ae-4682-bf77-c1c272fc3523|eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvNjBiNTVmNzQ2ODFjNjgyODNhMWMxY2U1MWYxYzgzYjUyZTI5NzFjOTFlZTM0ZWZjYjU5OGRmMzk5MGE3ZTcifX19

custom_juke_box_reduce_speed_item:
    type: item
    debug: false
    material: player_head
    display name: <&c>Reduce Juke Box Playback Speed
    mechanisms:
        skull_skin: c24a86b3-162f-4ec9-827f-0f79bddec3d0|eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvYzNlNGI1MzNlNGJhMmRmZjdjMGZhOTBmNjdlOGJlZjM2NDI4YjZjYjA2YzQ1MjYyNjMxYjBiMjVkYjg1YiJ9fX0=

open_custom_juke_box_task:
    type: task
    debug: false
    definitions: location
    script:
    - if !<[location].has_flag[custom_juke_box]||false> || <[location].material.name||air> != jukebox:
        - debug error "Cannot open custom_juke_box at <[location]||?>: not a custom juke box"
        - stop
    - define inv_note custom_juke_box_interface_<[location].simple>
    - if <inventory[<[inv_note]>]||null> == null:
        - note <inventory[custom_juke_box_interface]> as:<[inv_note]>
        - foreach <script[custom_juke_box_data].data_key[songs]> key:song as:item:
            - give <item[<[item]>].with[display=<&7>Play song <[song]>].with[hides=enchants].with_flag[song:<[song]>]> to:<[inv_note]>
        - inventory set origin:custom_juke_box_stop_item destination:<[inv_note]> slot:54
        - inventory set origin:custom_juke_box_reduce_range_item destination:<[inv_note]> slot:46
        - inventory set origin:custom_juke_box_add_range_item destination:<[inv_note]> slot:48
        - inventory set origin:custom_juke_box_reduce_speed_item destination:<[inv_note]> slot:50
        - inventory set origin:custom_juke_box_add_speed_item destination:<[inv_note]> slot:52
        - flag <inventory[<[inv_note]>]> juke_box_location:<[location]>
        - run custom_juke_box_set_specialitems def:<[location]>
    - inventory open destination:<[inv_note]>

custom_juke_box_set_specialitems:
    type: task
    debug: false
    definitions: location
    script:
    - if !<[location].has_flag[custom_juke_box]||false> || <[location].material.name||air> != jukebox:
        - debug error "Cannot update custom_juke_box at <[location]||?>: not a custom juke box"
        - stop
    - define inv_note custom_juke_box_interface_<[location].simple>
    - if <inventory[<[inv_note]>]||null> == null:
        - debug error "Cannot update custom_juke_box at <[location]||?>: not noted properly"
        - stop
    - define speed <[location].flag[custom_juke_box.speed]>
    - define range <[location].flag[custom_juke_box.range]>
    - define speed_item "custom_juke_box_speed_item[display=<&f>Playback Speed<&co> <&2><[speed]>x;durability=<material[diamond_shovel].max_durability.mul[<element[1].sub[<[speed].div[2]>]>].round>]"
    - define range_item "custom_juke_box_range_item[quantity=<[range]>;display=<&f>Range<&co> <&2><[range]> Chunks;durability=<material[bow].max_durability.mul[<element[1].sub[<[range].div[16]>]>].round>]"
    - inventory set origin:<[speed_item]> destination:<[inv_note]> slot:51
    - inventory set origin:<[range_item]> destination:<[inv_note]> slot:47
    - if <[location].has_flag[custom_juke_box.last_played_song_slot]>:
        - inventory adjust destination:<[inv_note]> slot:<[location].flag[custom_juke_box.last_played_song_slot]> enchantments:<map.with[luck].as[1]>

custom_juke_stop_playing:
    type: task
    debug: false
    definitions: jukebox
    script:
    - if <[jukebox].has_flag[last_played_to]>:
        - adjust <[jukebox].flag[last_played_to].filter[is_online]> stop_sound:records
        - flag <[jukebox]> last_played_to:!

custom_juke_box_world:
    type: world
    debug: false
    events:
        on block drops jukebox from breaking location_flagged:custom_juke_box priority:10:
        - determine passively cancelled
        - wait 1t
        - drop custom_juke_box_item <context.location>
        after player breaks jukebox location_flagged:custom_juke_box priority:10:
        - flag <context.location> custom_juke_box:!
        - define inv_note custom_juke_box_interface_<context.location.simple>
        - note remove as:<[inv_note]>
        on player right clicks jukebox location_flagged:custom_juke_box priority:10:
        - determine passively cancelled
        - wait 1t
        - run open_custom_juke_box_task def:<context.location>
        after player places custom_juke_box_item priority:10:
        - if <context.location.material.name||air> == jukebox:
            - flag <context.location> custom_juke_box.speed:1
            - flag <context.location> custom_juke_box.range:4
        on player clicks item in custom_juke_box_interface priority:100:
        - determine cancelled
        on player drags item in custom_juke_box_interface priority:100:
        - determine cancelled
        on player clicks custom_juke_box_reduce_range_item in custom_juke_box_interface:
        - wait 1t
        - define jukebox <context.inventory.flag[juke_box_location]>
        - if <[jukebox].flag[custom_juke_box.range]> <= 1:
            - stop
        - flag <[jukebox]> custom_juke_box.range:<[jukebox].flag[custom_juke_box.range].sub[1]>
        - run custom_juke_box_set_specialitems def:<[jukebox]>
        on player clicks custom_juke_box_add_range_item in custom_juke_box_interface:
        - wait 1t
        - define jukebox <context.inventory.flag[juke_box_location]>
        - if <[jukebox].flag[custom_juke_box.range]> >= 16:
            - stop
        - flag <[jukebox]> custom_juke_box.range:<[jukebox].flag[custom_juke_box.range].add[1]>
        - run custom_juke_box_set_specialitems def:<[jukebox]>
        on player clicks custom_juke_box_reduce_speed_item in custom_juke_box_interface:
        - wait 1t
        - define jukebox <context.inventory.flag[juke_box_location]>
        - if <[jukebox].flag[custom_juke_box.speed]> <= 0.1:
            - stop
        - flag <[jukebox]> custom_juke_box.speed:<[jukebox].flag[custom_juke_box.speed].sub[0.1].round_to[1]>
        - run custom_juke_box_set_specialitems def:<[jukebox]>
        on player clicks custom_juke_box_add_speed_item in custom_juke_box_interface:
        - wait 1t
        - define jukebox <context.inventory.flag[juke_box_location]>
        - if <[jukebox].flag[custom_juke_box.speed]> >= 2:
            - stop
        - flag <[jukebox]> custom_juke_box.speed:<[jukebox].flag[custom_juke_box.speed].add[0.1].round_to[1]>
        - run custom_juke_box_set_specialitems def:<[jukebox]>
        on player clicks custom_juke_box_stop_item in custom_juke_box_interface:
        - wait 1t
        - define jukebox <context.inventory.flag[juke_box_location]>
        - if <[jukebox].has_flag[custom_juke_box.last_played_song_slot]>:
            - inventory adjust destination:<context.inventory> slot:<[jukebox].flag[custom_juke_box.last_played_song_slot]> remove_enchantments
        - run custom_juke_stop_playing def:<context.inventory>
        - run custom_juke_box_set_specialitems def:<[jukebox]>
        on player clicks item_flagged:song in custom_juke_box_interface:
        - run custom_juke_stop_playing def:<context.inventory>
        - wait 1t
        - define jukebox <context.inventory.flag[juke_box_location]>
        - define players <[jukebox].find_players_within[<[jukebox].flag[custom_juke_box.range].mul[16]>]>
        - if <[players].is_empty>:
            - stop
        - flag <context.inventory> last_played_to:<[players]> duration:30m
        - playsound <[jukebox]> volume:<[jukebox].flag[custom_juke_box.range]> pitch:<[jukebox].flag[custom_juke_box.speed]> sound:<context.item.flag[song]> <[players]> sound_category:records
        - if <[jukebox].has_flag[custom_juke_box.last_played_song_slot]>:
            - inventory adjust destination:<context.inventory> slot:<[jukebox].flag[custom_juke_box.last_played_song_slot]> remove_enchantments
        - flag <[jukebox]> custom_juke_box.last_played_song_slot:<context.slot>
        - run custom_juke_box_set_specialitems def:<[jukebox]>
