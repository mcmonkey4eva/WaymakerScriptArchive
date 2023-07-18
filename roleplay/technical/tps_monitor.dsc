tps_monitor_world:
    type: world
    debug: false
    events:
        on delta time secondly:
        - if <server.recent_tps.first> < 18:
            - announce to_console "<&c>TPS: <server.recent_tps.parse[round_to[2]].formatted>"
