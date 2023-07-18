maintenance_safe_world:
    type: world
    debug: false
    events:
        on player logs in:
        #- if <server.has_flag[maintenance]> && !<player.has_permission[dscript.staff_maintenance_join]>:
        - if <server.has_flag[maintenance]> && !<player.is_op>:
            - determine "KICKED:Server maintenance in progress, please wait."
        on proxy server list ping:
        - if <server.has_flag[maintenance]>:
            - determine passively "MOTD:<&[error]>Server maintenance in progress, please wait."
            - determine passively VERSION:Maintenance
            #- determine passively VERSION_NAME:Maintenance
            #- determine passively PROTOCOL_VERSION:999
