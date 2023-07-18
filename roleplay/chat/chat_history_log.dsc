
chat_history_logger:
    type: world
    debug: false
    events:
        after bungee player joins network:
        - define __player <player[<context.uuid>]>
        - wait 2t
        - if !<server.has_flag[bungee_player_isonline.<player.uuid>]>:
            - stop
        - run chat_history_load
        after bungee player leaves network:
        - define __player <player[<context.uuid>]>
        # This "has_changes" is a hack to make the "exists" work
        - if !<yaml[chat_log_<player.uuid>].has_changes.exists>:
            - stop
        - ~yaml savefile:chat_logs/<util.time_now.year>/<player.uuid>.yml id:chat_log_<player.uuid>
        - wait 10s
        - if <server.has_flag[bungee_player_isonline.<player.uuid>]>:
            - stop
        - yaml unload id:chat_log_<player.uuid>
        on delta time hourly:
        - wait 5m
        - foreach <server.online_players> as:player:
            - ~yaml savefile:chat_logs/<util.time_now.year>/<[player].uuid>.yml id:chat_log_<[player].uuid>
            - wait 10t
        on system time 07:00:
        - if !<server.flag[years_ever_seen].contains[<util.time_now.year>]||false>:
            - flag server years_ever_seen:->:<util.time_now.year>

chat_history_load:
    type: task
    debug: false
    script:
    - if <yaml.list.contains[chat_log_<player.uuid>]>:
        - stop
    - if <util.has_file[chat_logs/<util.time_now.year>/<player.uuid>.yml]>:
        - ~yaml load:chat_logs/<util.time_now.year>/<player.uuid>.yml id:chat_log_<player.uuid>
    - else:
        - yaml create id:chat_log_<player.uuid>

chat_history_log:
    type: task
    debug: false
    definitions: player|log_message
    script:
    - run chat_history_load
    - yaml set history.<util.time_now.format[yyyy.MM.dd]>:->:<[log_message]> id:chat_log_<[player].uuid>

search_history_command:
    type: command
    debug: false
    name: search_history
    usage: /search_history [name] [words]
    description: Searches through history.
    permission: dscript.search_history
    script:
    - if <context.args.size> < 2:
        - narrate "<&[error]>/search_history [name] [words]"
        - stop
    - ratelimit <player> 1s
    - define target <server.match_offline_player[<context.args.first>]||null>
    - if <[target]> == null:
        - narrate "<&[error]>Unknown player '<&[emphasis]><context.args.first><&[error]>'."
        - stop
    - ratelimit <[target]> 1s
    - if <[target].is_online>:
        - ~yaml savefile:chat_logs/<util.time_now.year>/<[target].uuid>.yml id:chat_log_<[target].uuid>
    - define words <context.args.get[2].to[999]>
    - define found <list>
    - foreach <server.flag[years_ever_seen].numerical.reverse> as:year:
        - if !<util.has_file[chat_logs/<[year]>/<[target].uuid>.yml]>:
            - foreach next
        - define id chat_search_log_<[target].uuid>
        - ~yaml load:chat_logs/<util.time_now.year>/<[target].uuid>.yml id:<[id]>
        - define months <yaml[<[id]>].list_keys[history.<[year]>]||<list>>
        - narrate "<&[base]>Searching through year <[year]> history (<[months].size> months active)..."
        - foreach <[months].numerical.reverse> as:month:
            - define days <yaml[<[id]>].list_keys[history.<[year]>.<[month]>]||<list>>
            - foreach <[days].numerical.reverse> as:day:
                - define matches <yaml[<[id]>].read[history.<[year]>.<[month]>.<[day]>].filter[contains_any[<[words]>]]||<list>>
                - if <[matches].size> > 0:
                    - define found:|:<[matches]>
                    - if <[found].size> > 30:
                        - narrate "<&[base]>Search ending early due to number of matches found."
                        - yaml unload id:<[id]>
                        - goto end_loop
        - yaml unload id:<[id]>
    - mark end_loop
    - if <[found].is_empty>:
        - narrate "<&[error]>No matches found."
        - stop
    - narrate "<&[base]>=== Search found <&[emphasis]><[found].size><&[base]> matches... ==="
    - foreach <[found].get[1].to[30].reverse> as:match:
        - narrate "<&f>- <[match]>"
