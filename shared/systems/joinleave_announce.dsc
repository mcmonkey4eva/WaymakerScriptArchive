
all_joins_command:
    type: command
    debug: false
    name: alljoins
    aliases:
    - showalljoins
    - allquits
    - showallquits
    usage: /alljoins
    description: Toggles seeing all join messages.
    script:
    - if <player.has_flag[all_joins]>:
        - flag player all_joins:!
        - narrate "<&[base]>Stopped showing all join/quit messages."
    - else:
        - flag player all_joins
        - narrate "<&[base]>Now showing all join/quit messages."

announce_joinleave:
    type: task
    debug: false
    definitions: message|join
    script:
    - announce to_console "Bungee relay announce: <player.name||Unknown> <[join].if_true[joins].if_false[leaves]>"
    - define targets <server.online_players.filter[has_flag[all_joins]].include[<player>].include[<server.online_players.filter[has_flag[friends.current.<player.uuid>]]>].deduplicate>
    - define player <player>
    - if <[join]>:
        - if <[message]||null> == null:
            - narrate "<&[emphasis]><proc[proc_format_name].context[<[player]>|<player>|true]> <&[base]>joined." targets:<[targets]> per_player
        - else:
            - narrate <&[base]><[message].replace[<&lb>name<&rb>].with[<&[emphasis]><proc[proc_format_name].context[<[player]>|<player>|true]>].on_hover[(Custom Join Message) <[player].proc[proc_safe_name]> joined the server]> targets:<[targets]> per_player
    - else:
        - if <[message]||null> == null:
            - narrate "<&[emphasis]><proc[proc_format_name].context[<[player]>|<player>|true]> <&[base]>logged off." targets:<[targets]> per_player
        - else:
            - narrate <&[base]><[message].replace[<&lb>name<&rb>].with[<&[emphasis]><proc[proc_format_name].context[<[player]>|<player>|true]>].on_hover[(Custom Leave Message) <[player].proc[proc_safe_name]> logged off]> targets:<[targets]> per_player
