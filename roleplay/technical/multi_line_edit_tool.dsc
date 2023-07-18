

multi_line_edit_tool:
    type: task
    definitions: args|orig_lines|cmd_prefix|wrap_len|raw_args|def_color
    debug: false
    script:
    - if <[args].get[1]||null> == clear:
        - narrate "<&[base]>Text cleared."
        - determine <list>
    - else if <[args].get[1]||null> == insert && <[args].get[2].is_integer||false>:
        - if <[args].size> < 3:
            - narrate "<&[error]><[cmd_prefix]> insert [line] [text] <&[warning]>- to insert text at a specific index (automatically line-wrapping)"
            - determine <[orig_lines]>
        - define text <[raw_args].after[ ].after[ ].split_lines_by_width[<[wrap_len]>].lines_to_colored_list.parse_tag[<[def_color]><[parse_value]>]>
        - if <[args].get[2]> > <[orig_lines].size>:
            - define orig_lines <[orig_lines].include[<[text].parse[proc[chat_embed_handler].proc[chat_emoji_handler]]>]>
        - else:
            - define orig_lines <[orig_lines].insert[<[text].parse[proc[chat_embed_handler].proc[chat_emoji_handler]]>].at[<[args].get[2]>]>
    - else if <[args].get[1]||null> == add:
        - if <[args].size> == 1:
            - narrate "<&[error]><[cmd_prefix]> add [text] <&[warning]>- to add text to the end (automatically line-wrapping)"
            - determine <[orig_lines]>
        - if <[orig_lines].is_empty>:
            - define new_line <[def_color]><[raw_args].after[ ]>
        - else:
            - define last_line <[orig_lines].last>
            - define new_line "<[last_line]> <[raw_args].after[ ]>"
        - narrate "<&[base]>Last line is now <[def_color]><[new_line]><&[base]>."
        - define new_line <[new_line].split_lines_by_width[<[wrap_len]>].lines_to_colored_list>
        - define nl_proc <[new_line].parse[proc[chat_embed_handler].proc[chat_emoji_handler]]>
        - define orig_lines <[orig_lines].set[<[nl_proc]>].at[<[orig_lines].size>]||<list[<[nl_proc]>]>>
    - else if <[args].get[1]||null> == remove:
        - if <[args].size> == 1 || !<[args].get[2].is_integer||false>:
            - narrate "<&[error]><[cmd_prefix]> remove [line] <&[warning]>- to remove a single line (where line is a number, like 1)"
            - determine <[orig_lines]>
        - if <[args].get[2]> < 1 || <[args].get[2]> > <[orig_lines].size> || <[orig_lines].is_empty>:
            - narrate "<&[error]>Cannot remove that line."
            - determine <[orig_lines]>
        - narrate "<&[base]>Line <&[emphasis]><[args].get[2]> <&[base]>removed."
        - define orig_lines <[orig_lines].remove[<[args].get[2]>]>
    - else if <[args].get[1].is_integer||false>:
        - if <[args].size> == 1:
            - narrate "<&[error]><[cmd_prefix]> [line] [text] <&[warning]>- to set a line number to the given contents (where line is a number, like 1)"
            - determine <[orig_lines]>
        - define text <[def_color]><[raw_args].after[ ]>
        #- narrate "<&[base]>Line <&[emphasis]><[args].get[1]> <&[base]>is now <[text]><&[base]>."
        - if <[args].get[1]> > <[orig_lines].size>:
            - define orig_lines <[orig_lines].include_single[<[text].proc[chat_embed_handler].proc[chat_emoji_handler]>]>
        - else:
            - define orig_lines <[orig_lines].set_single[<[text].proc[chat_embed_handler].proc[chat_emoji_handler]>].at[<[args].get[1]>]>
    - else:
        - narrate "<&[error]><[cmd_prefix]> clear <&[warning]>- to clear all text"
        - narrate "<&[error]><[cmd_prefix]> remove [line] <&[warning]>- to remove a single line (where line is a number, like 1)"
        - narrate "<&[error]><[cmd_prefix]> [line] [text] <&[warning]>- to set a line number to the given contents (where line is a number, like 1)"
        - narrate "<&[error]><[cmd_prefix]> add [text] <&[warning]>- to add text to the end (automatically line-wrapping)"
        - narrate "<&[error]><[cmd_prefix]> insert [line] [text] <&[warning]>- to insert text at a specific index (automatically line-wrapping)"
        - determine <[orig_lines]>
    - narrate "<&[base]>New text:"
    - foreach <[orig_lines]> as:line:
        - narrate "<&[emphasis]><[loop_index]><&[base]>) <[def_color]><[line]>"
    - determine <[orig_lines]>
