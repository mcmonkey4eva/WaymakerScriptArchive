
painting_command:
    type: command
    debug: false
    name: painting
    usage: /painting (art)
    description: Controls paintings.
    permission: dscript.painting
    tab completions:
        1: <server.art_types>
    script:
    - if <player.target[painting]||null> != null:
        - narrate "<&[base]>The painting you are facing is currently painted as <&[emphasis]><player.target[painting].painting><&[base]>."
    - if <context.args.is_empty>:
        - if <player.has_flag[painting_scroller]>:
            - flag player painting_scroller:!
            - narrate "<&[warning]>Painting scroller disabled."
        - else:
            - flag player painting_scroller
            - narrate "<&[base]>Painting scroller enabled."
            - narrate "<&[base]>Consider also just doing <&[warning]>/painting (art name)<&[base]> to instant-set to a specific painting."
        - stop
    - else:
        - if <player.target[painting]||null> == null:
            - narrate "<&[error]>You must face a painting to edit its art."
            - stop
        - define art <player.target[painting].painting>
        - if <context.args.first> == <[art]>:
            - narrate "<&[error]>That painting is already painted as that."
            - stop
        - adjust <player.target[painting]> painting:<context.args.first>
        - if <player.target[painting].painting> == <[art]>:
            - if !<server.art_types.contains[<context.args.first>]>:
                - narrate "<&[error]>Invalid painting art name."
            - else:
                - narrate "<&[error]>Art update failed - something went wrong."
            - stop
        - narrate "<&[base]>Repainted to <&[emphasis]><player.target[painting].painting><&[base]>."

painting_world:
    type: world
    debug: false
    events:
        on player scrolls their hotbar flagged:painting_scroller:
        - define painting <player.target[painting]||null>
        - if <[painting]> == null:
            - stop
        - define art <[painting].painting>
        - define orig_index <server.art_types.find[<[art]>]||1>
        - if <context.new_slot> == 1 && <context.previous_slot> == 9:
            - define new_index <[orig_index].mod[<server.art_types.size>].add[1]>
        - else if <context.new_slot> == 9 && <context.previous_slot> == 1:
            - define new_index <[orig_index].sub[1]>
        - else if <context.new_slot> > <context.previous_slot>:
            - define new_index <[orig_index].mod[<server.art_types.size>].add[1]>
        - else if <context.new_slot> < <context.previous_slot>:
            - define new_index <[orig_index].sub[1]>
        - else:
            - stop
        - if <[new_index]> == 0:
            - define new_index <server.art_types.size>
        - adjust <[painting]> painting:<server.art_types.get[<[new_index]>]>
