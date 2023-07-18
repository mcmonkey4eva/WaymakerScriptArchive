help_command:
    type: command
    debug: false
    name: help
    usage: /help
    description: Shows help info.
    permission: dscript.help
    tab completions:
        1: economy|help|chat|emoji
    script:
    - choose <context.args.first||help>:
        - case emoji:
            - narrate "<&[warning]>===== Waymaker Emoji Help ====="
            - narrate "<&[base]>You can use the following emoji - shift-click an emoji name to auto-insert it, or hover your mouse to read the typable name (for example type <&[warning]>:waymaker: <&[base]>to output <element[waymaker].proc[emojify_proc]>):"
            - narrate <&f><script[emojify_proc].data_key[data].keys.parse_tag[<element[<[parse_value].proc[emojify_proc]>].with_insertion[:<[parse_value]>:]>].unseparated>
        - case chat:
            - narrate "<&[warning]>===== Waymaker Chat Help ====="
            - narrate "<&[warning]>- <&[base]>You can choose a chat channel like <&[emphasis]>/channel global <&[base]>or <&[emphasis]>/g <&[base]>you can also quick-chat in a channel like <&[emphasis]>/g quick message"
            - narrate "<&[warning]>- <&[base]>You can hide a chat channel like <&[emphasis]>/chat toggle global"
            - narrate "<&[warning]>- <&[base]>While in local, end a message with <&[emphasis]>!!<&[base]> to shout, <&[emphasis]>!<&[base]> to exclaim, <&[emphasis]>+<&[base]> to emote (also works in whisper/mutter), <&[emphasis]>$<&[base]> to mutter, <&[emphasis]>*<&[base]> to whisper, <&[emphasis]>@<&[base]> for a loud emote, <&[emphasis]>))<&[base]> to talk OOC, or <&[emphasis]><&rb><&[base]> for environmental messages."
            - narrate "<&[warning]>- <&[base]>You can also at any time type <&[emphasis]>[[helditem]] <&[base]>to embed your held item, or <&[emphasis]>[[character]] <&[base]>to embed your character card."
            - narrate "<&[base]>Or type <&[emphasis]>[[item:sword]] <&[base]>to embed an item in your inventory by search term (in that example 'stone'), or <&[emphasis]>[[character:bob]] <&[base]>to embed a different character card by search term, or <&[emphasis]>[[character:monkey:bob]] <&[base]>to embed a different player's character card by player name and search term."
            - narrate "<&[warning]>- <&[base]>See also <&[clickable]><element[/help emoji].on_hover[Click to view].on_click[/help emoji]>"
        - case economy:
            - narrate "<&[warning]>===== Waymaker Economy Help ====="
            - narrate "<&[warning]>- <&[base]>Waymaker uses an economy system based on <&6>Trade Gold<&[base]>, often shortened to <&6>TG<&[base]>."
            - narrate "<&[warning]>- <&[base]>Trade Gold is represented in item form as [<element[<&6>Trade Penny].on_hover[trade_penny_item].type[show_item]>] for <&6>1 TG<&[base]> and [<element[<&6>Trade Stater].on_hover[trade_stater_item].type[show_item]>] for <&6>10 TG"
            - narrate "<&[warrning]>- <&[base]>Balances are tracked per-character."
            - if <player.flag[character_mode]> == ic:
                - narrate "<&[warning]>- <&[base]>Your current character's balance is <&6><player.money> TG"
            - narrate "<&[warning]>- <&[base]>You can check your balance at any time while IC with <proc[clickable_cmd_proc].context[/balance]> or by looking at the sidebar"
            - narrate "<&[warning]>- <&[base]>You can pay a player via <&[warning]>/pay (PLAYER NAME) (AMOUNT) <&[base]>for example: <&[warning]>/pay somebody 50"
            - narrate "<&[warning]>- <&[base]>We also have a business system. To learn how to operate a business, use <proc[clickable_cmd_proc].context[/business help]>"
            - narrate "<&[warning]>- <&[base]>You can pay a business via <&[warning]>/business pay (BUSINESS NAME) (AMOUNT) <&[base]>for example: <&[warning]>/business pay waymaker 50"
            - narrate "<&[warning]>- <&[base]>If you want to convert some of your balance to staters and pennies, use <&[warning]>/withdraw (amount) <&[base]>You can put money items back into your balance via <&[warning]>/deposit (amount)"
        - default:
            - narrate "<&[warning]>===== Waymaker Help ====="
            - narrate "<&[warning]>- <&[base]>Welcome to Waymaker! Key links: <element[<&9>Discord].on_click[https://discord.gg/xxx].type[open_url].on_hover[Click Here]>, <element[<&9>Forums].on_click[https://forum.example.com/].type[open_url].on_hover[Click Here]>, <element[<&9>Wiki].on_click[https://wiki.example.com/].type[open_url].on_hover[Click Here]>, <element[<&9>Dynmap].on_click[https://dynmap.example.com/].type[open_url].on_hover[Click Here]>"
            - narrate "<&[warning]>- <&[base]>For help with chat usage, use <proc[clickable_cmd_proc].context[/help chat]>"
            - narrate "<&[warning]>- <&[base]>For help with character cards, use <proc[clickable_cmd_proc].context[/charactercard]>"
            - narrate "<&[warning]>- <&[base]>To make a staff ticket, use <proc[clickable_cmd_proc].context[/ticket]>"
            - narrate "<&[warning]>- <&[base]>For information about the economy system, use <proc[clickable_cmd_proc].context[/help economy]>"
            - narrate "<&[warning]>- <&[base]>We have a sidebar that shows common helpful information. You can turn it on or off with <proc[clickable_cmd_proc].context[/sidebar]>"
            - narrate "<&[warning]>- <&[base]>You can vote for our server on a few list websites to earn <&6>Trade Gold<&[base]>! To get vote links, use <proc[clickable_cmd_proc].context[/vote]>"
            - narrate "<&[warning]>- <&[base]>For help with the friends system, use <proc[clickable_cmd_proc].context[/friend]>"
            - narrate "<&[warning]>- <&[base]>You can roll dice with <proc[clickable_cmd_proc].context[/roll]>, pull a random card with <proc[clickable_cmd_proc].context[/card]>, or flip a coin with <proc[clickable_cmd_proc].context[/flip]>"
            - narrate "<&[warning]>- <&[base]>Low on inventory space? Use <proc[clickable_cmd_proc].context[/enderchest]>"

clickable_cmd_proc:
    type: procedure
    debug: false
    definitions: cmd
    script:
    - determine <element[<&[clickable]><[cmd]>].on_click[<[cmd]>].on_hover[Click Here]>
