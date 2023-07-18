never_leaf_decay_world:
    type: world
    debug: false
    events:
        on leaves decay:
        - determine passively cancelled
        - wait 1t
        - adjustblock <context.location> persistent:true
        - adjustblock <context.location> distance:7
        after player places *_leaves:
        - if <context.location> matches *_leaves && !<context.location.has_flag[custom_model_block]>:
            - adjustblock <context.location> persistent:true
            - adjustblock <context.location> distance:7
        after player breaks block location_flagged:custom_model_block:
        - if <context.location> matches air:
            - flag <context.location> custom_model_block:!
        after player right clicks block type:*_leaves:
        - if <context.location> matches *_leaves && !<context.location.has_flag[custom_model_block]>:
            - adjustblock <context.location> persistent:true
            - adjustblock <context.location> distance:7
        on block fades:
        - determine passively cancelled
        - if <context.location> matches *_leaves && !<context.location.has_flag[custom_model_block]>:
            - adjustblock <context.location> persistent:true
            - adjustblock <context.location> distance:7

leaf_fix_command:
    type: command
    debug: false
    name: leaffix
    usage: /leaffix
    description: Fixes leaf blocks.
    permission: dscript.leaffix
    script:
    - if !<player.has_flag[seltool_selection]>:
        - narrate "<&[error]>You must select an area with <&[warning]>/seltool <&[error]>before you can make it a property."
        - stop
    - define new_region <player.flag[seltool_selection]||null>
    - if <[new_region]> == null || ( <[new_region].object_type> == polygon && <[new_region].corners.size> < 3 ):
        - narrate "<&[error]>Your area selection is incomplete or invalid."
        - stop
    - define blocks <[new_region].blocks[*_leaves].filter[has_flag[custom_model_block].not]>
    - adjustblock <[blocks]> persistent:true
    - adjustblock <[blocks]> distance:7
    - narrate "<&[base]>Fixed <[blocks].size.custom_color[emphasis]> leaf blocks."
