voting_world:
    type: world
    debug: false
    events:
        on votifier vote:
        - announce to_console "Votifier vote from <context.username> on <context.service>"
        - define player <server.match_offline_player[<context.username>]||null>
        - if <[player]> == null || <[player].name> != <context.username>:
            - announce to_console "Votifier vote treated as from nobody"
            - define message "] **VOTIFIER VOTE** from unknown user `<context.username.proc[discord_escape]>` ignored"
            - run discord_send_message def:<list[<server.flag[discord_logs_channel]>].include_single[<[message]>]>
            - stop
        - if <context.service||null> == null:
            - define message "] **VOTIFIER VOTE** from `<[player].name>` was sent with unknown service, ignoring"
            - run discord_send_message def:<list[<server.flag[discord_logs_channel]>].include_single[<[message]>]>
            - stop
        - if <[player].has_flag[vote_history.<context.service.escaped>]>:
            - define message "] **VOTIFIER VOTE** from `<[player].name>` on service ` <context.service.proc[discord_escape]>` was repeated too quickly (`<player.flag[vote_history.<context.service.escaped>].from_now.formatted||?>`), ignoring"
            - run discord_send_message def:<list[<server.flag[discord_logs_channel]>].include_single[<[message]>]>
            - stop
        - if <[player].flag[vote_history].keys.size||0> > 4:
            - define message "] **VOTIFIER VOTE** from `<[player].name>` ignored due to already voting 5 times today"
            - run discord_send_message def:<list[<server.flag[discord_logs_channel]>].include_single[<[message]>]>
            - stop
        - flag <[player]> vote_history.<context.service.escaped>:<util.time_now> duration:20h
        - flag <[player]> last_voted:<util.time_now>
        - define vote_value 3
        - define message "] **VOTIFIER VOTE** from `<[player].name>` on service `<context.service>` accepted"
        - run discord_send_message def:<list[<server.flag[discord_logs_channel]>].include_single[<[message]>]>
        - flag <[player]> pending_vote_reward:+:<[vote_value]>
        - if <[player].is_online>:
            - narrate "<&[base]>Thank you for voting for Waymaker! You may claim your voting reward with <element[/claimvotereward].custom_color[clickable].on_click[/claimvotereward]>." targets:<[player]>

vote_command:
    type: command
    debug: false
    name: vote
    usage: /vote
    description: Shows voting links.
    permission: dscript.vote
    script:
    - narrate "<&[base]>You can vote for us on server list websites to get <&6>3 TG <&[base]>per vote, up to <&6>15 TG <&[base]>per day!"
    - narrate "<&[base]>Vote for us on [some site]"
    - narrate "<&[base]>Also vote on [some site]"
    - if <player.has_flag[last_voted]> && <player.flag[last_voted].from_now.in_hours> < 20:
        - narrate "<&[base]>You last voted <&[emphasis]><player.flag[last_voted].from_now.formatted><&[base]> ago. You can vote once on each website every 24 hours."
    - else:
        - narrate "<&[base]>You can vote once every 24 hours. You haven't voted yet today."

claimvotereward:
    type: command
    debug: false
    name: claimvotereward
    usage: /claimvotereward
    description: If you received a voting reward, use this command to claim it.
    permission: dscript.vote
    script:
    - if !<player.has_flag[pending_vote_reward]>:
        - narrate "<&[error]>You have no voting reward pending."
        - stop
    - if <player.flag[character_mode]> != ic:
        - narrate "<&[error]>You must be IC to take voting rewards."
        - stop
    - money give quantity:<player.flag[pending_vote_reward]>
    - run eco_log_gain def.amount:<player.flag[pending_vote_reward]> "def.reason:claimed voting reward"
    - narrate "<&[base]>You received <&6><player.flag[pending_vote_reward]> TG<&[base]> as a reward for voting for Waymaker."
    - flag player pending_vote_reward:!
