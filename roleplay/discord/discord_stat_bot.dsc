discord_stat_push_task:
    type: task
    debug: false
    definitions: antidup
    script:
    - wait 1t
    - if <server.has_flag[discord_stats_nodup]>:
        - if <[antidup]||null> != repeat:
            - run discord_stat_push_task delay:3s def:repeat
        - stop
    - flag server discord_stats_nodup duration:2s
    - define group <discord_group[relaybot,123]>
    - define channel 123
    - define message_id 123
    - define count <[group].members.size>
    - define human_count <[group].members.filter[is_bot.not].size>
    - define staff_count <[group].members.filter[roles[<[group]>].parse[id].contains[123]].size>
    - define development_count <[group].members.filter[roles[<[group]>].parse[id].contains[123]].size>
    - define bot_count <[group].members.filter[is_bot].size>
    - define online <server.online_players.filter[has_flag[vanished].not].size>
    - define ops_online <server.online_players.filter[in_group[staff]].filter[has_flag[vanished].not].size>
    - define total <server.players.size>
    - define ops_total <server.flag[all_staff].size>
    - define updated <util.time_now.format>
    - define embed <discord_embed.with[title].as[Automatic Statistics].with[footer].as[Last updated: <[updated]>].with[color].as[green]>
    - define embed <[embed].add_field[Discord Members].value[**<[count]>** (**<[human_count]>** humans, **<[staff_count]>** staff, **<[development_count]>** development, **<[bot_count]>** bots)]>
    - define embed <[embed].add_field[Players Now On Minecraft Server].value[**<[online]>** (**<[ops_online]>** staff)]>
    - define embed <[embed].add_field[Players Ever (Total)].value[**<[total]>** (**<[ops_total]>** staff)]>
    - define embed <[embed].add_field[In-Game Time].value[<world[danary].time.proc[format_world_time].strip_color>]>
    - ~discordmessage id:relaybot edit:<discord_message[relaybot,<[channel]>,<[message_id]>]> <[embed]>

discord_stats_world:
    type: world
    debug: false
    events:
        after server start:
        - wait 30s
        - run discord_stat_push_task
        after player joins:
        - if <player.in_group[staff]>:
            - flag server all_staff:!|:<server.flag[all_staff].include[<player>].deduplicate>
        - else:
            - flag server all_staff:!|:<server.flag[all_staff].exclude[<player>].deduplicate>
        - run discord_stat_push_task
        after player quits:
        - run discord_stat_push_task
        after discord user joins group:123:
        - run discord_stat_push_task
        after discord user leaves group:123:
        - run discord_stat_push_task
        after discord user role changes group:123:
        - run discord_stat_push_task
        on delta time minutely every:15:
        - run discord_stat_push_task
