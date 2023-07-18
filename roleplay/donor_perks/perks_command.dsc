perks_command:
    type: command
    debug: false
    name: perks
    description: Shows your available donator perks.
    usage: /perks
    aliases:
    - perk
    script:
    - define any false
    - if <player.in_group[booster]>:
        - narrate "<&[emphasis]>As a Discord Nitro Booster, you may:"
        - narrate "<&[base]>- Spawn a couple fireworks once per hour using <element[<&[clickable]>/firework].on_click[/firework].type[suggest_command].on_hover[click to try!]>"
        - narrate "<&[base]>- Play mob sounds once every five minutes using <element[<&[clickable]>/noise].on_click[/noise ].type[suggest_command].on_hover[click to try!]>"
        - narrate "<&[base]>- Crawl around the floor using <element[<&[clickable]>/crawlshift].on_click[/crawlshift].type[suggest_command].on_hover[click to try!]> to toggle and then hold shift to crawl"
        - narrate "<&[base]>- Also you get a crystal on your name <&f><element[:nitro:].proc[chat_emoji_handler]>"
        - define any true
    - if <player.in_group[donator_two]>:
        - narrate "<&[emphasis]>As a Wayfinder+, you may:"
        - narrate "<&[base]>- Get extra particles and sounds in <element[<&[clickable]>/cry].on_click[/cry].type[suggest_command].on_hover[click to try!]>, <element[<&[clickable]>/spit].on_click[/spit].type[suggest_command].on_hover[click to try!]>, <element[<&[clickable]>/lick].on_click[/lick].type[suggest_command].on_hover[click to try!]>, and <element[<&[clickable]>/kiss].on_click[/kiss].type[suggest_command].on_hover[click to try!]>"
        - narrate "<&[base]>- Hat any block <element[<&[clickable]>/hat].on_click[/hat].type[suggest_command].on_hover[click to try!]>"
        - narrate "<&[base]>- Customize your join/leave notification messages with <element[<&[clickable]>/customizejoinmessage].on_click[/customizejoinmessage].type[suggest_command].on_hover[click to try!]> and <element[<&[clickable]>/customizeleavemessage].on_click[/customizeleavemessage].type[suggest_command].on_hover[click to try!]>"
        - narrate "<&[base]>- Change the name color of most items using <element[<&[clickable]>/itemnamecolor].on_click[/itemnamecolor #].type[suggest_command].on_hover[click to try!]> (this will bind the item to you)"
        - narrate "<&[base]>- Disguise as a mob (especially helpful to Faefolke) using <element[<&[clickable]>/disguise].on_click[/disguise ].type[suggest_command].on_hover[click to try!]>"
        - define any true
    - if <player.in_group[donator_one]>:
        - narrate "<&[emphasis]>As a Wayfinder, you may:"
        - narrate "<&[base]>- Poke players with sounds and particles by right clicking a player and selecting the 'poke' option in the interact menu"
        - narrate "<&[base]>- Walk slower than normal using <element[<&[clickable]>/walk].on_click[/walk].type[suggest_command].on_hover[click to try!]>"
        - narrate "<&[base]>- Hat a banner item <element[<&[clickable]>/hat].on_click[/hat].type[suggest_command].on_hover[click to try!]>"
        - narrate "<&[base]>- Edit banners <element[<&[clickable]>/editbanner].on_click[/editbanner].type[suggest_command].on_hover[click to try!]> (this will bind the item to you)"
        - narrate "<&[base]>- Set the default name color of new players using <element[<&[clickable]>/setdefaultnamecolor].on_click[/setdefaultnamecolor #].type[suggest_command].on_hover[click to try!]>"
        - narrate "<&[base]>- Set the default name color of friends using <element[<&[clickable]>/setfriendsnamecolor].on_click[/setfriendsnamecolor #].type[suggest_command].on_hover[click to try!]>"
        - narrate "<&[base]>- Also you get a unique name color and special Discord channel access"
        - define any true
    - if <player.in_group[founder]>:
        - narrate "<&[emphasis]>As a Founder, you may:"
        - narrate "<&[base]>- Disguise as a mob (especially helpful to Faefolke) using <element[<&[clickable]>/disguise].on_click[/disguise ].type[suggest_command].on_hover[click to try!]>"
        - narrate "<&[base]>- Spawn a bunch of fireworks once per hour using <element[<&[clickable]>/firework].on_click[/firework].type[suggest_command].on_hover[click to try!]>"
        - narrate "<&[base]>- Punch any staff member up three times per hour"
        - narrate "<&[base]>- Also your character cards in-game have cooler colors. Also you can have one extra card."
        - narrate "<&[base]>- Also you get a diamond <&f>✦<&[base]> on your name and special Discord channel access"
        - define any true
    - if !<[any]>:
        - narrate "<&[base]>You are not a current donator, and so do not receive perks. Donate to support the server at <&9>https://example.com/ <&[base]>and get some cool perks! (Make sure to link your Discord account when Tebex asks you!!)"
