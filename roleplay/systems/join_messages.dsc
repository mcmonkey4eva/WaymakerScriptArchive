join_messages_random:
    type: world
    debug: false
    data:
        wayxcalibur: example.com
        autopack: example.com
        autopack-hash: CE568BD7CAE71A1529557E64A805D32B1E45A8F0
        autopack-message: Hey! Welcome to Waymaker!<n>This automatic resource pack contains basic necessary content for our server to work.<n>It's not a texture pack. Our texture pack, Wayxcalibur, is a separate download.<n>You must enable the pack to join. If you have PC troubles that make autopacks break for you, ask on Discord for an autopack bypass.
    events:
        on player quits:
        - flag player resourcepack_sent:!
        after bungee player joins network:
        - define __player <player[<context.uuid>]>
        - announce to_console "<player.proc[proc_safe_name]> joined network"
        - waituntil rate:1t max:5s <player.is_online||false>
        - wait 1t
        - if !<player.is_online||false>:
            - announce to_console "join failed"
            - stop
        - flag player resourcepack_sent:!
        - resourcepack url:<script.parsed_key[data.autopack]> hash:<script.parsed_key[data.autopack-hash]> prompt:<script.parsed_key[data.autopack-message]> forced:<player.has_flag[autopack_bypass_allowed].not>
        - narrate "<n><n><n><&font[waymaker:waymaker]>A A A A A"
        - if !<player.has_flag[chat_color]> && <util.random.int[1].to[4]> == 2:
            - narrate "<&[base]>Did you know you can choose a unique chat color for yourself? Having a variety of chat colors makes it easier to read chat for many of our players! Pick your color:"
            - narrate "<element[<&f>/chat color 1].on_hover[Click me!].on_click[/chat color 1]> <element[<&color[#C4FFC2]>/chat color 2].on_hover[Click me!].on_click[/chat color 2]> <element[<&color[#FFF5AA]>/chat color 3].on_hover[Click me!].on_click[/chat color 3]> <element[<&color[#CCFFFE]>/chat color 4].on_hover[Click me!].on_click[/chat color 4]>"
        - else if <player.flag[last_voted].from_now.in_days||999> > 5 && <util.random.int[1].to[4]> == 2:
            - narrate "<&[base]>You can vote for Waymaker to get up to <&6>15 TG <&[base]>per day! Use <&[warning]>/vote"
        - else if !<player.has_flag[personal_name_color]> && !<player.has_flag[personal_name_color_tried]> && <util.random.int[1].to[4]> == 2:
            - narrate "<&[base]>Want to distinguish your own messages in chat? Try <element[<&[clickable]>/mycolor].on_click[/mycolor ].type[suggest_command].on_hover[Click Here!]> to set your own name color (only you see the color). It accepts any hex color code you like."
        - else if !<player.groups.contains_any[donator_one|donator_two|founder]> && <util.random.int[1].to[4]> == 2:
            - narrate "<&[base]>Donate to support the server at <&9>https://example.com/ <&[base]>and get some cool perks! (Make sure to link your Discord account when Tebex asks you!!)"
        - else if <player.client_brand> != fabric && <util.random.int[1].to[4]> == 2:
            - narrate "<&[base]>We have a recommended modpack, that improves performance and makes everything just a lil nicer, you can find it in our Discord, in the <&[emphasis]>#modpack<&[base]> channel."
        - else if <util.random.int[1].to[6]> == 2:
            - narrate "<&[base]>We recommend all players use our texture pack, <element[<&9>Wayxcalibur! Click here to download!].on_hover[Click me!].click_url[<script.parsed_key[data.wayxcalibur]>]>."
        - else:
            - narrate "<&[base]>Need help? Use <proc[clickable_cmd_proc].context[/help]>"
        - wait 10t
        - if !<player.has_flag[sent_wayxcalibur_notice]>:
            - flag player sent_wayxcalibur_notice
            - narrate "<&[base]>New in town? Make sure to download our texture pack, <element[<&9>Wayxcalibur! Click here!].on_hover[Click me!].click_url[<script.parsed_key[data.wayxcalibur]>]>"
        - if !<player.has_flag[ever_joined_before]>:
            - flag player ever_joined_before
            - define newperson <player>
            - narrate "<&[base]>A new face is seen stepping off the boat at the Aurum docks. Gather a welcoming party for <proc[proc_format_name].context[<[newperson]>|<player>]><&[base]>!" targets:<server.online_players> per_player
            - run discord_send_message def.channel:<server.flag[discord_chat_channel]> "def.message:] <&lt>@&123<&gt> <&lt>**`<player.name>`**<&gt> **JOINED** for the first time, and is in the spawn area. Please welcome them to Waymaker!"
        after resource pack status:
        - flag player resourcepack_sent
        - announce to_console "<player.name> gives resource pack status <context.status>"
        - if <context.status> == declined || <context.status> == failed_download || <context.status> == accepted:
            - run discord_send_message def.channel:<server.flag[discord_logs_channel]> "def.message:] <&lt>**`<player.name>`** (`<player.uuid>`)<&gt> **RESPONDS TO RESOURCE PACK** as `<context.status>`"
            - flag <player> resource_pack_last_status:<context.status>
            - if <context.status> == declined && !<player.has_flag[rp_decline_cooldown]>:
                - flag player rp_decline_cooldown expire:31d
                - narrate "<&[warning]>You've rejected the server's required resource pack.<n><&[warning]>If this is because you downloaded it separately, that's okay.<n><&[warning]>If you rejected it because you don't want it - don't worry, it's not a texture pack! It just adds features we use like new block types, chat features, etc. You're going to see a lot of little [] error squares and stuff if you don't have the pack. We do also recommend the Wayxcalibur texture pack, but that's separate."

autopack_bypass_grant_command:
    type: command
    debug: false
    name: grantautopackbypass
    aliases:
    - autopackgrantbypass
    - bypassautopackgrant
    description: Grants permission to a player to bypass the autopack.
    permission: dscript.grantautopackbypass
    usage: /grantautopackbypass [player]
    script:
    - if <context.args.is_empty>:
        - narrate "<&[error]>/grantautopackbypass [player]"
        - stop
    - define target <server.match_offline_player[<context.args.first>]>
    - if <[target].name> != <context.args.first>:
        - narrate "<&[error]>Did you mean <[target].name.custom_color[warning]>?"
        - stop
    - if <[target].has_flag[autopack_bypass_allowed]>:
        - narrate "<[target].proc[proc_format_name].context[<player>]><&[error]> already has autopack bypass permission."
        - stop
    - flag <[target]> autopack_bypass_allowed
    - narrate "<[target].proc[proc_format_name].context[<player>]><&[base]> has been allowed to bypass the autopack."

