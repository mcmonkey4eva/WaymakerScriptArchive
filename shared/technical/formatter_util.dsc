format_world_time:
    type: procedure
    debug: false
    definitions: time
    script:
    - define hour <[time].add[6000].mod[24000].div[1000].round_down>
    - define minute <[time].add[6000].mod[1000].div[1000].mul[60].round_down>
    - if <[hour]> < 6 || <[hour]> >= 18:
        - define word Night
    - else:
        - define word Day
    - if <[hour]> < 12:
        - define suffix AM
    - else:
        - define suffix PM
    # Note: this isn't part of the 'else' because '12 PM' exists
    - if <[hour]> > 12:
        - define hour <[hour].sub[12]>
    - determine "<&[emphasis]><[hour].pad_left[2].with[0]><&7>:<&[emphasis]><[minute].pad_left[2].with[0]> <[suffix]> <&7>(<&[emphasis]><[word]><&7>)"

format_tiny_number:
    type: procedure
    debug: false
    definitions: text
    script:
    - determine <[text].replace_text[0].with[⁰].replace_text[1].with[¹].replace_text[2].with[²].replace_text[3].with[³].replace_text[4].with[⁴].replace_text[5].with[⁵].replace_text[6].with[⁶].replace_text[7].with[⁷].replace_text[8].with[⁸].replace_text[9].with[⁹].replace_text[-].with[⁻]>

auto_s_proc:
    type: procedure
    debug: false
    definitions: number
    script:
    - determine <[number].equals[1].if_true[].if_false[s]>
