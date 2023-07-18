bungee_track_backup_world:
    type: world
    debug: false
    events:
        after bungee player joins network priority:-100:
        - flag server bungee_player_backup.<context.uuid>:<context.name>
        - flag server bungee_player_isonline.<context.uuid>
        after bungee player switches to server:
        - flag server bungee_player_server.<context.uuid>:<context.server>
        - wait 5s
        after bungee player leaves network:
        - flag server bungee_player_isonline.<context.uuid>:!
        - wait 5s
        on server prestart:
        - flag server bungee_player_isonline:!
        - wait 1s
        - run bungee_track_preload
        after bungee server connects:
        - waituntil rate:1t max:10s <bungee.list_servers.is_empty.not||false> && <bungee.connected||false>
        - wait 1t
        - if !<bungee.list_servers.contains[<context.server>]>:
            - stop
        - announce to_console "new bungee server connected: <context.server>"
        - ~bungeetag server:<context.server> <server.online_players.parse[uuid]> save:x
        - if <entry[x].result||null> == null:
            - stop
        - foreach <entry[x].result> as:player:
            - flag server bungee_player_isonline.<[player]>
            - flag server bungee_player_server.<[player]>:<context.server>

bungee_track_preload:
    type: task
    debug: false
    script:
    - waituntil rate:1t max:10s <bungee.list_servers.is_empty.not||false> && <bungee.connected||false>
    - announce to_console "bungee_track_preload start"
    - wait 1t
    - foreach <bungee.list_servers||<list>> as:server:
        - ~bungeetag server:<[server]> <server.online_players.parse_tag[<[parse_value].uuid>/<[parse_value].name>]> save:x
        - foreach <entry[x].result||<list>> as:player:
            - flag server bungee_player_isonline.<[player].before[/]>
            - flag server bungee_player_server.<[player].before[/]>:<[server]>
            - flag server bungee_player_backup.<[player].before[/]>:<[player].after[/]>
    - announce to_console "bungee_track_preload end"

match_anywhere_online_player:
    type: procedure
    debug: false
    definitions: match
    script:
    - define best null
    - foreach <server.flag[bungee_player_isonline].keys> as:id:
        - define name <server.flag[bungee_player_backup.<[id]>]>
        - if <[name]> == <[match]>:
            - determine <player[<[id]>]>
        - else if <[name].starts_with[<[match]>]>:
            - define best <player[<[id]>]>
        - else if <[name].contains_text[<[match]>]> && <[best]> == null:
            - define best <player[<[id]>]>
    - determine <[best]>
