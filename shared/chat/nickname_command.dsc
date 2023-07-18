nick_command:
    type: command
    debug: false
    name: nick
    usage: /nick [name or 'off']
    description: Sets your nickname.
    permission: dscript.nick
    aliases:
    - nickname
    script:
    - if <context.args.is_empty>:
        - narrate "<&[error]>/nick [name or 'off']"
        - stop
    - if <context.args.first> == off:
        - flag player nickname:!
        - narrate "<&[emphasis]>Nickname cleared."
        - stop
    - if <context.raw_args.length> > 32:
        - narrate "<&[error]>Name too long."
        - stop
    - flag player nickname:<context.raw_args.proc[chat_emoji_handler]>
    - narrate "<&[emphasis]>Nickname updated to <&f><player.flag[nickname]><&[emphasis]>."
    - wait 1t
    - run name_suffix_character_card
