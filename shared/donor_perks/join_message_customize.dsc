
customize_join_message_command:
    type: command
    debug: false
    name: customizejoinmessage
    aliases:
    - customjoinmessage
    - editjoinmessage
    - joinmessagedit
    description: Edits your join message.
    usage: /customizejoinmessage [message]
    permission: dscript.customizejoinmessage
    tab complete:
    - determine [name]
    script:
    - if <context.args.is_empty>:
        - narrate "<&[error]>/customizejoinmessage [message]"
        - narrate "<&[error]>Must include <&[emphasis]>[name]<&[error]> (type that literally don't fill it in) where your name fits, exactly once."
        - narrate "<&[error]>For example: <&[warning]>/customizejoinmessage [name] joined."
        - stop
    - if <context.raw_args.split[<&lb>name<&rb>].size> != 2:
        - narrate "<&[error]>Necessary <&[emphasis]>[name]<&[error]> not found."
        - narrate "<&[error]>Your message must include <&[emphasis]>[name]<&[error]> (type that literally don't fill it in) where your name fits, exactly once."
        - narrate "<&[error]>For example: <&[warning]>/customizejoinmessage [name] joined."
        - stop
    - flag player custom_join_message:<context.raw_args>
    - narrate "<&[base]>Your join message has been set to:<n><&[base]><player.flag[custom_join_message].replace[<&lb>name<&rb>].with[<&[emphasis]><proc[proc_format_name].context[<player>|<player>]>]>"

customize_leave_message_command:
    type: command
    debug: false
    name: customizeleavemessage
    aliases:
    - customleavemessage
    - editleavemessage
    - leavemessagedit
    - customizequitmessage
    - customquitmessage
    - editquitmessage
    - quitmessagedit
    description: Edits your leave message.
    usage: /customizeleavemessage [message]
    permission: dscript.customizejoinmessage
    tab complete:
    - determine [name]
    script:
    - if <context.args.is_empty>:
        - narrate "<&[error]>/customizeleavemessage [message]"
        - narrate "<&[error]>Must include <&[emphasis]>[name]<&[error]> (type that literally don't fill it in) where your name fits, exactly once."
        - narrate "<&[error]>For example: <&[warning]>/customizeleavemessage [name] logged off."
        - stop
    - if <context.raw_args.split[<&lb>name<&rb>].size> != 2:
        - narrate "<&[error]>Necessary <&[emphasis]>[name]<&[error]> not found."
        - narrate "<&[error]>Your message must include <&[emphasis]>[name]<&[error]> (type that literally don't fill it in) where your name fits, exactly once."
        - narrate "<&[error]>For example: <&[warning]>/customizeleavemessage [name] logged off."
        - stop
    - flag player custom_leave_message:<context.raw_args>
    - narrate "<&[base]>Your leave message has been set to:<n><&[base]><player.flag[custom_leave_message].replace[<&lb>name<&rb>].with[<&[emphasis]><proc[proc_format_name].context[<player>|<player>]>]>"

custom_join_messages_world:
    type: world
    debug: false
    events:
        after player joins:
        - wait 5s
        - if !<player.is_online>:
            - stop
        - if <player.has_permission[dscript.customizejoinmessage]>:
            - flag player can_use_customjoinleave
        - else:
            - flag player can_use_customjoinleave:!
