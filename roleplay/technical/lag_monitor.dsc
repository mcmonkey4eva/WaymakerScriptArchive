lag_monitor_world:
    type: world
    debug: false
    events:
        on player joins:
        - flag player last_packets_sent:0
        - flag player last_packets_received:0
        on system time secondly every:30:
        - foreach <server.online_players> as:player:
            - flag <[player]> packets_sent_per_second:<[player].packets_sent.sub[<[player].flag[last_packets_sent]>].div[30].round_to[2]>
            - flag <[player]> packets_received_per_second:<[player].packets_received.sub[<[player].flag[last_packets_received]>].div[30].round_to[2]>
            - flag <[player]> last_packets_sent:<[player].packets_sent>
            - flag <[player]> last_packets_received:<[player].packets_received>
        - wait 1t
        - define lagging <server.online_players.filter[ping.is[more].than[450]]>
        - define safe <server.online_players.exclude[<[lagging]>]>
        - if <[lagging].size> >= 5:
            - define lagginginfo "`<[lagging].size>` lagging players (`<[lagging].parse[name].formatted>`) and `<[safe].size>` players not lagging"
            - define locationinfo "Lagging locations `<[lagging].parse[location.simple].formatted>`<n>non-lagging locations `<[safe].parse[location.simple].formatted>`"
            - define tpsinfo "TPS: `<server.recent_tps.parse[round_to[2]].separated_by[, ]>`"
            - define pinginfo "pings: `<[lagging].parse[ping].formatted>`"
            - define clientbrandinfo "lag client brands: `<[lagging].parse[client_brand].formatted>` non-lag client brand `<[safe].parse[client_brand].formatted>`"
            - define laggingrateinfo "packetrate: Lagging sent-ppm `<[lagging].parse[flag[packets_sent_per_second]].formatted>`, receive-ppm `<[lagging].parse[flag[packets_received_per_second]].formatted>`"
            - define saferateinfo "packetrate: Non-lag sent-ppm `<[safe].parse[flag[packets_sent_per_second]].formatted>`, receive-ppm `<[safe].parse[flag[packets_received_per_second]].formatted>`"
            - define meminfo "Memory used: `<util.ram_usage.div[1024].div[1024].round> MiB`, free: `<util.ram_free.div[1024].div[1024].round> MiB`"
            - define sitinfo "Lagging sitting: <[lagging].filter[is_inside_vehicle].size> non-lagging sitting: <[safe].filter[is_inside_vehicle].size>"
            - define message "Possible **LAG BURST DETECTED** (<[tpsinfo]>), (<[meminfo]>), <[lagginginfo]><n><[clientbrandinfo]><n><[pinginfo]><n><[locationinfo]><n><[laggingrateinfo]><n><[saferateinfo]>"
            - announce to_console <[message]>
            - ratelimit nothing 1m
            - run discord_send_message def:<list[discord_logs_channel].include_single[<[message]>]>
