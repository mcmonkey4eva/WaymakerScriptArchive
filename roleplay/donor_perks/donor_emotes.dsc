cry_command:
    type: command
    debug: false
    name: cry
    description: Makes you cry.
    usage: /cry
    permission: dscript.basic_emote
    tab complete:
    - inject chat_tabcomplete_inject
    script:
    - define player <player>
    - define message <context.raw_args.proc[chat_embed_handler].proc[chat_emoji_handler]>
    - narrate <proc[chat_format_local_emote].context[<[player]>|cries <[message]>]> targets:<player.location.find_players_within[15]> per_player
    - if <player.has_permission[dscript.emote_fancy_effect]>:
        - repeat 100:
            - wait 1t
            - playeffect falling_water at:<player.eye_location.forward[0.3].left[0.1]>|<player.eye_location.forward[0.3].right[0.1]> offset:0
            - if <[value].mod[10]> == 0:
                - playsound <player.location> sound:entity_parrot_imitate_ghast pitch:0.5 volume:0.1

spit_command:
    type: command
    debug: false
    name: spit
    description: Makes you spit.
    usage: /spit
    permission: dscript.basic_emote
    tab complete:
    - inject chat_tabcomplete_inject
    script:
    - define player <player>
    - define message <context.raw_args.proc[chat_embed_handler].proc[chat_emoji_handler]>
    - narrate <proc[chat_format_local_emote].context[<[player]>|spits <[message]>]> targets:<player.location.find_players_within[15]> per_player
    - if <player.has_permission[dscript.emote_fancy_effect]>:
        - playsound <player.location> sound:ENTITY_LLAMA_SPIT volume:0.5
        - define players <player.location.find_players_within[30]>
        - fakespawn hologram_entity[custom_name=<&font[waymaker:particle]>-a-;velocity=<player.location.direction.vector.mul[0.4]>] <player.eye_location.below[0.6]> save:stand duration:100t players:<[players]>
        - define stand <entry[stand].faked_entity>
        - repeat 100:
            - adjust <[stand]> velocity:<[stand].velocity.below[0.02]>
            - adjust <[stand]> move:<[stand].velocity>
            - if <[stand].is_on_ground>:
                - playsound <[stand].location> sound:<list[block_bell_use|block_anvil_land|block_grass_break].random> pitch:2 volume:0.1
                - remove <[stand]>
                - stop
            - wait 1t

lick_command:
    type: command
    debug: false
    name: lick
    description: Makes you lick.
    usage: /lick (thing to lick)
    permission: dscript.basic_emote
    tab complete:
    - inject chat_tabcomplete_inject
    script:
    - define player <player>
    - define message <context.raw_args.proc[chat_embed_handler].proc[chat_emoji_handler]>
    - narrate <proc[chat_format_local_emote].context[<[player]>|licks <[message]>]> targets:<player.location.find_players_within[15]> per_player
    - if <player.has_permission[dscript.emote_fancy_effect]>:
        - define players <player.location.find_players_within[30]>
        - playsound <player.location> sound:entity_generic_drink

kiss_command:
    type: command
    debug: false
    name: kiss
    description: Makes you kiss.
    usage: /kiss (thing to kiss)
    permission: dscript.basic_emote
    tab complete:
    - inject chat_tabcomplete_inject
    script:
    - define player <player>
    - define message <context.raw_args.proc[chat_embed_handler].proc[chat_emoji_handler]>
    - narrate <proc[chat_format_local_emote].context[<[player]>|kisses <[message]>]> targets:<player.location.find_players_within[15]> per_player
    - if <player.has_permission[dscript.emote_fancy_effect]>:
        - playsound <player.location> sound:waymaker.emotes.kiss custom
        - run floaty_particle_task def.location:<player.eye_location.random_offset[0.2]> def.text:<&font[waymaker:particle]>-b-

floaty_particle_task:
    type: task
    debug: false
    definitions: location|text|targets
    script:
    - if !<[targets].exists>:
        - define targets <player.location.find_players_within[30]>
    - fakespawn hologram_entity[custom_name=<[text]>;velocity=0,0.03,0] <[location]> save:stand duration:50t players:<[targets]>
    - define stand <entry[stand].faked_entity>
    - repeat 50:
        - adjust <[stand]> move:<[stand].velocity>
        - wait 1t

punch_command:
    type: command
    debug: false
    name: punch
    description: Makes you punch.
    usage: /punch (thing to punch)
    permission: dscript.basic_emote
    tab complete:
    - inject chat_tabcomplete_inject
    script:
    - define player <player>
    - define message <context.raw_args.proc[chat_embed_handler].proc[chat_emoji_handler]>
    - narrate <proc[chat_format_local_emote].context[<[player]>|punches <[message]>]> targets:<player.location.find_players_within[15]> per_player
    - if <player.has_permission[dscript.emote_fancy_effect]>:
        - playsound <player.location> sound:ENTITY_PLAYER_ATTACK_KNOCKBACK pitch:0.8
        - repeat 5:
            - playeffect effect:crit at:<player.location.above[1.2].forward[<util.random.decimal[1.5].to[2.5]>]> offset:0.2 quantity:5
