
setdefaultnamecolor_command:
    type: command
    debug: false
    name: setdefaultnamecolor
    aliases:
    - defaultnamecolor
    usage: /setdefaultnamecolor [#hex]
    description: Changes the name color of default new players.
    permission: dscript.donor_setnamecolors
    tab completions:
        1: <context.args.first.if_null[].proc[color_tabcomplete_proc]>
    script:
    - inject set_color_command_prevalidate
    - if <[color]> == reset:
        - flag player altnamecolor.default:!
        - narrate "<&[base]>Default player name colors reset."
    - else:
        - flag player altnamecolor.default:<[color]>
        - narrate "<&color[<player.flag[altnamecolor.default]>]>Default player name colors set to this."

setfriendsnamecolor_command:
    type: command
    debug: false
    name: setfriendsnamecolor
    aliases:
    - friendsnamecolor
    usage: /setfriendsnamecolor [#hex]
    description: Changes the name color of friends.
    permission: dscript.donor_setnamecolors
    tab completions:
        1: <context.args.first.if_null[].proc[color_tabcomplete_proc]>
    script:
    - inject set_color_command_prevalidate
    - if <[color]> == reset:
        - flag player altnamecolor.friend:!
        - narrate "<&[base]>Friend name colors reset."
    - else:
        - flag player altnamecolor.friend:<[color]>
        - narrate "<&color[<player.flag[altnamecolor.friend]>]>Friend name colors set to this."

setplayersnamecolor_command:
    type: command
    debug: false
    name: setplayersnamecolor
    aliases:
    - playersnamecolor
    usage: /setplayersnamecolor [#hex] [player]
    description: Changes the name color of a specific player.
    permission: dscript.donor_setplayernamecolors
    tab completions:
        1: <context.args.first.if_null[].proc[color_tabcomplete_proc]>
        2: <server.online_players.filter[has_flag[vanished].not].parse[name]>
    script:
    - inject set_color_command_prevalidate
    - if <context.args.size> == 1:
        - narrate "<&[error]>Must specify a player to set the name color for."
        - stop
    - define target <server.match_offline_player[<context.args.get[2]>]||null>
    - if <[target]> == null:
        - narrate "<&[error]>Unknown target."
        - stop
    - if <[color]> == reset:
        - flag player altnamecolor.player.<[target].uuid>:!
        - narrate "<&[base]>Reset name color for <proc[proc_format_name].context[<[target]>|<player>]><&[base]>."
    - else:
        - flag player altnamecolor.player.<[target].uuid>:<[color]>
        - narrate "<&[base]>Set name color of <proc[proc_format_name].context[<[target]>|<player>]><&color[<player.flag[altnamecolor.player.<[target].uuid>]>]> to this."
