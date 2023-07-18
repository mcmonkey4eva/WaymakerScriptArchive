
bungee_apply_flagmap:
    type: task
    debug: false
    definitions: player|map
    script:
    - define __player <[player]>
    - if <server.has_flag[is_roleplay_server]>:
        - define flags <script[bungee_flagmap_transfer].data_key[data.to_rp]>
    - else:
        - define flags <script[bungee_flagmap_transfer].data_key[data.from_rp].include[<script[bungee_flagmap_transfer].data_key[data.to_rp]>]>
    - foreach <[flags]> as:flagname:
        - flag <[player]> <[flagname]>:!
    - foreach <[map]> key:flagname as:value:
        - flag <[player]> <[flagname]>:<[value]>
    - if !<server.has_flag[is_roleplay_server]> && <player.has_flag[perm_groups]>:
        - group set <player.flag[perm_groups.staff]||default>
        - foreach <player.flag[perm_groups.other]||<list>>:
            - group add <[value]>
        - announce to_console "Final join-roles from bungee-apply-flagmap for <player.name> are <player.groups.separated_by[, ]>"

bungee_flagmap_transfer:
    type: world
    debug: false
    data:
        to_rp:
        - invisibility
        - vanished
        - channel
        - hide_channel
        - chat_color
        - personal_name_color
        - personal_name_color_tried
        - nickname
        - walk_speed
        - fly_speed
        - hidenameplates
        - nightvision
        - custom_leave_message
        - can_use_customjoinleave
        - custom_join_message
        - altnamecolor
        - can_use_playernamecolor
        - can_use_altnamecolor
        - all_joins
        from_rp:
        - friends
        - perm_groups
    events:
        on player quits:
        - stop if:<server.has_flag[is_roleplay_server]>
        - stop if:<server.has_flag[no_back_sync]>
        - announce to_console "<player.name> is quitting, sending RP flag sync"
        - define map <map>
        - foreach <script.data_key[data.to_rp]> as:flagname:
            - if <player.has_flag[<[flagname]>]>:
                - define map.<[flagname]>:<player.flag[<[flagname]>]>
        - bungeerun roleplay bungee_apply_flagmap def:<list_single[<player>].include_single[<[map]>]>
        on bungee player switches to server:
        - define __player <player[<context.uuid>]||null>
        - if !<player.is_online||false>:
            - stop
        - define server <context.server>
        - run bungee_send_data_out def.server:<[server]>

bungee_send_data_out:
    type: task
    debug: false
    definitions: server
    script:
    - announce to_console "<player.name> (<player.is_online>) is switching to <[server]>, sending flag sync"
    - define map <map>
    - if <server.has_flag[is_roleplay_server]>:
        - define flags <script[bungee_flagmap_transfer].data_key[data.from_rp].include[<script[bungee_flagmap_transfer].data_key[data.to_rp]>]>
    - else:
        - define flags <script[bungee_flagmap_transfer].data_key[data.to_rp]>
    - foreach <[flags]> as:flagname:
        - if <player.has_flag[<[flagname]>]>:
            - define map.<[flagname]>:<player.flag[<[flagname]>]>
    - wait 1t
    - bungeerun <[server]> bungee_apply_flagmap def:<list_single[<player>].include_single[<[map]>]>
