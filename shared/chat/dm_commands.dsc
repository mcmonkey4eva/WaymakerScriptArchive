tell_command:
    type: command
    debug: false
    name: tell
    aliases:
    - msg
    - message
    - dm
    - pm
    usage: /tell [player] (message)
    description: Sends a private message to somebody.
    permission: dscript.tell
    script:
    - if <player.has_flag[muted]>:
        - narrate "<&[error]>Cannot speak, you're muted!"
        - stop
    - if <context.args.is_empty>:
        - narrate "<&[error]>/tell [player] (message)"
        - stop
    - define first <context.args.first.proc[match_anywhere_online_player]>
    - if <[first]> == null:
        - narrate "<&[error]>Unknown player '<&[emphasis]><context.args.first><&[error]>'."
        - stop
    - if <context.args.size> < 2:
        - flag player pre_message_channel:<player.flag[channel]||global>
        - flag player channel:Message duration:24h
        - flag player message_channel_to:<[first]> duration:24h
        - narrate "<&[base]>Now in a private channel to <proc[proc_format_name].context[<[first]>|<player>]>."
        - stop
    - define message <context.raw_args.after[ ]>
    - if <context.source_type> != player:
        - narrate "<&[base]>[(Server) to <proc[proc_name_color].context[<player>|<[first]>]>] <&f><[message]>" targets:<[first]>
        - stop
    - run dm_message_task def:<list_single[<[first]>].include_single[<[message]>]>

reply_command:
    type: command
    debug: false
    name: reply
    aliases:
    - r
    usage: /reply [message]
    description: Reply to the last private message.
    permission: dscript.tell
    script:
    - if <player.has_flag[muted]>:
        - narrate "<&[error]>Cannot speak, you're muted!"
        - stop
    - if <context.args.is_empty>:
        - narrate "<&[error]>/reply [message]"
        - stop
    - if !<player.has_flag[last_dm]> || !<server.has_flag[bungee_player_isonline.<player.flag[last_dm].uuid||null>]> && !<player.flag[last_dm].is_online||false>:
        - narrate "<&[error]>Nobody to reply to."
        - stop
    - define target <player.flag[last_dm].as[player]>
    - define message <context.raw_args>
    - run dm_message_task def:<list_single[<[target]>].include_single[<[message]>]>

dm_message_task:
    type: task
    debug: false
    definitions: target|message
    script:
    - define message <proc[chat_embed_handler].context[<list_single[<[message]>]>]>
    - define orig_message <[message]>
    - define message <[message].proc[chat_emoji_handler]>
    - define prefix_b "<&[base]>[<&[emphasis]><proc[proc_name_color].context[<player>|<player>]><player.name> <&[base]>to <&[emphasis]><proc[proc_name_color].context[<[target]>|<player>]><[target].proc[proc_safe_name]><&[base]>]"
    - narrate "<[prefix_b].on_click[/tell <[target].name> ].type[suggest_command]> <&f><[message]>" from:<player.uuid>
    - flag <player> last_dm:<[target]>
    - if <[target].is_online>:
        - run dm_message_task_output def:<list[<player>|<[target]>].include_single[<[message]>]>
    - else:
        - bungeerun <server.flag[bungee_player_server.<[target].uuid>]> dm_message_task_output def:<list[<player>|<[target]>].include_single[<[message]>]>
    - define disc_message "[MSG] [`<player.name>` -<&gt> `<[target].proc[proc_safe_name]>`]: `<[orig_message].proc[discord_escape]>`"
    - announce to_console <[disc_message]>
    - define log_message "<&8><util.time_now.format> <&7>[MSG] <&[emphasis]><&lt><player.name><&gt> <&7>DMs to <&[emphasis]><&lt><[target].name><&gt>: <&f><[message]>"
    - if <server.has_flag[is_roleplay_server]>:
        - run discord_send_message def:<list[<server.flag[discord_local_channel]>].include_single[<[disc_message]>]>
        - yaml set history.<util.time_now.format[yyyy.MM.dd]>:->:<[log_message]> id:chat_log_<player.uuid>
    - else:
        - bungeerun roleplay discord_send_message def:<list[discord_local_channel].include_single[<[disc_message]>]>
        - bungeerun roleplay chat_history_log def:<list[<player>].include_single[<[log_message]>]>

dm_message_task_output:
    type: task
    debug: false
    definitions: sender|target|message
    script:
    - flag <[target]> last_dm:<[sender]>
    - define prefix_a "<&[base]>[<&[emphasis]><proc[proc_name_color].context[<[sender]>|<[target]>]><[sender].proc[proc_safe_name]> <&[base]>to <&[emphasis]><proc[proc_name_color].context[<[target]>|<[target]>]><[target].proc[proc_safe_name]><&[base]>]"
    - narrate "<[prefix_a].on_click[/tell <[sender].proc[proc_safe_name]> ].type[suggest_command]> <&f><[message]>" targets:<[target]> from:<[sender].uuid>

direct_message_world:
    type: world
    debug: false
    events:
        on player joins:
        - flag player last_dm:!
        - if <player.flag[channel]||null> == Message:
            - flag player channel:!
        - flag player message_channel_to:!
        on player chats priority:-10 flagged:message_channel_to:
        - if <player.flag[channel]||null> != Message:
            - stop
        - if !<server.has_flag[bungee_player_isonline.<player.flag[message_channel_to].uuid||null>]> && !<player.flag[message_channel_to].is_online||false>:
            - flag player message_channel_to:!
            - flag player channel:<player.flag[pre_message_channel]>
            - flag player pre_message_channel:!
            - narrate "<&[base]>Your last message went nowhere, as the player you were in a private message channel with is no longer online. You are now back in your previous channel."
            - determine cancelled
        - run dm_message_task def:<list_single[<player.flag[message_channel_to]>].include_single[<context.message>]>
        - determine cancelled
