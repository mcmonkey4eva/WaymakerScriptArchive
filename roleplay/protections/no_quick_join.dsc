no_quick_join_world:
    type: world
    debug: false
    events:
        on server prestart:
        - flag server startup_inprog duration:15s
        on player logs in server_flagged:startup_inprog:
        - determine "KICKED:Slow down, server still loading!"
        on proxy server list ping server_flagged:startup_inprog:
        - determine passively "motd:<&[error]>Server is loading..."
        - determine passively VERSION:Loading
        #- determine passively PROTOCOL_VERSION:999
