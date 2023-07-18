
abilities_command:
    type: command
    debug: false
    name: abilities
    aliases:
    - spells
    description: Manages the global list of known embeddable abilities/spells.
    usage: /abilities
    permission: dscript.abilities_manage
    tab completions:
        1: new|delete|list|description|name
        2: <server.flag[abilities].keys.parse[unescaped]||<list>>
    script:
    - choose <context.args.first||help>:
        - case new create:
            - if <context.args.size> < 2:
                - narrate "<&[error]>/abilities new [id]"
                - stop
            - define ability <context.args.get[2].to[last].separated_by[_].parse_color.strip_color.escaped>
            - if <server.has_flag[abilities.<[ability]>]>:
                - narrate "<&[error]>Ability name given already exists."
                - stop
            - define clean_name <context.args.get[2].to[last].space_separated.parse_color>
            - flag server abilities.<[ability]>:<map.with[name].as[<[clean_name]>].with[description].as[<list_single[<&f><&lb><[clean_name]><&f><&rb>]>]>
            - narrate "<&[base]>Ability created."
        - case name rename:
            - if <context.args.size> < 3:
                - narrate "<&[error]>/abilities name [id] [name]"
                - stop
            - define ability <context.args.get[2].escaped>
            - if !<server.has_flag[abilities.<[ability]>]>:
                - narrate "<&[error]>Unknown ability id given."
                - stop
            - define new_name <context.raw_args.after[ ].after[ ].parse_color>
            - flag server abilities.<[ability]>.name:<[new_name]>
            - narrate "<&[base]>Ability renamed."
        - case delete remove:
            - if <context.args.size> < 2:
                - narrate "<&[error]>/abilities delete [id]"
                - stop
            - define ability <context.args.get[2].escaped>
            - if !<server.has_flag[abilities.<[ability]>]>:
                - narrate "<&[error]>Unknown ability id given."
                - stop
            - flag server abilities.<[ability]>:!
            - narrate "<&[base]>Ability deleted."
        - case description d desc:
            - if <context.args.size> < 3:
                - narrate "<&[error]>/abilities description [id] [line] [text]"
                - narrate "<&[base]>Or, <&[error]>/abilities description [id] clear"
                - narrate "<&[base]>Or, <&[error]>/abilities description [id] remove [line]"
                - stop
            - define ability <context.args.get[2].escaped>
            - if !<server.has_flag[abilities.<[ability]>]>:
                - narrate "<&[error]>Unknown ability id given."
                - stop
            - define description <list[<server.flag[abilities.<[ability]>.description]||<list>>]>
            - run multi_line_edit_tool def.args:<context.args.get[3].to[last]> def.orig_lines:<[description]> "def.cmd_prefix:/abilities description [id]" def.wrap_len:240 def.raw_args:<context.raw_args.after[ ].after[ ].parse_color> def.def_color:<&f> save:edited
            - define description <entry[edited].created_queue.determination.first>
            - flag server abilities.<[ability]>.description:<[description]>
        - case list:
            - narrate "<&[base]>Current abilities available: <&[emphasis]><server.flag[abilities].keys.alphabetical.parse[proc[embedder_for_ability]].formatted||None>"
        - default:
            - narrate "<&[error]>/abilities new [id]"
            - narrate "<&[error]>/abilities delete [id]"
            - narrate "<&[error]>/abilities name [id] [name]"
            - narrate "<&[error]>/abilities description [id] [line] [text]"
            - narrate "<&[error]>/abilities list"

embedder_for_ability:
    type: procedure
    debug: false
    definitions: ability
    script:
    - define ability_data <server.flag[abilities.<[ability]>]>
    - determine [<[ability_data].get[name].on_hover[<[ability_data].get[description].separated_by[<n>]>]>]
