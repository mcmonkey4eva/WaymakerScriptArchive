bread_salesman_assign:
    type: assignment
    debug: false
    actions:
        on assignment:
        - trigger name:click state:true
        - trigger name:chat state:true
        - trigger name:proximity state:true radius:15
        on click:
        - wait 10t
        - narrate "<&[emphasis]>[<&6><element[Buy 16 Bread (5 TG)].on_click[buy 16 bread]><&[emphasis]>] [<&6><element[Buy 32 Bread (10 TG)].on_click[buy 32 bread]><&[emphasis]>] [<&6><element[Buy 64 Bread (20 TG)].on_click[buy 64 bread]><&[emphasis]>] [<element[No Thanks].on_click[No Thanks]><&[emphasis]>]"
        on spawn:
        - wait 1t
        - sneak <list[<npc>].include[<npc.name_hologram_npc||<list>>].include[<npc.hologram_npcs||<list>>].filter[is_spawned]> start fake
        on enter proximity:
        - sneak <list[<npc>].include[<npc.name_hologram_npc||<list>>].include[<npc.hologram_npcs||<list>>].filter[is_spawned]> stopfake
        on exit proximity:
        - sneak <list[<npc>].include[<npc.name_hologram_npc||<list>>].include[<npc.hologram_npcs||<list>>].filter[is_spawned]> start fake
    interact scripts:
    - bread_salesman_interact

bread_salesman_chat:
    type: format
    debug: false
    format: <&[emphasis]><npc.flag[npcname]||<npc.name>> <&f>says<&co> <[text]>

bread_salesman_data:
    type: data
    bread_info: <&[emphasis]>[<item[kit_item_fresh_bread].display.on_hover[kit_item_fresh_bread].type[show_item]><&[emphasis]>]
    prices:
        16: 5
        32: 10
        64: 20

bread_salesman_interact:
    type: interact
    debug: false
    speed: instant
    steps:
        1:
            click trigger:
                script:
                - narrate format:bread_salesman_chat "Hello! Would you like to buy some bread? <&6>5 Trade Gold <&f>for 16 <script[bread_salesman_data].parsed_key[bread_info]>"
                - zap 2
        2:
            click trigger:
                script:
                - narrate format:bread_salesman_chat "Hungry, aren'tcha?"
            chat trigger:
                1:
                    trigger: I'd like to /regex:buy \d+ bread/ please
                    script:
                    - if <player.flag[character_mode]> != ic:
                        - narrate "<&[error]>You must be IC to buy bread."
                        - stop
                    - define amount <context.message.after[buy].before[bread].trim>
                    - if !<[amount].is_integer>:
                        - narrate format:bread_salesman_chat "You what now?"
                        - stop
                    - define cost <script[bread_salesman_data].data_key[prices.<[amount]>]||null>
                    - if <[cost]> == null:
                        - narrate format:bread_salesman_chat "I can't count to that number."
                        - stop
                    - narrate format:bread_salesman_chat "Okay! Pay up! <&6><[cost]> TG"
                    - if <player.money> < <[cost]>:
                        - narrate format:bread_salesman_chat "Poor people don't get bread."
                        - stop
                    - take money quantity:<[cost]>
                    - run eco_log_loss def:<list[<[cost]>].include_single[bought BREAD from Butchy The Butcher]>
                    - run give_safe_item def.item:kit_item_fresh_bread[quantity=<[amount]>]
                    - narrate format:bread_salesman_chat "There you go! <&[emphasis]><[amount]> <script[bread_salesman_data].parsed_key[bread_info]><&f>! Enjoy!"
                2:
                    trigger: /No thanks/ I don't want any bread
                    script:
                    - narrate format:bread_salesman_chat "Then don't waste my time!"
                    - zap 1
