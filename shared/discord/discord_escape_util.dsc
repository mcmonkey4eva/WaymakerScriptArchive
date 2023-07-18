
discord_escape:
    type: procedure
    debug: false
    definitions: message
    script:
    - determine <[message].strip_color.replace_text[<&chr[0060]>].with[<&sq>].replace_text[<&chr[005C]>].with[/].replace_text[<&lt>].with[<&chr[3008]>].replace_text[:].with[<&chr[FF1A]>].replace_text[*].with[<&chr[2731]>].replace_text[_].with[<&chr[FF3F]>].replace_text[|].with[<&chr[FF5C]>].replace_text[~].with[<&chr[223C]>]>

discord_escape_simple_proc:
    type: procedure
    debug: false
    definitions: message
    script:
    - determine <[message].replace_text[\].with[\\].replace_text[@].with[\@].replace_text[*].with[\*].replace_text[`].with[\`].replace_text[~].with[\~].replace_text[_].with[\_].replace_text[<&lt>].with[\<&lt>].replace_text[<&gt>].with[\<&gt>].replace_text[@ever].with[﹫ever].replace_text[@her].with[﹫her]>
