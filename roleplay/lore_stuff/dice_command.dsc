dice_cmd_secretinject:
    type: task
    debug: false
    script:
    - define secret <context.alias.contains_text[secret]>
    - if <[secret]>:
        - define targets <list[<player>]>
    - else:
        - define targets <player.location.find_players_within[15]>

dice_cmd_log:
    type: task
    debug: false
    definitions: message|targets
    script:
    - define roller <player>
    - narrate "<proc[proc_format_name].context[<[roller]>|<player>]> <[message]>"  t:<[targets]> per_player
    - announce to_console "<player.name> <[message]>"
    - define message "[**ROLL** (to <[targets].size.sub[1]>)] <&lt>**`<player.name>`**<&gt>:  `<[message].strip_color>`"
    - run discord_send_message def:<list[<server.flag[discord_local_channel]>].include_single[<[message]>]>

random_coin_command:
    type: command
    permission: dscript.roll
    debug: false
    aliases:
    - coin
    - coinflip
    - flipcoin
    - flipsecret
    - secretflip
    - coinflipsecret
    - flipcoinsecret
    - secretcoinflip
    - secretflipcoin
    name: flip
    usage: /flip
    description: Flips a coin.
    script:
    - inject dice_cmd_secretinject
    - define message "<&[base]>flips a coin... <&[emphasis]><util.random_boolean.if_true[Heads].if_false[Tails]>!"
    - run floaty_particle_task def.location:<player.eye_location.random_offset[0.1]> def.text:<&font[waymaker:particle]>-<util.random_boolean.if_true[d].if_false[e]>- def.targets:<[targets]>
    - inject dice_cmd_log

random_card_command:
    type: command
    permission: dscript.roll
    debug: false
    aliases:
    - card
    - cardsecret
    - secretcard
    name: pullcard
    usage: /pullcard
    description: Pulls a random card from a standard 52-card deck.
    script:
    - inject dice_cmd_secretinject
    - define card <list[Ace|2|3|4|5|6|7|8|9|10|Jack|Queen|King].random>
    - define suit <list[Clubs|Diamonds|Hearts|Spades].random>
    - define prefix <script[playing_cards_data].parsed_key[<[suit]>]>
    - define message "<&[base]>pulls a card... <&[emphasis]><[card]> of <[prefix]> <[suit]>"
    - run floaty_particle_task def.location:<player.eye_location.random_offset[0.1]> def.text:<[prefix]><[card]> def.targets:<[targets]>
    - inject dice_cmd_log


roll_command:
    type: command
    permission: dscript.roll
    debug: false
    aliases:
    - dice
    - random
    - secretroll
    - secretdice
    - rollsecret
    - dicesecret
    - randomsecret
    - secretrandom
    name: roll
    usage: /roll (2d20) (+5)
    description: Rolls a dice.
    tab complete:
    - define in_prog <context.raw_args.ends_with[ ].if_true[<empty>].if_false[<context.args.last.if_null[<empty>]>]>
    - define prefix <empty>
    - if <[in_prog].contains[+]>:
        - define prefix <[in_prog].before_last[+]>+
        - define in_prog <[in_prog].after_last[+]>
    - if <[in_prog].contains[-]>:
        - define prefix <[in_prog].before_last[-]>-
        - define in_prog <[in_prog].after_last[-]>
    - define out <list>
    - if <[in_prog].contains[d]>:
        - define before_d <[in_prog].before[d]>
        - if <[before_d].is_integer>:
            - define after_d <[in_prog].after[d]>
            - foreach 1|2|3|4|5|6|7|8|9|10|20|100 as:possible:
                - if <[possible].starts_with[<[after_d]>]>:
                    - define out:->:<[prefix]><[before_d]>d<[possible]>
            - determine <[out]>
    - foreach <script[cc_data].parsed_key[stats].keys.include[<script[cc_data].parsed_key[skills].keys>].include[1|2|3|4|5|6|7|8|9|1d6|1d10|1d20|+]> as:possible:
        - if <[possible].starts_with[<[in_prog]>]>:
            - define out:->:<[prefix]><[possible]>
            - if <[prefix]> == <empty> && <[in_prog]> == <empty>:
                - define out:->:<[prefix]>-<[possible]>
    - determine <[out]>
    script:
    - inject dice_cmd_secretinject
    - if <context.raw_args> == card:
        - execute as_player <[secret].if_true[secretcard].if_false[pullcard]>
        - stop
    - if <context.raw_args> in coin|flip:
        - execute as_player <[secret].if_true[secretcoinflip].if_false[coinflip]>
        - stop
    - if <context.args.is_empty>:
        - narrate "<&[error]>You can roll any dice number or equation, for example <&[warning]>/roll d6 <&[error]>or <&[warning]>/roll 1d20 + 5"
        - narrate "<&[error]>You can use stat or skill names too, for example<n><&[warning]>/roll d20 + athletics"
        - narrate "<&[error]>Don't be afraid to get crazy if you want to!<n><&[warning]>/roll 20 - 2d20 + senses - body + 7"
        - stop
    - define parts <context.raw_args.replace_text[ ].replace_text[-].with[+-].replace_text[--].with[].split[+]>
    - define full_val 0
    - define result <empty>
    - foreach <[parts]> as:part:
        - if <[part]> == <empty>:
            - foreach next
        - define mul 1
        - define symbol +
        - if <[part].starts_with[-]>:
            - define mul -1
            - define symbol -
            - define part <[part].substring[2]>
        - if <[part]> in <script[cc_data].parsed_key[stats].keys>:
            - define part_val <[part].proc[cc_stat]>
            - define stat_col <script[cc_data].parsed_key[stats.<[part]>.color]>
            - define part_desc "<&[base]>Player stat <[stat_col]><[part].to_titlecase><&[base]> had value <[part_val].custom_color[emphasis]>"
        - else if <[part]> in <script[cc_data].parsed_key[skills].keys>:
            - define skill_name <[part].to_titlecase>
            - define part_val <[part].proc[cc_stat]>
            - define stat <script[cc_data].parsed_key[skills.<[part]>.stat]>
            - define stat_col <script[cc_data].parsed_key[stats.<[stat]>.color]>
            - define stat_raw_val <proc[cc_flag].context[stats.<[stat]>].custom_color[emphasis]>
            - define skilL_raw_val <proc[cc_flag].context[skills.<[part]>].custom_color[emphasis]>
            - define species <proc[cc_flag].context[species]>
            - define spec_perk <script[cc_data].parsed_key[species.<[species]>.skill_perk]>
            - define skill_perk_text <[spec_perk].equals[<[skill_name]>].if_true[ +<&[emphasis]>1<&[base]> (species bonus)].if_false[<empty>]>
            - define part_desc "<&[base]>Player skill <[skill_name].custom_color[emphasis]> had value <[part_val].custom_color[emphasis]> (<[stat_raw_val]> <[stat_col]><[stat]> <&[base]>+ <[skilL_raw_val]> <[skill_name]><[skill_perk_text]>)"
        - else if <[part].contains[d]>:
            - define count <[part].before[d]>
            - if <[count]> == <empty>:
                - define count 1
            - define sides <[part].after[d]>
            - if !<[count].is_integer> || <[count]> < 1 || <[count]> > 20:
                - narrate "<&[error]>Invalid die roll count '<[sides].custom_color[count]>'."
                - stop
            - if !<[sides].is_integer> || <[sides]> < 1 || <[sides]> > 999:
                - narrate "<&[error]>Invalid die roll sides '<[sides].custom_color[emphasis]>'."
                - stop
            - define die_out <list>
            - repeat <[count]>:
                - define die_out:->:<util.random.int[1].to[<[sides]>]>
            - define part_val <[die_out].sum>
            - define part_desc "<&[base]>Rolled <[count].custom_color[emphasis]> dice with <[sides].custom_color[emphasis]> sides: <&[emphasis]><[die_out].separated_by[<&[base]>, <&[emphasis]>]>"
        - else if <[part].is_integer>:
            - define part_val <[part]>
            - define part_desc "<&[base]>Constant number <[part].custom_color[emphasis]>"
        - else:
            - narrate "<&[error]>Unknown roll equation part '<[part].custom_color[emphasis]>'."
            - stop
        - define part_val:*:<[mul]>
        - define full_val:+:<[part_val]>
        - if <[result]> == <empty>:
            - if <[symbol]> == -:
                - define result -<[part].on_hover[<[part_desc]>]>
            - else:
                - define result <[part].on_hover[<[part_desc]>]>
        - else:
            - define result "<[result]> <[symbol]> <[part].on_hover[<[part_desc]>]>"
    - define message "<&[bases]>rolls a <&[emphasis]><[result]><&[base]>: <&[emphasis]><[full_val]>"
    - run floaty_particle_task def.location:<player.eye_location.random_offset[0.1]> def.text:<&[emphasis]><[parts].size.is_less_than[3].if_true[<[result].strip_color>: ].if_false[]><[full_val]> def.targets:<[targets]>
    - inject dice_cmd_log

playing_cards_data:
    type: data
    debug: false
    clubs: <&8>♣
    spades: <&8>♠
    diamonds: <&4>♦
    hearts: <&4>♥
