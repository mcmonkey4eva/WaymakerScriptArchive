noclip_command:
    type: command
    debug: false
    name: noclip
    usage: /noclip
    description: Gives you noclip.
    permission: dscript.noclip
    script:
    - define target <player>
    - if !<context.args.is_empty>:
        - define target <server.match_offline_player[<context.args.first>]||null>
        - if <[target]> == null:
            - narrate "<&[error]>Unknown player '<&[emphasis]><context.args.first><&[error]>'."
            - stop
    - if <[target].has_flag[noclip]>:
        - flag <[target]> noclip:!
        - adjust <[target]> noclip:false
        - showfake cancel <[target].location.find_blocks.within[5]> players:<[target]>
        - narrate "<&[base]>Noclip disabled."
    - else:
        - flag <[target]> noclip
        - adjust <[target]> noclip:true
        - narrate "<&[base]>Noclip enabled."

noclip_world:
    type: world
    debug: false
    events:
        on player steps on block flagged:noclip:
        - define second_blocks <context.new_location.sub[2,0,2].to_cuboid[<context.new_location.add[2,3,2]>].blocks>
        - define reset_blocks <context.previous_location.find_blocks.within[5].exclude[<[second_blocks]>]>
        - showfake cancel <[reset_blocks]>
        - showfake air <[second_blocks]>
