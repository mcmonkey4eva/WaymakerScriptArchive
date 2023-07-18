block_explode_command:
    type: command
    name: block_explode
    aliases:
    - blockexplode
    - block_explosion
    - blockexplosion
    debug: false
    usage: /block_explode [size] [material matcher] [count] [speed]
    description: Makes an explosion with blocks going flying everywhere.
    permission: dscript.block_explode
    tab completions:
        1: 1|2|3|4|5
        2: <server.material_types.parse[name]>
        3: 3|5|10|15
        4: 1|1.5|2
    script:
    - if <context.args.size> < 4:
        - narrate "<&[error]>/block_explode [size] [material matcher] [count] [speed]"
        - narrate "<&[warning]>Size should be 1-5. Count is how many blocks should go flying (max 50). Speed should be a decimal number. Speed of 2 is very fast."
        - narrate "<&[warning]>For example: a tree exploding might be: <&[error]>/block_explode 3 *_log|*_leaves 15 0.5"
        - stop
    - define size <context.args.get[1]>
    - if !<[size].is_integer> || <[size]> < 1 || <[size]> > 5:
        - narrate "<&[error]>Size number invalid."
        - stop
    - define materials <server.material_types.filter[advanced_matches[<context.args.get[2]>]]>
    - if <[materials].is_empty>:
        - narrate "<&[error]>Invalid material matcher."
        - stop
    - define count <context.args.get[3]>
    - if !<[count].is_integer> || <[count]> < 1 || <[count]> > 50:
        - narrate "<&[error]>Count number is invalid."
        - stop
    - define speed <context.args.get[4]>
    - if !<[speed].is_decimal> || <[speed]> < 0.1 || <[speed]> > 3:
        - narrate "<&[error]>Speed decimal number is invalid."
        - stop
    - flag server explodesafe expire:1t
    - explode <player.location> power:<[size]>
    - flag server explodesafe:!
    - repeat <[count]>:
        - define shoot_type falling_block[fallingblock_hurt_entities=false;fallingblock_drop_item=false;fallingblock_type=<[materials].random>]
        - spawn <[shoot_type]> <player.eye_location.random_offset[1]> save:block
        - flag <entry[block].spawned_entity> block_no_form
        - adjust <entry[block].spawned_entity> velocity:<util.random.decimal[-<[speed]>].to[<[speed]>]>,<util.random.decimal[<[speed].div[2]>].to[<[speed].mul[2]>]>,<util.random.decimal[-<[speed]>].to[<[speed]>]>

block_explode_command_world:
    type: world
    debug: false
    events:
        on entity_flagged:block_no_form changes block:
        - determine cancelled
        on entity damaged server_flagged:explodesafe priority:-20:
        - determine cancelled
