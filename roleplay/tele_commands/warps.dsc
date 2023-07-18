warp_command:
    type: command
    debug: false
    name: warp
    usage: /warp [name]
    description: Warps to a named warp.
    permission: dscript.warp
    aliases:
    - warps
    tab completions:
        1: <server.flag[warps_system].filter_tag[<[filter_value].get[player_usable].or[<player.has_permission[dscript.staffwarp]>]>].keys.parse[unescaped].include[list]||list>
    script:
    - if !<player.has_flag[waymaker_verified]>:
        - narrate "<&[error]>You cannot use this command until you are verified."
    - if <context.args.is_empty>:
        - define categories <server.flag[warps_system].filter_tag[<[filter_value].get[player_usable].or[<player.has_permission[dscript.staffwarp]>]>].values.parse[get[category]].deduplicate||<list>>
        - narrate "<&[base]>Warp categories: <&[clickable]><[categories].parse_tag[<[parse_value].on_hover[Click to view category <[parse_value]>].on_click[/warp list <[parse_value]>]>].alphanumeric.separated_by[<&[base]>, <&[clickable]>]>"
        - stop
    - if <context.args.first> == list && <context.args.size> == 2:
        - define warps <server.flag[warps_system].filter_tag[<[filter_value].get[category].equals[<context.args.get[2]>]>].filter_tag[<[filter_value].get[player_usable].or[<player.has_permission[dscript.staffwarp]>]>].keys>
        - if <[warps].is_empty>:
            - narrate "<&[base]>No such warps currently available."
        - else:
            - narrate "<&[base]>Warps: <&[clickable]><[warps].alphanumeric.parse[unescaped].parse_tag[<[parse_value].on_hover[Click to warp to <[parse_value]>].on_click[/warp <[parse_value]>]>].separated_by[<&[base]>, <&[clickable]>]>"
        - stop
    - define warp <server.flag[warps_system.<context.args.first.escaped>]||null>
    - if <[warp]> == null || ( !<[warp].get[player_usable]> && !<player.has_permission[dscript.staffwarp]> ):
        - narrate "<&[error]>That warp doesn't exist."
        - stop
    - narrate "<&[base]>Warping to <&[emphasis]><context.args.first><&[base]>."
    - teleport <player> <[warp].get[location]>

setwarp_command:
    type: command
    debug: false
    name: setwarp
    usage: /setwarp [name] [category]
    description: Makes a new warp.
    permission: dscript.setwarp
    tab completions:
        1: <list>
        2: <server.flag[warps_system].values.parse[get[category]].deduplicate||<list>>
    script:
    - if <context.args.size> < 2:
        - narrate "<&[error]>/setwarp [name] [category]"
        - stop
    - define name <context.args.first.escaped>
    - if <[name]> == list:
        - narrate "<&[error]>Can't set a warp named 'list' that breaks stuff."
        - stop
    - if <server.has_flag[warps_system.<[name]>]>:
        - narrate "<&[error]>That warp already exists. Use <&[warning]>/delwarp [name]<&[error]> to remove it if you want to replace it."
        - stop
    - flag server warps_system.<[name]>.location:<player.location>
    - flag server warps_system.<[name]>.player_usable:false
    - flag server warps_system.<[name]>.category:<context.args.get[2]>
    - narrate "<&[base]>Created a new warp named <&[emphasis]><context.args.first><&[base]>."

delwarp_command:
    type: command
    debug: false
    name: delwarp
    usage: /delwarp [name]
    description: Deletes a warp.
    permission: dscript.setwarp
    tab completions:
        1: <server.flag[warps_system].keys.parse[unescaped]||<list>>
    script:
    - if <context.args.is_empty>:
        - narrate "<&[error]>/delwarp [name]"
        - stop
    - if !<server.has_flag[warps_system.<context.args.first.escaped>]>:
        - narrate "<&[error]>That warp doesn't exist."
        - stop
    - flag server warps_system.<context.args.first.escaped>:!
    - narrate "<&[base]>Deleted the warp named <&[emphasis]><context.args.first><&[base]>."

setplayerwarp_command:
    type: command
    debug: false
    name: setplayerwarp
    usage: /setplayerwarp [name]
    description: Makes a new player-accessible warp.
    permission: dscript.setplayerwarp
    script:
    - if <context.args.is_empty>:
        - narrate "<&[error]>/setplayerwarp [name]"
        - stop
    - define name <context.args.first.escaped>
    - if <[name]> == list:
        - narrate "<&[error]>Can't set a warp named 'list' that breaks stuff."
        - stop
    - if <server.has_flag[warps_system.<[name]>]>:
        - narrate "<&[error]>That warp already exists. Use <&[warning]>/delwarp [name]<&[error]> to remove it if you want to replace it."
        - stop
    - flag server warps_system.<[name]>.location:<player.location>
    - flag server warps_system.<[name]>.player_usable:true
    - flag server warps_system.<[name]>.category:Player
    - narrate "<&[base]>Created a new player-accessible warp named <&[emphasis]><context.args.first><&[base]>."

warpcategory_command:
    type: command
    debug: false
    name: warpcategory
    usage: /warpcategory [name] [category]
    description: Recategorizes a warp.
    permission: dscript.setwarp
    tab completions:
        1: <server.flag[warps_system].keys.parse[unescaped]||<list>>
        2: <server.flag[warps_system].values.parse[get[category]].deduplicate||<list>>
    script:
    - if <context.args.size> != 2:
        - narrate "<&[error]>/warpcategory [name] [category]"
        - stop
    - if !<server.has_flag[warps_system.<context.args.first.escaped>]>:
        - narrate "<&[error]>That warp doesn't exist."
        - stop
    - flag server warps_system.<context.args.first.escaped>.category:<context.args.get[2]>
    - narrate "<&[base]>Recategorized the warp named <&[emphasis]><context.args.first><&[base]>."

nearestwarp_command:
    type: command
    debug: false
    name: nearestwarp
    usage: /nearestwarp
    description: Tells you what warp is nearest to your location.
    permission: dscript.nearestwarp
    script:
    - define warp <server.flag[warps_system].filter_tag[<[filter_value].get[location].world.name.equals[<player.world.name>]>].parse_value_tag[<list_single[<[parse_key]>].include_single[<[parse_value].get[location]>]>].values.lowest[get[2].distance[<player.location>]]||null>
    - if <[warp]> == null:
        - narrate "<&[error]>No warps here."
        - stop
    - narrate "<&[base]>Nearest warp: <&[emphasis]><[warp].first> <&[base]>distance <&[emphasis]><[warp].get[2].distance[<player.location>].round><&[base]> blocks."
