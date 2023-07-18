

bungee_chat_show:
    type: task
    debug: false
    definitions: channel|player|message
    script:
    - announce to_console "[Bungee Chat Show] <[player].name> (<server.flag[bungee_player_backup.<[player].uuid>]>) says in <[channel]>: <[message]>"
    - define recipients <server.online_players.filter[has_flag[hide_channel.<[channel]>].not]>
    - choose <[channel]>:
            - case global:
                - define format chat_format_global
            - case advert:
                - define format chat_format_advert
            - case broadcast:
                - define format chat_format_broadcast
            - case staff:
                - define recipients <[recipients].filter[has_permission[dscript.staffchat]]>
                - define format chat_format_staff
            - default:
                - debug error "Invalid channel <[channel]> for bungee_chat_show"
                - stop
    - narrate <proc[<[format]>].context[<list_single[<[player]>].include_single[<[message]>]>]> t:<[recipients]> from:<[player].uuid> per_player

bungee_discord_chat_show:
    type: task
    debug: false
    definitions: channel|name|player|message
    script:
    - if <[channel]> == global:
        - define prefix <&2>[<element[y].font[waymaker:waymaker].on_hover[Discord Global]><element[G].on_hover[Discord Global]>]
        - define targets <server.online_players.filter[has_flag[hide_channel.global].not]>
    - else if <[channel]> == advert:
        - define prefix <&a>[<element[y].font[waymaker:waymaker].on_hover[Discord Advert Channel]><element[Advert].on_hover[Discord Advert Channel]>]
        - define targets <server.online_players.filter[has_flag[hide_channel.advert].not]>
    - else if <[channel]> == staff:
        - define prefix <&6>[<element[y].font[waymaker:waymaker].on_hover[Discord Staff]><element[S].on_hover[Discord Staff]>]
        - define targets <server.online_players.filter[has_permission[dscript.staffchat]].filter[has_flag[hide_channel.staff].not]>
    - else:
        - announce to_console "Failed to broadcast chat in unknown channel <[channel]>"
        - stop
    - if <[player]> != null:
        - narrate "<[prefix]> <&r><&color[#dddddd]><[player].proc[proc_global_name]><&r><&co> <[message]>" targets:<[targets]> per_player
    - else:
        - narrate "<[prefix]> <&r><&color[#dddddd]><[name]><&r><&co> <[message]>" targets:<[targets]>
