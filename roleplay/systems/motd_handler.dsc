motd_handler:
    type: world
    debug: false
    data:
        known_scanners: 1.2.3.4
    events:
        on proxy server list ping:
        - determine passively players:<server.online_players.filter[has_flag[vanished].not]>
        - if <context.address.replace[/].before[:].advanced_matches[<script.data_key[data.known_scanners]>]>:
            - stop
        - define possible <server.flag[ip_accounts.<context.address.replace[/].before[:].escaped>].parse[name]||<list>>
        - announce to_console "List ping from <context.address>, players possible = <[possible].formatted>"
        - determine "motd:<&6>Waymaker Roleplay <&e>| <&6>The Fifth Era<n><&3>Original Fantasy Roleplay <&e>| <&b>Sandbox RPG"
