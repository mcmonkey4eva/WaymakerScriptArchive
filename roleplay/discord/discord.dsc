discord_world:
    type: world
    debug: false
    events:
        after bungee player joins network:
        - define __player <player[<context.uuid>]>
        - waituntil rate:1t max:5s <player.is_online||false>
        - if !<player.is_online||false>:
            - stop
        - if !<player.has_flag[vanished]>:
            - define message "] <&lt>**`<player.name>`**<&gt> **JOINS**"
            - run discord_send_message def:<list[<server.flag[discord_chat_channel]>].include_single[<[message]>]>
        on player joins:
        - flag player did_join_rp_server
        - flag player last_joined_time:<util.time_now>
        - define addr <player.ip.address_only||?>
        - wait 1t
        - define vanish <player.has_flag[vanished].if_true[ (Vanished)].if_false[]>
        - define loc <player.location.simple||?>
        - waituntil rate:5t max:10s <player.client_brand||unknown> != unknown || !<player.is_online>
        - define message "] <&lt>**`<player.name>`** (`<player.uuid>`)<&gt> **JOINS** from IP `<[addr]>` with client brand `<player.client_brand||unknown>` at location `<[loc]>`<[vanish]>"
        - run discord_send_message def:<list[<server.flag[discord_logs_channel]>].include_single[<[message]>]>
        on bungee player leaves network:
        - define __player <player[<context.uuid>]>
        - if !<player.is_whitelisted||false>:
            - stop
        - if !<player.has_flag[last_joined_time]||false>:
            - announce to_console "Never-Joined-Before join failed for <context.uuid> / <context.name>"
            - stop
        - if !<player.has_flag[did_join_rp_server]||false>:
            - announce to_console "Other join failure for <context.uuid> / <context.name>"
            - stop
        - define vanish " (Vanished)"
        - if !<player.has_flag[vanished]>:
            - define message "] <&lt>**`<player.name>`**<&gt> **QUITS**"
            - run discord_send_message def:<list[<server.flag[discord_chat_channel]>].include_single[<[message]>]>
            - define vanish <empty>
        - define message "] <&lt>**`<player.name>`** (`<player.uuid>`)<&gt> **QUITS** after `<util.time_now.duration_since[<player.flag[last_joined_time]>].formatted>` online<[vanish]>"
        - run discord_send_message def:<list[<server.flag[discord_logs_channel]>].include_single[<[message]>]>
        - flag player did_join_rp_server:!
        #on player chats priority:10 ignorecancelled:true:
        #- define message <context.message>
        #- inject player_chat_relay_discord
        #on mpm_message_receive:
        #- announce to_console "MPM Message from <player.name> : <context.message>"
        #- if !<player.has_flag[mpm_seen]>:
        #    - flag <player> mpm_seen duration:10h
        #    - define message "] <&lt>**`<player.name>`** (`<player.uuid>`)<&gt> **is using MPM**"
        #    - run discord_send_message def:<list[<server.flag[discord_logs_channel]>].include_single[<[message]>]>
        on player quits flagged:mpm_seen:
        - flag <player> mpm_seen:!
        on discord message received for:relaybot:
        - if <context.bot.self_user.id> == <context.new_message.author.id> || <context.new_message.author.is_bot>:
            - stop
        - announce to_console "[Discord] #<context.channel.name> <&lt><context.new_message.author.name>(<context.new_message.author.id>)<&gt> sent: <context.new_message.text>"
        - if <context.channel.id> not in <server.flag[discord_chat_channel]>|<server.flag[discord_staff_channel]>|<server.flag[discord_advert_channel]>:
            - stop
        - define speaker <context.new_message.author>
        - define message <context.new_message.text_display.strip_color.replace_text[<&chr[D]>].replace_text[<n>]>
        - if <[message].starts_with[!players]>:
            - define to_list <server.flag[bungee_player_isonline].keys.parse[as[player]].filter[has_flag[vanished].not]||<list>>
            - if <[to_list].is_empty>:
                - define message "] **PLAYERS ONLINE**<&co> None"
            - else:
                - define message "] **PLAYERS ONLINE** (<[to_list].size>)<&co> `<[to_list].parse[proc[proc_format_name].context[null|true].strip_color].formatted>`"
            - run discord_send_message def:<list[<context.channel>].include_single[<[message]>]>
            - stop
        - else if <context.channel.id> == <server.flag[discord_advert_channel]>:
            - define channel advert
        - else if <context.channel.id> == <server.flag[discord_chat_channel]>:
            - define channel global
        - else:
            - define channel staff
        - define message <[message].proc[chat_emoji_handler]>
        - if <[speaker].has_flag[minecraft_account]>:
            - define player <[speaker].flag[minecraft_account]>
            - define name <[player].name>
        - else:
            - define player null
            - define name <[speaker].name>
        - bungeerun <bungee.list_servers> bungee_discord_chat_show def:<list_single[<[channel]>].include_single[<[name]>].include_single[<[player]>].include_single[<[message]>]>
        on server start:
        - wait 2s
        - run discord_reconnect def:true

fakejoin_for_relay:
    type: task
    debug: false
    script:
    - define message "] <&lt>**`<player.name>`**<&gt> **JOINS**"
    - run discord_send_message def:<list[<server.flag[discord_chat_channel]>].include_single[<[message]>]>
    - run "discord_world.events.on player joins"
    - flag player did_join_rp_server

player_chat_discord_webhook:
    type: task
    debug: false
    definitions: hook|message
    script:
    - definemap headers:
        User-Agent: dDiscordBot
        Content-Type: application/json
    - definemap data:
        username: <&lb>Relay<&rb> <player.name>
        avatar_url: https://minotar.net/armor/bust/<player.uuid.replace_text[-]>/100.png?date=<util.time_now.format[yyyy-MM-dd-HH]>
        content: <[message].proc[discord_escape_simple_proc]>
    - webget <[hook]> headers:<[headers]> data:<[data].to_json>

player_chat_relay_discord:
    type: task
    debug: false
    definitions: orig_message|chat_channel
    script:
    - if <player.has_flag[muted]>:
        - stop
    - define channel discord_local_channel
    - if <[chat_channel]> == global:
        - run player_chat_discord_webhook def.hook:<secret[globalchat_webhook]> def.message:<[orig_message]>
        - stop
        #- define channel discord_chat_channel
    - else if <[chat_channel]> == staff:
        - run player_chat_discord_webhook def.hook:<secret[staffchat_webhook]> def.message:<[orig_message]>
        - stop
        #- define channel discord_staff_channel
    - else if <[chat_channel]> == advert:
        - run player_chat_discord_webhook def.hook:<secret[advertchat_webhook]> def.message:<[orig_message]>
        - stop
        #- define channel discord_advert_channel
    - else if <player.has_flag[last_chat_recip_count]>:
        - define channel_name "<[chat_channel]> (to <player.flag[last_chat_recip_count].sub[1]>)"
        - if <player.gamemode> == creative:
            - define channel_name "<[channel_name]> (Creative)"
    - define message <[orig_message]>
    - if <[message].length> >= 1100:
        - define message "<[message].substring[1,1000]>... (Trimmed)"
    - define player_name <player.name>
    - if ( <player.flag[character_mode]> == ic ) && <list[local|whisper].contains[<player.flag[channel]>]>:
        - define player_name "<player.name> (<player.proc[character_name_proc].proc[discord_escape]>)"
    - define disc_message "[<[channel_name]||<[chat_channel]>>] **`<[player_name]>`** says: <[message].proc[discord_escape_simple_proc]>"
    - run discord_send_message def:<list[<server.flag[<[channel]>]>].include_single[<[disc_message]>]>
    - define log_message "<&8><util.time_now.format> <&7>[<[channel_name]||<player.flag[channel]>>] <&[emphasis]><&lt><player.name><&gt> <&7>says: <&f><[orig_message]>"
    - run chat_history_load
    - yaml set history.<util.time_now.format[yyyy.MM.dd]>:->:<[log_message]> id:chat_log_<player.uuid>
    - if <[chat_channel]> == broadcast:
        - define channel discord_chat_channel
        - define disc_message "[BROADCAST]: <[message].proc[discord_escape_simple_proc]>"
        - run discord_send_message def:<list[<server.flag[<[channel]>]>].include_single[<[disc_message]>]>

discord_reconnect:
    type: task
    debug: false
    definitions: is_first
    script:
    - if !<[is_first]||false>:
        - discord id:relaybot disconnect
    - yaml load:savedata/discordbot.yml id:bot_temp
    - ~discordconnect id:relaybot token:<secret[discord_bot_token]>
    #- flag server discord_chat_channel:<yaml[bot_temp].read[discord.bot.chat-channel]>
    #- flag server discord_logs_channel:<yaml[bot_temp].read[discord.bot.logs-channel]>
    #- flag server discord_local_channel:<yaml[bot_temp].read[discord.bot.local-channel]>
    #- flag server discord_staff_channel:<yaml[bot_temp].read[discord.bot.staff-channel]>
    #- flag server discord_advert_channel:<yaml[bot_temp].read[discord.bot.advert-channel]>
    #- flag server discord_ticket_channel:<yaml[bot_temp].read[discord.bot.ticket-channel]>
    #- flag server discord_slowlog_channel:<yaml[bot_temp].read[discord.bot.slow-log-channel]>
    - yaml unload id:bot_temp
    - wait 5s
    - ~discordmessage id:relaybot channel:<server.flag[discord_chat_channel]> "Connected and online."

discord_send_message_immediate:
    type: task
    debug: false
    definitions: channel|message|attach_name|attach_text
    script:
    - if <[channel].starts_with[discord_]>:
        - define channel <server.flag[<[channel]>]>
    - if <[attach_name].exists>:
        - ~discordmessage id:relaybot channel:<[channel]> <[message]> attach_file_name:<[attach_name]> attach_file_text:<[attach_text]>
    - else:
        - ~discordmessage id:relaybot channel:<[channel]> <[message].trim>

discord_send_message:
    type: task
    debug: false
    definitions: channel|message
    script:
    - if <[channel].starts_with[discord_]>:
        - define channel <server.flag[<[channel]>]>
    - if <[message].length> >= 1750:
        - define message "<[message].substring[1,1700]>... (Trimmed)"
    - flag server discord_messages.<[channel]>:->:<[message]>
    - run discord_process_messages def:<[channel]>

discord_process_messages:
    type: task
    debug: false
    definitions: channel
    script:
    - if <server.flag[discord_messages.<[channel]>].is_empty||true>:
        - stop
    - if <server.has_flag[discord_message_delay]>:
        - wait 1s
        - run discord_process_messages def:<[channel]>
        - stop
    - flag server discord_message_delay duration:1s
    - define message <empty>
    - foreach <server.flag[discord_messages.<[channel]>]> as:submessage:
        - if <[message].length.add[<[submessage].length>]> > 1800:
            - foreach stop
        - define message <[message]><[submessage]><n>
        - flag server discord_messages.<[channel]>[1]:<-
    - ~discordmessage id:relaybot channel:<[channel]> <[message].trim>
    - if !<server.flag[discord_messages.<[channel]>].is_empty||true>:
        - run discord_process_messages def:<[channel]>

discord_command:
    type: command
    debug: false
    name: discord
    usage: /discord
    description: Gets a discord link.
    script:
    - narrate <&b><underline><element[https://discord.gg/xxx].on_click[https://discord.gg/xxx].type[open_url]>
    - if !<player.has_flag[discord_account]>:
        - narrate "<&[base]>Link your account by typing <&[emphasis]>!link <player.name><&[base]> in the <&[emphasis]>#bot-spam<&[base]> channel."

discord_dualserver_bridge:
    type: world
    debug: false
    events:
        after discord user role changes group:123:
        - run discord_role_bridge_stafftopublic def.staff_roles:<context.new_roles> def.user:<context.user>
        after discord user leaves group:123:
        - run discord_role_bridge_stafftopublic def.staff_roles:<list> def.user:<context.user>

discord_role_bridge_stafftopublic:
    type: task
    debug: false
    data:
        staff_to_public:
            # Members
            123: 123
            # Trainee
            123: 123
            # Lead
            123: 123
            # Officer
            #123:
            # Tech
            123: 123
            # Lore
            123: 123
            # PR
            123: 123
            # Build
            123: 123
            # Mod
            123: 123
            # Event
            123: 123
            # Art
            123: 123
    definitions: staff_roles|user
    script:
    - if <[user].is_bot>:
        - stop
    - define controlled <script.data_key[data.staff_to_public].values>
    - define public_roles <[user].roles[relaybot,123].parse[id].filter_tag[<[controlled].contains[<[filter_value]>]>]||null>
    - if <[public_roles]> == null:
        - announce to_console "Not updating roles for <[user]> because they're not in public discord"
        - stop
    - define intended_public_role_ids <[staff_roles].parse_tag[<script.data_key[data.staff_to_public.<[parse_value].id>]||0>].exclude[0]>
    - define to_remove <[public_roles].exclude[<[intended_public_role_ids]>]>
    - define to_add <[intended_public_role_ids].exclude[<[public_roles]>]>
    - if <[to_remove].is_empty> && <[to_add].is_empty>:
        - announce to_console "Not updating roles for <[user]> because no changes to make"
        - stop
    - announce to_console "updating roles for <[user]>: add <[to_add].comma_separated> ... remove <[to_remove].comma_separated>"
    - foreach <[to_add]> as:role:
        - ~discord id:relaybot add_role user:<[user]> role:<[role]> group:relaybot,123
    - foreach <[to_remove]> as:role:
        - ~discord id:relaybot remove_role user:<[user]> role:<[role]> group:relaybot,123
