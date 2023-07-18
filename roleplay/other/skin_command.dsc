skin_command:
    type: command
    debug: false
    permission: dscript.skin
    name: skin
    usage: /skin [reset/name/uuid/link] (player)
    description: Sets your skin to a different skin.
    script:
    - if <context.args.is_empty>:
        - narrate "<&[error]>/skin [name/uuid/link] (player)"
        - narrate "<&[warning]>Or <&[error]>/skin reset <&[warning]>to switch back to your own skin."
        - stop
    - define target <player>
    - if <context.args.size> == 2:
        - define target <server.match_player[<context.args.get[2]>]||null>
        - if <[target]> == null:
            - narrate "<&[error]>Unknown player '<&[emphasis]><context.args.get[2]><&[error]>'."
            - stop
    - ratelimit <player><[target]> 1s
    - define arg <context.args.first>
    - inject skin_command_process
    - flag <[target]> custom_skin:<[target].skin_blob>

skin_command_process:
    type: task
    debug: false
    definitions: target|arg
    script:
    - if <[arg]> == reset:
        - flag <[target]> custom_skin:!
        - adjust <[target]> skin:<[target].name>
        - run skin_autopatch_task player:<[target]>
        - narrate "<&[base]>Skin reset."
        - stop
    - if <[arg].starts_with[https://]>:
        - if !<[arg].ends_with[.png]> && !<[arg].starts_with[https://minesk]>:
            - narrate "<&[error]>That URL isn't likely to be valid. Make sure you have a direct image URL, ending with '.png'."
        - narrate "<&[base]>Retrieving the requested skin..."
        - run skin_url_task def:<[arg]> save:newQueue
        - while <entry[newQueue].created_queue.state> == running:
            - if <[loop_index]> > 100:
                - queue <entry[newQueue].created_queue> stop
                - narrate "<&[error]>The request timed out. Is the url valid?"
                - stop
            - wait 5t
        - if <entry[newQueue].created_queue.determination.first||null> == null:
            - narrate "<&[error]>Failed to retrieve the skin from the provided link. Is the url valid?"
            - stop
        - define yamlid <player.uuid>_skin_from_url
        - yaml loadtext:<entry[newQueue].created_queue.determination.first> id:<[yamlid]>
        - if !<yaml[<[yamlid]>].contains[data.texture]>:
            - narrate "<&[error]>An unexpected error occurred while retrieving the skin data. Perhaps try again?"
            - yaml unload id:<[yamlid]>
            - stop
        - else:
            - define skin_blob <yaml[<[yamlid]>].read[data.texture.value]>;<yaml[<[yamlid]>].read[data.texture.signature]>
            - adjust <[target]> skin_blob:<[skin_blob]>
            - run skin_autopatch_task player:<[target]>
            - narrate "<&[base]>Set skin for <proc[proc_format_name].context[<[target]>|<player>]> to <&[emphasis]><[arg]><&[base]>."
            - yaml unload id:<[yamlid]>
    - else:
        - if <[arg].length> > 16 || <[arg].length> < 3:
            - narrate "<&[error]>That skin name is not valid."
            - stop
        - define pre_blob:<[target].skin_blob>
        - adjust <[target]> skin:<[arg]>
        - run skin_autopatch_task player:<[target]>
        - if <[target].skin_blob> == <[pre_blob]>:
            - narrate "<&[base]>Skin unchanged."
            - stop
        - run skin_autopatch_task player:<[target]>
        - narrate "<&[base]>Set skin for <proc[proc_format_name].context[<[target]>|<player>]> to <&[emphasis]><[arg]><&[base]>."

skin_updater_world:
    type: world
    debug: false
    events:
        after bungee player switches to server:
        - define __player <player[<context.uuid>]||null>
        - wait 5t
        - if !<player.is_online||false>:
            - stop
        - flag <player> bungee_swapped expire:3s
        after player joins:
        - wait 1t
        - waituntil <player.has_flag[resourcepack_sent]> || <player.has_flag[bungee_swapped]> || !<player.is_online> rate:5t max:2m
        - if !<player.is_online>:
            - stop
        - if <player.has_flag[custom_skin]>:
            - adjust <player> skin_blob:<player.flag[custom_skin]>
            - run skin_autopatch_task

skin_url_task:
    type: task
    debug: false
    definitions: url
    script:
    - ~webget https://api.mineskin.org/generate/url post:url=<[url]> timeout:25s save:webResult
    - determine <entry[webResult].result||null>
