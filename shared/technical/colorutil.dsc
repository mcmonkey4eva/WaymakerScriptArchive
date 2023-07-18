color_data:
    type: data
    debug: false
    colors:
        red: FF0000
        green: 00FF00
        blue: 0000FF
        magenta: FF00FF
        pink: FF55FF
        yellow: FFFF00
        cyan: 00FFFF
        black: 000000
        white: FFFFFF
        orange: FFA500
        darkgreen: 008000
        darkblue: 000080
        darkred: 800000
        darkyellow: 808000
        darkcyan: 008080
        darkmagenta: 800080
        gray: 808080

color_tabcomplete_proc:
    type: procedure
    debug: false
    definitions: arg
    script:
    - if <[arg].starts_with[#]>:
        - determine <list[0|1|2|3|4|5|6|7|8|9|a|b|c|d|e|f].parse_tag[<[arg].substring[1,6]||#><[parse_value]>].include[#FF0000|#00FFFF|#00FF00|#0000FF|#FFFF00|#00FF55|#]>
    - determine <script[color_data].data_key[colors].keys.include[reset|#]>

set_color_command_prevalidate:
    type: task
    debug: false
    script:
    - define color <context.args.first>
    - define alias <context.alias>
    - inject set_color_command_extravalidate

set_color_command_extravalidate:
    type: task
    debug: false
    definitions: color|alias
    script:
    - if <[color].if_null[]> == <empty>:
        - narrate "<&[error]>/<[alias]> [color] <&[base]>- Use any RGB Hex Code, like <&[warning]>/<[alias]> #00AABB <&[base]>... if confused, <element[<&9>click here for a color picker].on_click[https://www.google.com/search?q=color+picker].type[open_url]><&[base]>, or <&[error]>/<[alias]> reset"
        - stop
    - if <[color]> != reset:
        - if <script[color_data].data_key[colors].contains[<[color]>]>:
            - define color #<script[color_data].parsed_key[colors.<[color]>]>
        - if !<[color].starts_with[#]> || <[color].length> != 7 || !<[color].after[#].matches_character_set[0123456789abcdefABCDEF]>:
            - narrate "<&[error]>Color input does not match standard color format. Use any RGB Hex Code, like <&[warning]>/<[alias]> #00FF55"
            - stop
