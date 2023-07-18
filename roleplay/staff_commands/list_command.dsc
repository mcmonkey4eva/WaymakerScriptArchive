list_command:
    type: command
    debug: false
    name: list
    aliases:
    - online
    permission: dscript.list
    usage: /list
    description: Lists online players.
    script:
    - narrate "<&[base]>Currently online players (<&[emphasis]><server.online_players.size><&[base]>):<n><&[emphasis]><server.online_players.parse[proc[name_detailed_clearly_proc]].formatted>"

name_detailed_clearly_proc:
    type: procedure
    debug: false
    definitions: player
    script:
    - if <player.exists>:
        - define name <proc[proc_format_name].context[<[player]>|<player>]>
    - else:
        - define name "<&f><[player].name> (<[player].flag[current_character].proc[cc_name].context[<[player]>].if_null[<[player].flag[character_override]||NoCard>]>)"
    - determine <[name]><[player].has_flag[vanished].if_true[ <&7>(Vanished)].if_false[]><[player].has_flag[auto_afk_mark].if_true[ <&7>(AFK for <[player].flag[monitor_afk].from_now.formatted>)].if_false[]><&[base]>
