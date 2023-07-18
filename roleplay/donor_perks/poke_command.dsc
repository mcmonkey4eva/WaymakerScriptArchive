poke_command:
    type: command
    debug: false
    name: poke
    description: Pokes a player. Limited range.
    usage: /poke [player]
    permission: dscript.poke
    script:
    - if <context.args.is_empty>:
        - narrate "<&[error]>/poke [player] <&[warning]>- poke player, by name, with limited range"
        - stop
    - define target <server.match_player[<context.args.first>]||null>
    - if <[target]> == null:
        - narrate "<&[error]>Unknown target."
        - stop
    - if <player.location.distance[<[target].location>]||999> > 8:
        - narrate "<&[error]>Out of range."
        - stop
    - ratelimit <player>_<[target]> 0.5s
    - actionbar targets:<[target]> "<&[emphasis]><player.name><&[base]> pokes you!"
    - actionbar targets:<player> "<&[base]>You poke <&[emphasis]><[target].name><&[base]>!"
    - announce to_console "[Poke] <player.name> pokes <[target].name>"
    - if <player.has_permission[dscript.special_poke]>:
        - playsound sound:ENTITY_PLAYER_LEVELUP <[target]>|<player> volume:0.5
        - playeffect at:<player.location.points_between[<[target].location>]> effect:VILLAGER_HAPPY
        - ratelimit <player>_<[target]> 5s
        - toast "<&[emphasis]><player.name><&[base]> pokes you!" targets:<[target]> frame:goal icon:player_head[skull_skin=<player.skull_skin>]
