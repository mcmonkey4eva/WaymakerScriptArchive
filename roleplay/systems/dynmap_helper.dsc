dynmap_helper:
    type: world
    debug: false
    events:
        after player joins:
        - if <player.has_flag[dynmap_hide]>:
            - narrate "<&[base]>You are currently hidden on dynmap. You can fix this via <&[clickable]><element[/dynmap show].on_click[/dynmap show]>"
        - run dynmap_should_hide_fix

dynmap_should_hide_fix:
    type: task
    debug: false
    script:
    - define should_hide false
    - if <player.has_flag[vanished]> || <player.has_flag[dynmap_hide]> || <player.gamemode> == spectator || <player.world.name> != danary || <player.has_flag[invisibility]>:
        - define should_hide true
    - if <[should_hide]> != <player.has_flag[dynmap_washidden]>:
        - if <[should_hide]>:
            - flag player dynmap_washidden
            - execute as_server "dynmap:dynmap hide <player.name>" silent
        - else:
            - flag player dynmap_washidden:!
            - execute as_server "dynmap:dynmap show <player.name>" silent

dynmap_command:
    type: command
    debug: false
    name: dynmap
    usage: /dynmap
    description: Shows the dynmap.
    aliases:
    - map
    tab completions:
        1: hide|show
    permission: dscript.dynmap
    script:
    - choose <context.args.first||help>:
        - case webregister:
            - if <player.has_permission[dscript.dynmap_webregister]>:
                - execute as_server "dynmap:dynmap webregister <player.name>"
        - case hide:
            - flag player dynmap_hide
            - narrate "<&[base]>You are now hidden on the map."
            - run dynmap_should_hide_fix
        - case show:
            - flag player dynmap_hide:!
            - narrate "<&[base]>You are now visible on the map."
            - run dynmap_should_hide_fix
        - default:
            - narrate "<&[base]>View the map: <&9><underline>https://dynmap.example.com"
            - narrate "<&[base]>You can also do <&[warning]>/dynmap hide <&[base]>and <&[warning]>/dynmap show <&[base]>to hide/show yourself on the map"
