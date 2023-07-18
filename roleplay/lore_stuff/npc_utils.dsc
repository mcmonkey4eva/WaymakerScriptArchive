player_forcespeak_near:
    type: task
    debug: false
    definitions: message
    script:
    - define player <player>
    - if <player.flag[character_mode]> == ic:
        - narrate "<proc[proc_name_format_local].context[<[player]>]> says to an NPC<&co> <[player].flag[chat_color]||<&f>><[message]>" targets:<npc.location.find_players_within[10]> per_player
    - else:
        - narrate "<&color[#777777]>[OOC-<&gt>NPC] <player.flag[nickname]||<player.name>><&color[#777777]><&co> <[message]>" targets:<npc.location.find_players_within[10]>

npc_speak_near:
    type: task
    debug: false
    definitions: message
    script:
    - narrate "<&b>[<npc.name.strip_color>] <&f><[message]>" targets:<npc.location.find_players_within[10]>

npc_emote:
    type: task
    debug: false
    definitions: message
    script:
    - narrate <&[way_emote]>[<[message]>] targets:<npc.location.find_players_within[10]>
