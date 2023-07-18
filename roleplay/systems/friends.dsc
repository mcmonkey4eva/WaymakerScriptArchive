friends_command:
    type: command
    name: friends
    debug: false
    aliases:
    - friend
    - fr
    permission: dscript.friends
    usage: /friends [list/add/remove/accept/reject/pending]
    description: Manages your friends list.
    tab completions:
        1: list|add|remove|accept|reject|pending
        2: <server.online_players.filter[has_flag[vanished].not].parse[name]>
    script:
    - choose <context.args.first||help>:
        - case list:
            - define friends <player.flag[friends.current].keys.parse_tag[<proc[proc_format_name].context[<[parse_value]>|<player>]>].formatted||None.>
            - if <[friends].length> == 0:
                - define friends None.
            - narrate "<&[base]>Friends: <[friends]>"
        - case add:
            - define target <server.match_offline_player[<context.args.get[2]||null>]||null>
            - if <[target]> == null:
                - narrate "<&[error]>Unknown target player."
                - stop
            - if <player.has_flag[friends.current.<[target].uuid>]>:
                - narrate "<&[error]>You are already friends with that player."
                - stop
            - if <[target].has_flag[friends.pending.<player.uuid>]>:
                - narrate "<&[error]>You have already sent a friend request to that player."
                - stop
            - if <player.has_flag[friends.pending.<[target].uuid>]>:
                - narrate "<&[error]>You have a friend request waiting from that player. Use <&[warning]>/friend accept <[target].name>"
                - stop
            - flag <[target]> friends.pending.<player.uuid>:<util.time_now>
            - narrate "<&[base]>Sent a friend request to <proc[proc_format_name].context[<[target]>|<player>]>."
            - if <[target].is_online>:
                - narrate "<&[base]>New friend request from <proc[proc_format_name].context[<player>]>: <proc[friend_buttons_proc].context[<player>]>" targets:<[target]>
        - case remove:
            - define target <server.match_offline_player[<context.args.get[2]||null>]||null>
            - if <[target]> == null:
                - narrate "<&[error]>Unknown target player."
                - stop
            - if <[target].has_flag[friends.pending.<player.uuid>]>:
                - flag <[target]> friends.pending.<player.uuid>:!
                - narrate "<&[base]>Cancelled your friend request to <proc[proc_format_name].context[<[target]>|<player>]>."
                - stop
            - if <player.has_flag[friends.current.<[target].uuid>]>:
                - flag <[target]> friends.current.<player.uuid>:!
                - flag <player> friends.current.<[target].uuid>:!
                - narrate "<&[base]>Ended your friendship with <proc[proc_format_name].context[<[target]>|<player>]>."
                - narrate "<proc[proc_format_name].context[<player>|<[target]>]> is no longer your friend." targets:<[target]>
                - stop
            - if <[target].is_online>:
                - run name_suffix_character_card
                - run name_suffix_character_card player:<[target]>
            - narrate "<&[error]>You are not friends with that player."
            - stop
        - case accept:
            - define target <server.match_offline_player[<context.args.get[2]||null>]||null>
            - if <[target]> == null:
                - narrate "<&[error]>Unknown target player."
                - stop
            - if !<player.has_flag[friends.pending.<[target].uuid>]>:
                - narrate "<&[error]>No pending friend request from that player."
                - stop
            - flag <player> friends.pending.<[target].uuid>:!
            - narrate "<&[base]>Accepted friend request from <proc[proc_format_name].context[<[target]>|<player>]>."
            - if <[target].is_online>:
                - narrate "<&[base]>Your friend request to <proc[proc_format_name].context[<player>|<[target]>]> was accepted." targets:<[target]>
                - run name_suffix_character_card
                - run name_suffix_character_card player:<[target]>
            - flag <player> friends.current.<[target].uuid>
            - flag <[target]> friends.current.<player.uuid>
        - case reject:
            - define target <server.match_offline_player[<context.args.get[2]||null>]||null>
            - if <[target]> == null:
                - narrate "<&[error]>Unknown target player."
                - stop
            - if !<player.has_flag[friends.pending.<[target].uuid>]>:
                - narrate "<&[error]>No pending friend request from that player."
                - stop
            - flag <player> friends.pending.<[target].uuid>:!
            - narrate "<&[base]>Rejected friend request from <proc[proc_format_name].context[<[target]>|<player>]>."
            - if <[target].is_online>:
                - narrate "<&[base]>Your friend request to <proc[proc_format_name].context[<player>|<[target]>]> was rejected." targets:<[target]>
        - case pending:
            - if <player.flag[friends.pending].is_empty||true>:
                - narrate "<&[error]>No pending friend requests."
                - stop
            - foreach <player.flag[friends.pending]> key:pl as:time:
                - narrate "<&[base]>At <&[emphasis]><[time].format> <&[base]>from <proc[proc_format_name].context[<[pl]>|<player>]>: <proc[friend_buttons_proc].context[<player[<[pl]>]>]>"
        - default:
            - narrate "<&[error]>/friends list"
            - narrate "<&[error]>/friends pending"
            - narrate "<&[error]>/friends add [name]"
            - narrate "<&[error]>/friends remove [name]"
            - narrate "<&[error]>/friends accept [name]"
            - narrate "<&[error]>/friends reject [name]"

friend_buttons_proc:
    type: procedure
    debug: false
    definitions: player
    script:
    - determine "<&[clickable]><element[<&lb>Accept<&rb>].on_hover[Click to accept].on_click[/friends accept <[player].name>]><&[base]> or <&[clickable]><element[<&lb>Reject<&rb>].on_hover[Click to reject].on_click[/friends reject <[player].name>]>"

friends_world:
    type: world
    debug: false
    events:
        after player joins:
        - wait 2t
        - if !<player.flag[friends.pending].keys.is_empty||true>:
            - narrate "<&[base]>You have pending friend requests! Use <&[clickable]><element[/friends pending].on_hover[Click to show].on_click[/friends pending]><&[base]> to see."

join_leave_announce_world:
    type: world
    debug: false
    events:
        after bungee player joins network:
        - define __player <player[<context.uuid>]>
        - waituntil rate:1t max:10s <player.is_online||false>
        - if !<player.is_online||false>:
            - stop
        - if !<server.has_flag[bungee_player_backup.<context.uuid>]>:
            - stop
        - if !<player.has_flag[vanished]>:
            - if <player.has_flag[custom_join_message]> && <player.has_flag[can_use_customjoinleave]>:
                - define message <player.flag[custom_join_message]>
            - else:
                - define message null
            - bungeerun <bungee.list_servers> announce_joinleave def:<list_single[<[message]>].include[true]>
        on bungee player leaves network:
        - define __player <player[<context.uuid>]>
        - if !<server.has_flag[bungee_player_backup.<context.uuid>]>:
            - stop
        - if !<player.has_flag[vanished]> && <player.has_flag[did_join_rp_server]>:
            - if <player.has_flag[custom_leave_message]> && <player.has_flag[can_use_customjoinleave]>:
                - define message <player.flag[custom_leave_message]>
            - else:
                - define message null
            - bungeerun <bungee.list_servers> announce_joinleave def:<list_single[<[message]>].include[false]>
