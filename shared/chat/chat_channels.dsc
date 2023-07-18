
channel_config:
    type: data
    debug: false
    colors:
        global: <&2>
        staff: <&6>
        local: <&f>
        event: <&c>
        whisper: <&color[#777777]>
        mutter: <&color[#777777]>
        broadcast: <&color[#c22929]>
        message: <&7>
        advert: <&a>

proc_name_format_local:
    type: procedure
    debug: false
    definitions: player
    script:
    - determine <proc[proc_name_color].context[<[player]>|<player>]><element[<[player].flag[current_character].proc[cc_name].context[<[player]>].proc[chat_emoji_handler]||<[player].flag[nickname]||<[player].name>>>].on_hover[(Local) <[player].name>].on_click[/msg <[player].name> ].type[SUGGEST_COMMAND]><&f>

chat_format_local_ooc:
    type: procedure
    debug: false
    definitions: player|text
    script:
    - determine "<&color[#777777]>[OOC] <[player].flag[nickname]||<[player].name>><&color[#777777]><&co> <[text]>"

chat_format_local_normal:
    type: procedure
    debug: false
    definitions: player|text
    script:
    - determine "<proc[proc_name_format_local].context[<[player]>]> says<&co><[player].flag[chat_color]||<&f>> <[text]>"

chat_format_local_ask:
    type: procedure
    debug: false
    definitions: player|text
    script:
    - determine "<proc[proc_name_format_local].context[<[player]>]> asks<&co><[player].flag[chat_color]||<&f>> <[text]>"

chat_format_local_exclaim:
    type: procedure
    debug: false
    definitions: player|text
    script:
    - determine "<proc[proc_name_format_local].context[<[player]>]> exclaims<&co><[player].flag[chat_color]||<&f>> <[text]>"

chat_format_local_shout:
    type: procedure
    debug: false
    definitions: player|text
    script:
    - determine "<proc[proc_name_format_local].context[<[player]>]> <&c><&l>shouts<&co><[player].flag[chat_color]||<&f>> <[text]>"

chat_format_local_whisper:
    type: procedure
    debug: false
    definitions: player|text
    script:
    - determine "<proc[proc_name_format_local].context[<[player]>]> <&color[#777777]>whispers<&co><[player].flag[chat_color]||<&f>> <[text]>"

chat_format_local_emote:
    type: procedure
    debug: false
    definitions: player|text
    script:
    - determine "<proc[proc_name_format_local].context[<[player]>]><&color[#B8A78F]><&o> <[text]>"

chat_format_local_emote_whisper:
    type: procedure
    debug: false
    definitions: player|text
    script:
    - determine "<proc[proc_name_format_local].context[<[player]>]><&color[#7D7D7D]><&o> <[text]>"

chat_format_local_mutter:
    type: procedure
    debug: false
    definitions: player|text
    script:
    - determine "<proc[proc_name_format_local].context[<[player]>]> <&color[#777777]>mutters<&co><[player].flag[chat_color]||<&f>> <[text]>"

chat_format_local_emote_mutter:
    type: procedure
    debug: false
    definitions: player|text
    script:
    - determine "<proc[proc_name_format_local].context[<[player]>]><&color[#7D7D7D]><&o> <[text]>"

chat_format_local_emote_loud:
    type: procedure
    debug: false
    definitions: player|text
    script:
    - determine "<proc[proc_name_format_local].context[<[player]>]><&color[#60D760]><&o> <[text]>"

chat_format_local_environmental:
    type: procedure
    debug: false
    definitions: player|text
    script:
    - determine <&color[#d9b577]><[text].on_hover[(Environmental) <[player].name>]>

proc_global_name:
    type: procedure
    debug: false
    definitions: player
    script:
    - determine <proc[proc_name_color].context[<[player]>|<player>]><[player].flag[nickname].if_null[<[player].proc[proc_safe_name]>].on_click[/msg <[player].proc[proc_safe_name]> ].type[SUGGEST_COMMAND]><&f>

chat_format_global:
    type: procedure
    debug: false
    definitions: player|text
    script:
    - determine "<&2><element[<&lb>G<&rb>].on_hover[Global Chat]> <[player].proc[proc_global_name]><&co> <[text]>"

chat_format_advert:
    type: procedure
    debug: false
    definitions: player|text
    script:
    - determine "<&a><element[<&lb>Advert<&rb>].on_hover[This player is advertising an RP opportunity]> <[player].proc[proc_global_name]><&co> <[text]>"

chat_format_broadcast:
    type: procedure
    debug: false
    definitions: player|text
    script:
    - determine "<n><script[channel_config].data_key[colors.broadcast].parsed><&l>[BROADCAST] <&f><[text]><n>"

chat_format_event:
    type: procedure
    debug: false
    definitions: player|text
    script:
    - determine "<&8>[<&[warning]>!<&8>] <script[channel_config].data_key[colors.event].parsed><[text].on_hover[(Event) <[player].name>]>"

chat_format_staff:
    type: procedure
    debug: false
    definitions: player|text
    script:
    - determine "<&6><element[<&lb>S<&rb>].on_hover[Staff Chat]> <[player].proc[proc_global_name]><&co> <[text]>"

chat_handler_world:
    type: world
    debug: false
    events:
        on player chats bukkit_priority:high:
        - define message <context.message>
        - determine passively cancelled
        - inject chat_handling_task
        - announce to_console "[CHAT] [<player.flag[channel]>] (to <[recipients].size>) <player.name>: <context.message>"

### CHAT RANGES AS IMPLEMENTED IN 'chat_handling_task'
# - Broadcast: global (/broadcast, staff only)
# - Staff: global but hidable (/staff, staff only)
# - Global: global but hidable (/global)
# - Advert: global but hidable (/advert)
# - Event: 35 (/event, staff only)
# - OOC: 13 (/ooc, or end line with '))')
# - Mutter: 5 (/mutter, or end line with '$')
# - Whisper: 2 (/whisper, or end line with '*')
# - SayLocal: 13 (/local)
# - Shout: 30 (in local end line with '!!')
# - Exclaim: 18 (in local end line with '!')
# - AnnounceEmote: 30 (in local end line with '@')
# - Emote: 20 (in local end line with '+')
# - Environment: 13 (in local end line with ']')

chat_handling_task:
    type: task
    debug: false
    definitions: message
    script:
        - define is_env <[message].ends_with[<&rb>].and[<[message].ends_with[<&rb><&rb>].not>]>
        - define message <[message].proc[chat_embed_handler]>
        - define orig_message <[message]>
        - define message <[message].proc[chat_emoji_handler]>
        - if !<player.has_flag[channel]>:
            - flag player channel:global
        - define recipients <server.online_players.filter[has_flag[hide_channel.<player.flag[channel]>].not]>
        - define format chat_format_global
        - define max_distance 0
        - define partial_range 0
        - define is_rp false
        - define relayable false
        - define autoquote false
        - define channel <player.flag[channel]>
        - if <[orig_message].contains_text[:]>:
            - choose <[orig_message].before[:]>:
                - case g:
                    - define channel global
                    - define message <[message].after[g:]>
                    - define orig_message <[orig_message].after[g:]>
                - case l:
                    - define channel local
                    - define message <[message].after[l:]>
                    - define orig_message <[orig_message].after[l:]>
                - case m:
                    - define channel mutter
                    - define message <[message].after[m:]>
                    - define orig_message <[orig_message].after[m:]>
                - case e:
                    - define channel local
                    # local will parse the 'e:'
                - case w:
                    - define channel whisper
                    - define message <[message].after[w:]>
                    - define orig_message <[orig_message].after[w:]>
                - case s:
                    - if <player.has_permission[dscript.staffchat]>:
                        - define channel staff
                        - define message <[message].after[s:]>
                        - define orig_message <[orig_message].after[s:]>
        - choose <[channel]>:
            - case global:
                - define format chat_format_global
                - define relayable true
            - case advert:
                - define format chat_format_advert
                - define relayable true
                - if <player.has_flag[advert_ratelimit]>:
                    - narrate "<&[error]>You can only send <&a>advert<&[error]> messages once every <&[emphasis]>10 minutes<&[error]>. You are on cooldown for <&[emphasis]><player.flag_expiration[advert_ratelimit].from_now.formatted>"
                    - stop
                - flag player advert_ratelimit expire:10m
            - case broadcast:
                - define format chat_format_broadcast
                - define relayable true
            - case staff:
                - define recipients <[recipients].filter[has_permission[dscript.staffchat]]>
                - define format chat_format_staff
                - define relayable true
            - case event:
                - define max_distance 35
                - define format chat_format_event
            - case mutter:
                - define is_rp true
                - if <[message].starts_with[((]> || <[message].starts_with[))]> || <[message].ends_with[((]> || <[message].ends_with[))]> || <player.flag[character_mode]> != ic:
                    - define is_rp false
                    - define max_distance 13
                    - define format chat_format_local_ooc
                    - if <[message].ends_with[))]>:
                        - define message <[message].before_last[))]>
                - else if <[message].starts_with[e:]>:
                    - define max_distance 5
                    - define partial_range 10
                    - define format chat_format_local_emote_mutter
                    - define raw_message <[message].after[e:]>
                    - define text_color <&color[#7D7D7D]>
                    - inject chat_local_emote_handler
                - else if <[message].ends_with[+]>:
                    - define max_distance 5
                    - define partial_range 10
                    - define format chat_format_local_emote_mutter
                    - define raw_message <[message].before_last[+]>
                    - define text_color <&color[#7D7D7D]>
                    - inject chat_local_emote_handler
                - else:
                    - define max_distance 5
                    - define partial_range 10
                    - define format chat_format_local_mutter
                    - define autoquote true
            - case whisper:
                - define is_rp true
                - if <[message].starts_with[((]> || <[message].starts_with[))]> || <[message].ends_with[((]> || <[message].ends_with[))]> || <player.flag[character_mode]> != ic:
                    - define is_rp false
                    - define max_distance 13
                    - define format chat_format_local_ooc
                    - if <[message].ends_with[))]>:
                        - define message <[message].before_last[))]>
                - else if <[message].starts_with[e:]>:
                    - define max_distance 2
                    - define partial_range 5
                    - define format chat_format_local_emote_whisper
                    - define raw_message <[message].after[e:]>
                    - define text_color <&color[#7D7D7D]>
                    - inject chat_local_emote_handler
                - else if <[message].ends_with[+]>:
                    - define max_distance 2
                    - define partial_range 5
                    - define format chat_format_local_emote_whisper
                    - define raw_message <[message].before_last[+]>
                    - define text_color <&color[#7D7D7D]>
                    - inject chat_local_emote_handler
                - else:
                    - define max_distance 2
                    - define partial_range 5
                    - define format chat_format_local_whisper
                    - define autoquote true
            - case local:
                - define is_rp true
                - if <[message].starts_with[((]> || <[message].starts_with[))]> || <[message].ends_with[((]> || <[message].ends_with[))]> || <player.flag[character_mode]> != ic:
                    - define is_rp false
                    - define max_distance 13
                    - define format chat_format_local_ooc
                    - if <[message].ends_with[))]>:
                        - define message <[message].before_last[))]>
                - else if <[message].ends_with[!!]>:
                    - define max_distance 30
                    - define partial_range 50
                    - define format chat_format_local_shout
                    - define autoquote true
                - else if <[message].ends_with[!]>:
                    - define max_distance 18
                    - define partial_range 25
                    - define format chat_format_local_exclaim
                    - define autoquote true
                - else if <[message].ends_with[?]>:
                    - define max_distance 13
                    - define partial_range 18
                    - define format chat_format_local_ask
                    - define autoquote true
                - else if <[message].ends_with[@]>:
                    - define max_distance 30
                    - define format chat_format_local_emote_loud
                    - define raw_message <[message].before_last[@]>
                    - define text_color <&color[#60D760]>
                    - inject chat_local_emote_handler
                - else if <[message].starts_with[e:]>:
                    - define max_distance 20
                    - define format chat_format_local_emote
                    - define raw_message <[message].after[e:]>
                    - define text_color <&color[#B8A78F]>
                    - inject chat_local_emote_handler
                - else if <[message].ends_with[+]>:
                    - define max_distance 20
                    - define format chat_format_local_emote
                    - define raw_message <[message].before_last[+]>
                    - define text_color <&color[#B8A78F]>
                    - inject chat_local_emote_handler
                - else if <[is_env]>:
                    - define max_distance 13
                    - define partial_range 18
                    - define format chat_format_local_environmental
                    - define message <[message].before_last[<&rb>]>
                - else if <[message].ends_with[$]>:
                    - define message <[message].before_last[$]>
                    - define max_distance 5
                    - define partial_range 10
                    - define format chat_format_local_mutter
                    - define autoquote true
                - else if <[message].ends_with[*]>:
                    - define message <[message].before_last[*]>
                    - define max_distance 2
                    - define partial_range 5
                    - define format chat_format_local_whisper
                    - define autoquote true
                - else:
                    - define max_distance 13
                    - define partial_range 18
                    - define format chat_format_local_normal
                    - define autoquote true
        - define player <player>
        - define partial_hearers <list>
        - if <[autoquote]> && !<player.has_flag[toggle_quotes_off]> && !<[message].starts_with[<&dq>]>:
            - define message <&dq><[message]><&dq>
        - if <[max_distance]> != 0:
            - define even_possible <[recipients].filter[world.name.equals[<player.location.world.name>]]>
            - define recipients <[even_possible].filter[proc[local_chat_dist_proc].context[<player>].is[less].than[<[max_distance]>]]>
            - if <[partial_range]> != 0:
                - define partial_hearers <[even_possible].filter[proc[local_chat_dist_proc].context[<player>].is[less].than[<[partial_range]>]].exclude[<[recipients]>]>
                - if <[partial_hearers].any>:
                    - define partial_message <[message].proc[message_partialize_proc]>
                    - narrate <proc[<[format]>].context[<list_single[<[player]>].include_single[<[partial_message]>]>]> t:<[partial_hearers]> from:<player.uuid> per_player
            - flag player last_chat_recip_count:<[recipients].size> duration:1t
            - if <[recipients].size.add[<[partial_hearers].size>]> <= 1:
                - actionbar "<&[error]><&o>You are speaking only to yourself."
        - narrate <proc[<[format]>].context[<list_single[<[player]>].include_single[<[message]>]>]> t:<[recipients]> from:<player.uuid> per_player
        - if <[relayable]>:
            - bungeerun <bungee.list_servers.exclude[<bungee.server>]> bungee_chat_show def:<list_single[<[channel]>].include_single[<player>].include_single[<[message]>]>
        - if <server.has_flag[is_roleplay_server]>:
            - run player_chat_relay_discord def:<list_single[<[orig_message].strip_color>].include_single[<[channel]>]>
            - if <[is_rp]>:
                - flag <player> rp_stats.<util.time_now.format[yyyy_MM_dd]>:+:<[orig_message].strip_color.length>
                - if <player.has_flag[refer_waiting]>:
                    - flag player refer_waiting:+:<[orig_message].length>
                    - if <player.flag[refer_waiting]> >= 30000:
                        - run refer_complete
                - foreach <player.location.cuboids.include[<player.location.polygons>].filter[note_name.starts_with[rentable_id_]].parse[note_name.after[rentable_id_]]> as:rentplace:
                    - flag server rentables.<[rentplace]>.rp_stats.<util.time_now.format[yyyy_MM_dd]>:+:<[orig_message].strip_color.length>
        - else:
            - bungeerun roleplay player_chat_relay_discord def:<list_single[<[orig_message].strip_color>].include_single[<[channel]>]>

local_chat_dist_proc:
    type: procedure
    debug: false
    definitions: player|speaker
    script:
    - define dist <[player].location.distance[<[speaker].location>]>
    # 50 = partial hearing on shout, ie max
    - if <[dist]> > 50:
        - determine 5000
    - if <[player].can_see[<[speaker]>]>:
        - determine <[dist]>
    - determine <[dist].mul[2]>

message_partialize_proc:
    type: procedure
    debug: false
    definitions: message
    script:
    - define words <[message].strip_color.split>
    - define min <util.random.int[2].to[<[words].size>]>
    - repeat <util.random.int[<[min]>].to[<[words].size>]>:
        - define words[<util.random.int[1].to[<[words].size>]>]:...
    - determine <[words].separated_by[ ]>
