whereis_command:
    type: command
    debug: false
    name: whereis
    description: Shows you where a thing is.
    usage: /whereis [place or player]
    permission: dscript.whereis
    script:
    - define target <server.match_offline_player[<context.args.first>].location||null>
    - if <[target]> == null:
        - narrate "<&[error]>Unknown player '<&[emphasis]><context.args.first><&[error]>'."
        - stop
    - if <[target].world.name> != <player.world.name>:
        - narrate "<&[error]>Sorry mario, your target is in another world."
        - stop
    - define start <player.eye_location.with_pitch[0].forward[2]>
    - define vector <[target].sub[<[start]>].normalize>
    - repeat 20:
        - playeffect flame offset:0 quantity:1 at:<[start].add[<[vector].mul[<[value]>].div[7]>]> targets:<player>
        - if <[value].mod[3]> == 0:
            - wait 1t
    - define end <[start].add[<[vector].mul[20].div[7]>]>
    - define back_vec1 <[vector].rotate_around_y[<element[140].to_radians>].with_y[<[vector].y.mul[-1]>]>
    - define back_vec2 <[vector].rotate_around_y[<element[220].to_radians>].with_y[<[vector].y.mul[-1]>]>
    - playeffect flame offset:0 quantity:1 at:<util.list_numbers_to[7].parse_tag[<[end].add[<[back_vec1].mul[<[parse_value]>].div[7]>]>]> targets:<player>
    - playeffect flame offset:0 quantity:1 at:<util.list_numbers_to[7].parse_tag[<[end].add[<[back_vec2].mul[<[parse_value]>].div[7]>]>]> targets:<player>
