eventcharacter_command:
    type: command
    debug: false
    name: eventcharacter
    aliases:
    - eventchar
    - echar
    - echaracter
    usage: /eventcharacter
    description: Controls event characters.
    permission: dscript.eventcharacter
    tab completions:
        1: new|delete|update|apply|help
        2: <server.online_players.filter[has_flag[vanished].not].parse[name].include[<server.flag[event_characters].keys.parse[unescaped]||<list>>]>
        3: <server.flag[event_characters].keys.parse[unescaped]||<list>>
    script:
    - choose <context.args.first||help>:
        - case new:
            - if <context.args.size> < 2:
                - narrate "<&[error]>/eventcharacter new [name] <&[warning]>- Creates a new event character from your current character card"
                - stop
            - if !<player.has_flag[current_character]>:
                - narrate "<&[error]>You don't current have a character card applied. You must create the card using <&[warning]>/charactercard<&[error]> before you can turn it into an event character."
                - stop
            - define name <context.raw_args.after[ ].escaped>
            - if <server.has_flag[event_characters.<[name]>]>:
                - narrate "<&[error]>That event character already exists."
                - stop
            - flag server event_characters.<[name]>:<player.flag[character_cards.<player.flag[current_character]>]>
            - narrate "<&[base]>Event character created and updated to match your current character card."
        - case delete:
            - if <context.args.size> < 2:
                - narrate "<&[error]>/eventcharacter delete [name] <&[warning]>- Removes an event character"
                - stop
            - define name <context.raw_args.after[ ].escaped>
            - if !<server.has_flag[event_characters.<[name]>]>:
                - narrate "<&[error]>That event character doesn't exist."
                - stop
            - flag server event_characters.<[name]>:!
            - narrate "<&[base]>Event character deleted."
        - case update:
            - if <context.args.size> < 2:
                - narrate "<&[error]>/eventcharacter update [name] <&[warning]>- Updates an event character to match your current character card"
                - stop
            - if !<player.has_flag[current_character]>:
                - narrate "<&[error]>You don't current have a character card applied. You must create the card using <&[warning]>/charactercard<&[error]> before you can turn it into an event character."
                - stop
            - define name <context.raw_args.after[ ].escaped>
            - if !<server.has_flag[event_characters.<[name]>]>:
                - narrate "<&[error]>That event character doesn't exist."
                - stop
            - flag server event_characters.<[name]>:<player.flag[character_cards.<player.flag[current_character]>]>
            - narrate "<&[base]>Event character updated to match your current character card."
        - case apply:
            - if <context.args.size> < 3:
                - narrate "<&[error]>/eventcharacter apply [player] [name] <&[warning]>- Applies an event character to a player"
                - stop
            - define target <server.match_offline_player[<context.args.get[2]>]||null>
            - if <[target]> == null:
                - narrate "<&[error]>Unknown player '<&[emphasis]><context.args.get[2]><&[error]>'."
                - stop
            - define name <context.raw_args.after[ ].after[ ].escaped>
            - if !<server.has_flag[event_characters.<[name]>]>:
                - narrate "<&[error]>That event character doesn't exist."
                - stop
            - flag <[target]> pre_ooc_character:!
            - flag <[target]> character_override:!
            - flag <[target]> marked_afk:!
            - flag <[target]> character_cards.event.<[name]>:<server.flag[event_characters.<[name]>]>
            - run cc_set_mode def.mode:ic def.name:event.<[name]> player:<[target]>
            - narrate "<&[base]>Changed <proc[proc_format_name].context[<[target]>|<player>]> to event character <&[emphasis]><[name]><&[base]>."
        - default:
            - narrate "<&[error]>/eventcharacter new [name] <&[warning]>- Creates a new event character from your current character card"
            - narrate "<&[error]>/eventcharacter update [name] <&[warning]>- Updates an event character to match your current character card"
            - narrate "<&[error]>/eventcharacter delete [name] <&[warning]>- Removes an event character"
            - narrate "<&[error]>/eventcharacter apply [player] [name] <&[warning]>- Applies an event character to a player"
            - narrate "<&[base]>Current event characters: <&[emphasis]><server.flag[event_characters].keys.formatted||None>"
