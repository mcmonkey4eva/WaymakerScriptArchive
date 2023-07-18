auto_restarter_world:
    type: world
    debug: false
    events:
        on system time 03:00:
        - wait <server.flag[auto_restart_delay]||5s>
        - run auto_restarter_task
        on player logs in server_flagged:restart_happening:
        - determine "KICKED:Server is restarting momentarily, please wait."

auto_restarter_task:
    type: task
    debug: false
    script:
    - wait 1m
    - flag server restarting_soon expire:1h
    - define marks <list[30m|20m|15m|10m|5m|4m|3m|2m|1m|30s|15s|10s|5s].parse[as[duration]]>
    - foreach <[marks]> as:mark:
        - if <server.online_players.is_empty>:
            - foreach stop
        - define display_in <[mark].formatted.replace_text[s].with[ seconds].replace_text[m].with[ minutes].replace_text[1 minutes].with[1 minute]>
        - announce "<&[error]>Server will automatically restart in <[display_in]>."
        - announce to_console "<&c>Auto-restart planned for <[display_in]>"
        - if <[mark].in_seconds> <= 60:
            - title "subtitle:<&[error]>Restart in <[display_in]>." fade_out:10s targets:<server.online_players>
            - flag server restart_happening duration:<[mark].add[10s]>
        - wait <[mark].sub[<[marks].get[<[loop_index].add[1]>]||0s>]||5s>
    - inject stop_internal_task
    - flag server restarting_soon:!
    - adjust server restart

stopserver_world:
    type: world
    debug: false
    events:
        on stop|restart command:
        - if <player.has_permission[minecraft.command.stop]||<context.source_type.equals[server]>>:
            - narrate "<&[error]>Native stop command blocked: if you're serious, use <&[warning]>/stopserver"
            - determine fulfilled

stopserver_command:
    type: command
    debug: false
    name: stopserver
    permission: dscript.stopserver
    usage: /stopserver
    description: Admin only, stops the entire server.
    script:
    - inject stop_internal_task
    - adjust server shutdown

stop_internal_task:
    type: task
    debug: false
    script:
    - flag server restart_happening duration:5s
    - announce "<&[error]>Server RESTARTING NOW!"
    - kick <server.online_players> "reason:Restarting! Please wait a minute before rejoining."
    - adjust server save
    - wait 1s
