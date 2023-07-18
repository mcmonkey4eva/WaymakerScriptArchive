refer_command:
    type: command
    debug: false
    name: refer
    permission: dscript.refer
    usage: /refer [name]
    description: Refers a new player.
    script:
    - if <context.args.is_empty>:
        - narrate "<&[error]>/refer [name] <&[warning]>- input the exact minecraft name of a player you invited to Waymaker. Make sure to avoid typos!"
        - stop
    - if <context.args.first> == internal_respond_yes && <player.has_flag[possible_referral]>:
        - define referrer <player.flag[possible_referral]>
        - flag player possible_referral:!
        - flag player referred_by:<[referrer]>
        - flag player refer_waiting:0 expire:90d
        - narrate "<&[base]>Referral confirmed. Thank you!"
        - define message "] <&lt>**`<player.name>`**<&gt> **CONFIRMED REFERRAL CLAIM** from **`<[referrer].name>`**."
        - run discord_send_message def:<list[<server.flag[discord_slowlog_channel]>].include_single[<[message]>]>
        - stop
    - else if <context.args.first> == internal_respond_no && <player.has_flag[possible_referral]>:
        - define referrer <player.flag[possible_referral]>
        - flag player possible_referral:!
        - narrate "<&[base]>Referral denied. Thank you!"
        - define message "] <&lt>**`<player.name>`**<&gt> **DENIED REFERRAL CLAIM** from **`<[referrer].name>`**. Possible referral abuse?"
        - run discord_send_message def:<list[<server.flag[discord_slowlog_channel]>].include_single[<[message]>]>
        - stop
    - if <player.flag[referrals].keys.size||0> > 20:
        - define first <player.flag[referrals].keys.get[1]>
        - define first_name <player.flag[referrals].values.get[1]>
        - flag player referrals.<[first]>:!
        - flag server referrals.<[first]>:!
        - narrate "<&[warning]>You are trying to refer too many players that haven't actually joined. Your oldest referral, for <&[emphasis]><[first_name]><&[warning]> has been automatically dropped."
    - if <context.args.first> != <context.args.first.escaped> || <context.args.first.length> < 3 || <context.args.first.length> > 16:
        - narrate "<&[warning]>That input doesn't look like a real player-name."
        - stop
    - if <server.match_offline_player[<context.args.first>].name||-null-> == <context.args.first>:
        - narrate "<&[warning]>That player is already on the server."
        - stop
    - ~webget https://api.mojang.com/users/profiles/minecraft/<context.args.first> save:lookup
    - if <entry[lookup].failed> || <entry[lookup].status> != 200:
        - narrate "<&[warning]>That name doesn't correspond to a valid minecraft account."
        - stop
    - define id <util.parse_yaml[<entry[lookup].result>].get[id].proc[proc_fix_id]>
    - if <server.has_flag[referrals.<[id]>]>:
        - narrate "<&[warning]>That player has already been referred."
        - stop
    - if <player[<[id]>].name> != null:
        - narrate "<&[warning]>That player is already on the server."
        - stop
    - flag player referrals.<[id]>:<context.args.first>
    - flag server referrals.<[id]>:<player>
    - narrate "<&[base]>Recorded your referral for <&[emphasis]><context.args.first><&[base]>. You will be rewarded if they join and roleplay on Waymaker."

proc_fix_id:
    type: procedure
    debug: false
    definitions: id
    script:
    - define id <[id].replace[-]>
    - determine <[id].substring[1,8]>-<[id].substring[9,12]>-<[id].substring[13,16]>-<[id].substring[17,20]>-<[id].substring[21]>

refer_world:
    type: world
    debug: false
    events:
        after player joins:
        - if <player.has_flag[pending_refer_reward]>:
            - narrate "<&[base]>You have pending a referral reward! You may claim it with <element[/claimreferreward].custom_color[clickable].on_click[/claimreferreward]>."
        - if <player.has_flag[refer_notice]>:
            - foreach <player.flag[refer_notice]> as:referred:
                - narrate "<&[base]>You received <&6><script[refer_complete].data_key[data.referrer_amt]> TG <&[base]>for referring user <proc[proc_format_name].context[<[referred]>|<player>]> <&[base]>to Waymaker! You may claim it with <element[/claimreferreward].custom_color[warning].on_click[/claimreferreward]>."
            - flag player refer_notice:!
        - if !<player.has_flag[referral_seen]>:
            - flag player referral_seen
            - define referrer <server.flag[referrals.<player.uuid>]||null>
            - if <[referrer]> == null:
                - define message "] <&lt>**`<player.name>`**<&gt> **JOINED** for the first time - no referrer tracked."
                - run discord_send_message def:<list[<server.flag[discord_slowlog_channel]>].include_single[<[message]>]>
                - stop
            - define message "] <&lt>**`<player.name>`**<&gt> **JOINED** for the first time - referred by **`<[referrer].name>`**"
            - run discord_send_message def:<list[<server.flag[discord_slowlog_channel]>].include_single[<[message]>]>
            - flag player possible_referral:<[referrer]>
            - flag <[referrer]> referrals.<player.uuid>:!
        - if <player.has_flag[possible_referral]>:
            - define referrer <player.flag[possible_referral]>
            - narrate "<&[base]>The player <proc[proc_format_name].context[<[referrer]>|<player>]> <&[base]>claims that they referred you to Waymaker. Is this true? <element[<&lb>Yes<&rb>].custom_color[clickable].on_click[/refer internal_respond_yes].on_hover[Click to confirm that user referred you]> <element[<&lb>No<&rb>].custom_color[clickable].on_click[/refer internal_respond_no].on_hover[Click to deny that user referred you]>"

refer_complete:
    type: task
    debug: false
    data:
        new_user_amt: 50
        referrer_amt: 100
    script:
    - if !<player.has_flag[refer_waiting]>:
        - stop
    - flag player refer_waiting:!
    - define referrer <player.flag[referred_by]>
    - flag <player> pending_refer_reward:+:<script.data_key[data.new_user_amt]>
    - narrate "<&[base]>You are rewarded <&6><script.data_key[data.new_user_amt]> TG <&[base]>for being active on Waymaker after being referred by <proc[proc_format_name].context[<[referrer]>|<player>]>. You may claim it with <element[/claimreferreward].custom_color[clickable].on_click[/claimreferreward]>."
    - flag <[referrer]> pending_refer_reward:+:<script.data_key[data.referrer_amt]>
    - if <[referrer].is_online>:
        - narrate "<&[base]>You received <&6><script.data_key[data.referrer_amt]> TG <&[base]>for referring user <proc[proc_format_name].context[<player>|<[referrer]>]> <&[base]>to Waymaker! You may claim it with <element[/claimreferreward].custom_color[clickable].on_click[/claimreferreward]>." targets:<[referrer]>
    - else:
        - flag <[referrer]> refer_notice:->:<player>

claimreferreward:
    type: command
    debug: false
    name: claimreferreward
    usage: /claimreferreward
    description: If you received a referral reward, use this command to claim it.
    permission: dscript.refer
    script:
    - if !<player.has_flag[pending_refer_reward]>:
        - narrate "<&[error]>You have no refer reward pending."
        - stop
    - if <player.flag[character_mode]> != ic:
        - narrate "<&[error]>You must be IC to take referral rewards."
        - stop
    - money give quantity:<player.flag[pending_refer_reward]>
    - run eco_log_gain def.amount:<player.flag[pending_refer_reward]> "def.reason:claimed referral reward"
    - narrate "<&[base]>You received <&6><player.flag[pending_refer_reward]> TG<&[base]> as a reward for using the referral system."
    - flag player pending_refer_reward:!
