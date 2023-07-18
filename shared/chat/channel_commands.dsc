channel_command:
    type: command
    debug: false
    permission: dscript.channel
    name: channel
    usage: /channel [channel]
    description: Sets your current chat channel.
    aliases:
    - ch
    - chat
    tab complete:
    - define list <list[local|global|toggle|color|whisper|mutter|advert]>
    - if <player.has_permission[dscript.staffchat]>:
        - define list:->:staff
    - if <player.has_permission[dscript.eventchat]>:
        - define list:->:event
    - if <player.has_permission[dscript.broadcastchat]>:
        - define list:->:broadcast
    - determine <[list]>
    script:
    - if <context.args.first||help> == help:
        - narrate "<&[error]>/channel [channel] <&[warning]>or <&[error]>/ch toggle (channel)"
        - narrate "<&[base]>You can use choose a chat color with:<n><element[<&f>/chat color 1].on_hover[Click me!].on_click[/chat color 1]> <element[<&color[#C4FFC2]>/chat color 2].on_hover[Click me!].on_click[/chat color 2]> <element[<&color[#FFF5AA]>/chat color 3].on_hover[Click me!].on_click[/chat color 3]> <element[<&color[#CCFFFE]>/chat color 4].on_hover[Click me!].on_click[/chat color 4]>"
        - narrate "<&[base]>If confused about chat, use <proc[clickable_cmd_proc].context[/help chat]>"
        - narrate "<&[emphasis]>You are currently in <green><player.flag[channel]||global><&[emphasis]>."
        - run chat_channel_show_task
        - stop
    - if <context.args.first> == hide || <context.args.first> == leave || <context.args.first> == toggle:
        - if <context.args.size> == 2:
            - if <context.args.get[2].starts_with[g]>:
                - if <player.has_flag[hide_channel.global]>:
                    - flag player hide_channel.global:!
                    - narrate "<&[base]>Global chat reshown."
                - else:
                    - flag player hide_channel.global
                    - narrate "<&[warning]>Global chat hidden."
                - stop
            - else if <context.args.get[2].starts_with[a]>:
                - if <player.has_flag[hide_channel.advert]>:
                    - flag player hide_channel.advert:!
                    - narrate "<&[base]>Advert chat reshown."
                - else:
                    - flag player hide_channel.advert
                    - narrate "<&[warning]>Advert chat hidden."
                - stop
            - else if <context.args.get[2].starts_with[s]> && <player.has_permission[dscript.staffchat]>:
                - if <player.has_flag[hide_channel.staff]>:
                    - flag player hide_channel.staff:!
                    - narrate "<&[base]>Staff chat reshown."
                - else:
                    - flag player hide_channel.staff
                    - narrate "<&[warning]>Staff chat hidden."
                - stop
    - else if <context.args.first> == color:
        - choose <context.args.get[2]||null>:
            - case 1:
                - flag player chat_color:<&f>
            - case 2:
                - flag player chat_color:<&color[#C4FFC2]>
            - case 3:
                - flag player chat_color:<&color[#FFF5AA]>
            - case 4:
                - flag player chat_color:<&color[#CCFFFE]>
            - default:
                - narrate "<&[error]>Unknown chat color choice."
                - stop
        - narrate "<player.flag[chat_color]>Your chat color is now this."
        - stop
    - else if <context.args.first> == whohides:
        - foreach <server.online_players.filter[has_flag[vanished].not].filter[has_flag[hide_channel]]>:
            - if <[value].has_flag[hide_channel.staff]> && <player.has_permission[dscript.staffchat]>:
                - narrate "<proc[proc_format_name].context[<[value]>]> hides STAFF."
            - if <[value].has_flag[hide_channel.global]>:
                - narrate "<proc[proc_format_name].context[<[value]>]> hides GLOBAL."
            - if <[value].has_flag[hide_channel.advert]>:
                - narrate "<proc[proc_format_name].context[<[value]>]> hides ADVERT."
        - stop
    - define channel_choice <context.args.first>
    - inject channel_swap_cmd_task
    - narrate "<&[base]>Your channel is now <script[channel_config].parsed_key[colors.<player.flag[channel]||global>]><player.flag[channel]||global><&[base]>."

chat_notify_on_join:
    type: world
    debug: false
    events:
        after player joins:
        - if !<player.has_flag[chat_color]>:
            - flag player chat_color:<list[<&f>|<&color[#C4FFC2]>|<&color[#FFF5AA]>|<&color[#CCFFFE]>].random>
        - if <player.has_flag[hide_channel.global]>:
            - narrate "<&[base]>You are hiding GLOBAL chat.<n>To toggle global chat, type <&[warning]>/chat toggle global"
        - if <player.has_flag[hide_channel.staff]> && <player.has_permission[dscript.staffchat]>:
            - narrate "<&[base]>You are hiding STAFF chat.<n>To toggle staff chat, type <&[warning]>/chat toggle staff"

channel_swap_cmd_task:
    type: task
    debug: false
    definitions: channel_choice
    script:
    - if <[channel_choice].starts_with[g]>:
        - flag player channel:global
    - else if <[channel_choice].starts_with[a]>:
        - flag player channel:advert
    - else if <[channel_choice].starts_with[s]> && <player.has_permission[dscript.staffchat]>:
        - flag player channel:staff
    - else if <[channel_choice].starts_with[l]> || <[channel_choice].starts_with[r]> || <[channel_choice]> == me:
        - flag player channel:local
    - else if <[channel_choice].starts_with[w]>:
        - flag player channel:whisper
    - else if <[channel_choice].starts_with[m]>:
        - flag player channel:mutter
    - else if <[channel_choice].starts_with[e]> && <player.has_permission[dscript.eventchat]>:
        - flag player channel:event
    - else if <[channel_choice].starts_with[b]> && <player.has_permission[dscript.broadcastchat]>:
        - flag player channel:broadcast
    - else:
        - run chat_channel_show_task
        - stop

chat_tabcomplete_inject:
    type: task
    debug: false
    script:
    - define list <server.online_players.filter[has_flag[vanished].not].parse[name]>
    - if !<context.args.is_empty> && !<context.raw_args.ends_with[ ]>:
        - if <context.args.last.starts_with[:]>:
            - define list <script[emojify_proc].data_key[data].keys.parse_tag[:<[parse_value]>:]>
        - else if <context.args.last.starts_with[<&lb>]>:
            - if <context.args.last.starts_with[<&lb><&lb>ab]>:
                - define list <server.flag[abilities].keys.parse_tag[<&lb><&lb>ability:<[parse_value].unescaped><&rb><&rb>]||<list>>
            - else if <context.args.last.starts_with[<&lb><&lb>ch]>:
                - define list <proc[characters_list_proc].parse_tag[<&lb><&lb>character:<[parse_value]><&rb><&rb>]>
                - define list:|:<server.online_players.filter[has_flag[vanished].not].parse_tag[<&lb><&lb>character:<[parse_value].name><&rb><&rb>]>
            - else if <context.args.last.starts_with[<&lb><&lb>it]>:
                - define list <player.inventory.list_contents>
                - define list:|:<player.enderchest.list_contents>
                - define list <[list].filter[material.name.is[!=].to[air]]>
                - define displaynamelist <[list].filter[has_display].parse[display.strip_color.before[ ]]>
                - define list <[list].parse[material.name].include[<[displaynamelist]>].deduplicate.parse_tag[<&lb><&lb>item:<[parse_value].unescaped><&rb><&rb>]>
            - else:
                - define list <list[<&lb><&lb>item:].include[<&lb><&lb>helditem<&rb><&rb>].include[<&lb><&lb>character<&rb><&rb>].include[<&lb><&lb>character:].include[<&lb><&lb>ability:]>
    - determine <[list].filter[starts_with[<context.args.last||>]]>

quick_channel_command:
    type: command
    name: global
    debug: false
    usage: /global (message)
    description: Chats in another channel or swaps to it.
    permission: dscript.channel
    aliases:
    - g
    - a
    - ad
    - adv
    - advert
    - s
    - staff
    - l
    - local
    - e
    - event
    - b
    - broadcast
    - w
    - whisper
    - rp
    - mutter
    - me
    tab complete:
    - inject chat_tabcomplete_inject
    script:
    - define orig_channel <player.flag[channel]||global>
    - define channel_choice <context.alias>
    - inject channel_swap_cmd_task
    - if <context.args.is_empty>:
        - narrate "<&[base]>Your channel is now <script[channel_config].parsed_key[colors.<player.flag[channel]||global>]><player.flag[channel]||global><&[base]>."
        - stop
    - define message <context.raw_args>
    - if <[channel_choice]> == me:
        - define message <[message]>+
    - inject chat_handling_task
    - flag player channel:<[orig_channel]>

chat_channel_show_task:
    type: task
    debug: false
    script:
    - define channels <list[global|local|whisper|mutter|advert]>
    - if <player.has_permission[dscript.staffchat]>:
        - define channels:|:staff|event|broadcast
    - define channels <[channels].parse_tag[<script[channel_config].parsed_key[colors.<[parse_value]>]><[parse_value].on_click[/ch <[parse_value]>].on_hover[<&[emphasis]>Click to change channel to <script[channel_config].parsed_key[colors.<[parse_value]>]><[parse_value]>.]><&[emphasis]>]>
    - narrate "<&[emphasis]>Channels: <[channels].formatted>"
