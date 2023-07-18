player_info_staff_command:
    type: command
    debug: false
    name: player
    usage: /player [player]
    aliases:
    - seen
    description: Displays staff information about a player.
    permission: dscript.player
    script:
    - if <context.args.is_empty>:
        - narrate "<&[error]>/player [player]"
        - stop
    - define target <server.match_offline_player[<context.args.get[1]>]||null>
    - if <[target]> == null:
        - narrate "<&[error]>Unknown target player."
        - stop
    - narrate "<&[base]>=============== Player <&[emphasis]><[target].name><&[base]> ==============="
    - narrate "<&[base]>UUID: <&[emphasis]><[target].uuid>"
    - if <player.has_permission[dscript.ecostaff]||<context.server>>:
        - narrate "<&[base]>Balance: <&6><[target].money> TG"
    - if <player.has_permission[dscript.ip_history]||<context.server>>:
        - if <[target].flag[known_ips].size||1> == 1:
            - narrate "<&[base]>Last known IP: <&[emphasis]><[target].flag[last_ip]||Unknown>"
        - else:
            - narrate "<&[base]>Last known IP: <&[emphasis]><[target].flag[last_ip]> <&[base]>(<&[emphasis]><[target].flag[known_ips].size> <&[base]>IPs seen for this player)"
    - if <player.has_permission[dscript.alt_history]||<context.server>>:
        - define other_players <[target].flag[known_ips].parse_tag[<server.flag[ip_accounts.<[parse_value].escaped>]>].combine.deduplicate.exclude[<[target]>]||<list>>
        - if !<[other_players].is_empty>:
            - define list_formatted <[other_players].parse_tag[<[parse_value].name.on_hover[<[parse_value].uuid>]>]>
            - narrate "<&[base]>Player's IP addresses have also been seen with accounts: <&[emphasis]><[list_formatted].separated_by[<&[base]>, <&[emphasis]>]>"
    - narrate "<&[base]>Known usernames: <&[emphasis]><[target].flag[known_names].formatted||None>"
    - if <[target].has_flag[vanished]> && <player.has_permission[dscript.vanish]||<context.server>>:
        - narrate "<&[base]>Currently vanished."
    - narrate "<&[base]>First played: <&[emphasis]><[target].first_played_time.format> <&[base]>(<&[emphasis]><util.time_now.duration_since[<[target].first_played_time>].formatted><&[base]> ago)"
    - if !<[target].is_online>:
        - narrate "<&[base]>Last played: <&[emphasis]><[target].last_played_time.format> <&[base]>(<&[emphasis]><util.time_now.duration_since[<[target].last_played_time>].formatted><&[base]> ago)"
    - else if !<[target].has_flag[vanished]>:
        - narrate "<&[base]>Currently online."
        - if <[target].has_flag[auto_afk_mark]>:
            - narrate "<&[base]>Has been AFK for: <&[emphasis]><[target].flag[monitor_afk].from_now.formatted>"
    - if <player.has_permission[dscript.warn_history]||<context.server>>:
        - narrate "<&[base]>Total play time: <&[emphasis]><duration[<[target].statistic[play_one_minute]>t].formatted>"
    - foreach <player.flag[character_cards]||<list>> key:char as:char_data:
        - narrate "<&[base]>Character: <&[emphasis]><[char_data.name]>"
        - if !<[char_data.rentables_owned].is_empty||true>:
            - narrate "<&[base]>... Properties owned: <&[emphasis]><[char_data.rentables_owned].parse[unescaped].formatted||None>"
        - if !<[char_data.businesses_owned].is_empty||true>:
            - narrate "<&[base]>... Businesses owned: <&[emphasis]><[char_data.businesses_owned].parse[unescaped].formatted||None>"
    - if <[target].has_flag[discord_account]>:
        - define discord_name <discord_user[relaybot,<[target].flag[discord_account]>].name||null>
        - if <[discord_name]> != null:
            - narrate "<&[base]>Discord account: <&[emphasis]><[discord_name]>#<discord_user[relaybot,<[target].flag[discord_account]>].discriminator>"
    - if <[target].has_flag[irl_dob]>:
        - narrate "<&[base]>Date of Birth: <[target].flag[irl_dob].format[yyyy/MM/dd].custom_color[emphasis]> (<[target].flag[irl_dob].from_now.in_years.round_down.custom_color[emphasis]> years old)"
    - if <player.has_permission[dscript.warn_history]||<context.server>>:
        - if <[target].flag[warnings].size||0> > 0:
            - narrate "<&[base]>Warning history:"
        - foreach <[target].flag[warnings].reverse.get[1].to[20]||<list>> as:warning:
            - narrate "<&[warning]><[warning].get[type]> <&7><[warning].get[date].format><&[warning]> from <&[emphasis]><[warning].get[creator].name||Server/Unknown><&[warning]>: <&f><[warning].get[reason]>"
        - if <[target].flag[warnings].size||0> > 20:
            - narrate "<&[error]>AND MORE! Ban this user already!"
            - stop
    - if <[target].has_flag[personal_name_color]>:
        - narrate "<&[base]>Their <&[emphasis]>/mycolor <&[base]>is: <[target].flag[personal_name_color]>#<[target].flag[personal_name_color].replace_text[<&ss>].replace_text[x]>"

player_info_logger_world:
    type: world
    debug: false
    events:
        on player joins:
        - flag player known_names:<list[<player.flag[known_names]||<list>>].include[<player.name>].deduplicate>
        - flag player last_ip:<player.ip.address_only>
        - define ip <player.ip.address_only.before[:].replace_text[/]>
        - flag player known_ips:<list[<player.flag[known_ips]||<list>>].include[<[ip]>].deduplicate>
        - flag server ip_accounts.<[ip].escaped>:<list[<server.flag[ip_accounts.<[ip].escaped>]||<list>>].include[<player>].deduplicate>
        - if <player.has_flag[last_seen_name]> && <player.flag[last_seen_name]> != <player.name>:
            - define message "] <&lt>**`<player.name>`**<&gt> **CHANGED THEIR USERNAME** from `<player.flag[last_seen_name]>`"
            - flag player last_seen_name:<player.name>
            - run discord_send_message def:<list[<server.flag[discord_chat_channel]>].include_single[<[message]>]>
            - run discord_send_message def:<list[<server.flag[discord_slowlog_channel]>].include_single[<[message]>]>
