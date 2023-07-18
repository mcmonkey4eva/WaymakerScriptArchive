
donor_playsound_command:
    type: command
    debug: false
    name: noise
    aliases:
    - makenoise
    - playnoise
    description: Plays an animal noise.
    usage: /noise [noise]
    permission: dscript.donor_playsound
    tab completions:
        1: <proc[donor_noises_allowed_proc]>
    script:
    - if <context.args.is_empty>:
        - narrate "<&[error]>/noise [noise] <&[warning]>- use tab completions to pick a noise. 5 minute usage cooldown."
        - stop
    - if !<proc[donor_noises_allowed_proc].contains[<context.args.first>]>:
        - narrate "<&[error]>Unknown noise name."
        - stop
    - if <player.has_flag[donor_playsound_cooldown]>:
        - narrate "<&[error]>You must wait <&[emphasis]><player.flag_expiration[donor_playsound_cooldown].from_now.formatted><&[error]> before you can make another noise."
        - stop
    - flag player donor_playsound_cooldown duration:5m
    - playsound <player.location> sound:entity_<context.args.first> volume:1

donor_noises_allowed_proc:
    type: procedure
    debug: false
    data:
        exclusions: arrow|tnt|dragon|player|leash|item_|lightning|potion|explod|armor_stand|experience|firework|bobber|boat|minecart|painting|generic|creeper
    script:
    - determine <server.sound_types.parse[to_lowercase].filter[starts_with[entity_]].parse[after[entity_]].filter[contains_any_text[<script.data_key[data.exclusions]>].not]>
