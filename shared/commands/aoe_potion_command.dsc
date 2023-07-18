aoe_potion_command:
    type: command
    name: aoe_potion
    aliases:
    - aoepotion
    - potionaoe
    - potionarea
    - areapotion
    debug: false
    usage: /aoe_potion [potion] [range] (time) (amplifier)
    description: Applies a potion effect to everybody in a range.
    permission: dscript.aoe_potion
    tab completions:
        1: <server.potion_effect_types.parse[to_lowercase]>
        2: 1|5|10|15|50|100
        3: 1s|5s|10s|30s|1m|5m
        4: 0|1|2|3
    script:
    - if <context.args.size> < 2:
        - narrate "<&[error]>/aoe_potion [potion] [range] (time) (amplifier)"
        - narrate "<&[warning]>Default time: 30s, default amplifier: 0"
        - stop
    - if !<server.potion_effect_types.contains[<context.args.get[1]>]>:
        - narrate "<&[error]>That potion effect name is invalid."
        - stop
    - if !<context.args.get[2].is_integer> || <context.args.get[2]> < 0:
        - narrate "<&[error]>That range is not a valid integer number."
        - stop
    - define time 30s
    - if <context.args.size> > 2:
        - if !<duration[<context.args.get[3]>].exists>:
            - narrate "<&[error]>That duration is invalid."
            - stop
        - define time <duration[<context.args.get[3]>]>
    - define amplifier 0
    - if <context.args.size> > 3:
        - if !<context.args.get[4].is_integer>:
            - narrate "<&[error]>That amplifier is not a valid integer number."
            - stop
        - define amplifier <context.args.get[4]>
    - define targets <player.location.find_players_within[<context.args.get[2]>].exclude[<player>]>
    - cast <context.args.get[1]> <[targets]> duration:<[time]> amplifier:<[amplifier]>
    - narrate "<&[base]>Cast potion effect onto <&[emphasis]><element[<[targets].size> players].on_hover[<[targets].parse[name].separated_by[<n>]>]><&[base]>."
