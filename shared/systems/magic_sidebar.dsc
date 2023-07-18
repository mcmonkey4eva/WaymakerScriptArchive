# +-------------------------
# |
# | M a g i c   S i d e b a r
# |
# | Provides a working live-updating per-player sidebar!
#
# @author mcmonkey
# @date 2019/03/01
# @denizen-build REL-1679
# @script-version 1.0
#
# Installation:
# 1. Put the script in your scripts folder.
# 2. Edit the config script below to your liking.
# 3. Reload
#
# Usage:
# Type "/sidebar" in-game to toggle the sidebar on or off.
#
# ---------------------------- END HEADER ----------------------------

# ------------------------- Begin configuration -------------------------
magic_sidebar_config:
    type: data
    # How many updates per second (acceptable values: 1, 2, 4, 5, 10)
    per_second: 2
    # Set this to your sidebar title.
    title: <&[emphasis]><&l>Player Info
    # Set this to the list of sidebar lines you want to display.
    # Start a line with "[scroll:#/#]" to make it automatically scroll
    # with a specified width and scroll speed (characters shifted per second).
    # Note that width must always be less than the line's actual length.
    # There should also be at least one normal line that's as wide as the width, to prevent the sidebar resizing constantly.

    dir_name:
        east: E<&sp>
        west: W<&sp>
        north: N<&sp>
        south: S<&sp>
        northeast: NE
        northwest: NW
        southeast: SE
        southwest: SW
    world_name:
        waymakerland: <element[5].font[waymaker:waymaker]>
        tutorial: intro
        superflat: build
        oceanevent: ocean
        voidworld: void
        survivalland: survival
        test17: Test1.17
        danary: <element[6].font[waymaker:waymaker]>
    #- "[scroll:20/5]<&a>Welcome to <&6>Waymaker<&a>, <&[emphasis]><player.name><&a>!"
    #- "<&8>----------------------<&1>"
    lines_quest:
    - Focused quest: <&[emphasis]><server.flag[quests.<player.flag[quests.focused]>.name]||(Outdated)>
    lines_auto_afk:
    - Status: <&7>Auto AFK
    lines_character:
    - Character: <&[emphasis]><player.flag[current_character].proc[cc_name]>
    - Age: <&[emphasis]><proc[cc_flag].context[age]>
    - Species: <&[emphasis]> <proc[cc_flag].context[species]> (<proc[cc_flag].context[culture]>)
    - Trade Gold: <&6><player.money||0> TG
    lines_ooc:
    - Character Type: <&7><player.flag[character_override]>
    lines_nochar:
    - Character Type: <&7>None.
    - Use <&[warning]>/cc new <&f>or <&[warning]>/cc swap
    lines_split_1:
    - <&8>---------------------------<&2>
    lines_initiative:
    - <&8>---------------------------<&3>
    - Current turn: <&[emphasis]><proc[turn_cmd_proc_current].name>
    - Next turn: <&[emphasis]><proc[turn_cmd_proc_next].name>
    - Turns until you: <&[emphasis]><proc[turn_cmd_proc_count_turns]>
    lines_core_1:
    - Ping: <&[emphasis]><player.ping>ms
    - Channel: <script[channel_config].parsed_key[colors.<player.flag[channel]||global>]><player.flag[channel]||global>
    - Location: <&[emphasis]><player.location.block.xyz.proc[format_tiny_number].replace_text[,].with[<&f>,<&[emphasis]>]><&f>,<&[emphasis]><script[magic_sidebar_config].parsed_key[world_name.<player.location.world.name||>]||?> <script[magic_sidebar_config].parsed_key[dir_name.<player.location.direction||>]||?>
    lines_time:
    - Time: <&[emphasis]><player.world.time.proc[format_world_time]>
    lines_core_2:
    - Players: <&[emphasis]><server.flag[bungee_player_isonline].keys.parse[as[player]].filter[has_flag[vanished].not].size> <&f>(<&[emphasis]><server.online_players.filter[in_group[staff]].filter[has_flag[vanished].not].size><&f> staff)
    - <&8>--------------------------<&4>
    - <&f>    Type <&[emphasis]>/sidebar<&f> to hide
# ------------------------- End of configuration -------------------------

magic_sidebar_world:
    type: world
    debug: false
    events:
        on delta time secondly:
        - define per_second <script[magic_sidebar_config].data_key[per_second]>
        - define wait_time <element[1].div[<[per_second]>]>s
        - define players <server.online_players.filter[has_flag[sidebar_disabled].not]>
        - define checklist <server.online_players.filter[flag[character_mode].equals[ic]].filter[proc[cc_has_flag].context[verified].not]>
        - define players <[players].exclude[<[checklist]>]>
        - if <[checklist].any>:
            - define title "<&b><bold>New Character Checklist"
            - sidebar title:<[title].parsed> values:<proc[newchar_checklist_proc]> players:<[checklist]> per_player
        - if <[players].any>:
            - define title <script[magic_sidebar_config].data_key[title]>
            - repeat <[per_second]>:
                - sidebar title:<[title].parsed> values:<proc[magic_sidebar_lines_proc]> players:<[players]> per_player
                - wait <[wait_time]>

newchar_checklist_proc:
    type: procedure
    debug: false
    script:
    - definemap checks:
        discord_linked: <player.has_flag[discord_account]>
        irl_age: <player.has_flag[irl_dob]>
        char_age: <player.proc[cc_flag].context[age].equals[(Unset)].not>
        species: <player.proc[cc_flag].context[culture].equals[Uncultured].not>
        description: <player.proc[cc_flag].context[description].unseparated.equals[(UNSET)].not>
        stats: <element[6].sub[<proc[cc_flag].context[stats].values.sum>].equals[0]>
        skills: <element[10].sub[<proc[cc_flag].context[skills].values.sum>].equals[0]>
    - define strikes <[checks].parse_value_tag[<[parse_value].if_true[<gray><strikethrough>].if_false[<&[emphasis]>]>]>
    - define strikes_warn <[checks].parse_value_tag[<[parse_value].if_true[<gray><strikethrough>].if_false[<&[warning]>]>]>
    - define any_strike <[checks].values.filter[equals[false]].any>
    - define can_verify <player.proc[cc_has_flag].context[finalized].not>
    - definemap lines:
        1: <[strikes.discord_linked]>- Link your Discord account <[strikes_warn.discord_linked]>/discord
        2: <[strikes.irl_age]>- Confirm your IRL age with <[strikes_warn.irl_age]>/dob
        3: <[strikes.char_age]>- Set your <[strikes_warn.char_age]>/cc age
        4: <[strikes.species]>- Set your <[strikes_warn.species]>/cc species
        5: <[strikes.stats]>- Set your <[strikes_warn.stats]>/cc stats
        6: <[strikes.skills]>- Set your <[strikes_warn.skills]>/cc skills
        7: <[strikes.description]>- Set your <[strikes_warn.description]>/cc description
        8: <[can_verify].if_true[<[any_strike].if_true[<gray>].if_false[<&[emphasis]>]>].if_false[<gray><strikethrough>]>- Lock in with <[can_verify].if_true[<[any_strike].if_true[<gray>].if_false[<&[warning]>]>].if_false[<gray><strikethrough>]>/cc finalize
        9: <[can_verify].if_true[<gray>].if_false[<&[emphasis]>]>- Get verified by staff
    - determine <[lines].values>
    # discord, irl age, char age, stats, skills, species/culture, description, finalize, get verified

sidebar_line_process:
    type: procedure
    debug: false
    definitions: line
    script:
    - if <[line].starts_with[<&lb>scroll<&co>]>:
        - define width <[line].after[<&co>].before[/]>
        - define rate <[line].after[/].before[<&rb>]>
        - define line <[line].after[<&rb>]>
        - define index <util.current_time_millis.div[1000].mul[<[rate]>].round.mod[<[line].strip_color.length>].add[1]>
        - define end <[index].add[<[width]>]>
        - repeat <[line].length> as:charpos:
            - if <[line].char_at[<[charpos]>]> == <&ss>:
                - define index <[index].add[2]>
            - if <[index]> <= <[charpos]>:
                - repeat stop
        - define start_color <[line].substring[0,<[index]>].last_color>
        - if <[end]> > <[line].strip_color.length>:
            - define end <[end].sub[<[line].strip_color.length>]>
            - repeat <[line].length> as:charpos:
                - if <[line].char_at[<[charpos]>]> == <&ss>:
                    - define end <[end].add[2]>
                - if <[end]> < <[charpos]>:
                    - repeat stop
            - define line "<[start_color]><[line].substring[<[index]>]> <&f><[line].substring[0,<[end]>]>"
        - else:
            - repeat <[line].length> as:charpos:
                - if <[line].char_at[<[charpos]>]> == <&ss>:
                    - define end <[end].add[2]>
                - if <[end]> < <[charpos]>:
                    - repeat stop
            - define line <[start_color]><[line].substring[<[index]>,<[end]>]>
    - determine <[line]>

magic_sidebar_lines_proc:
    type: procedure
    debug: false
    script:
    - define list <list>
    - if <player.has_flag[auto_afk_mark]> && !<player.has_flag[marked_afk]>:
        - define list:|:<script[magic_sidebar_config].data_key[lines_auto_afk]>
    - if <server.has_flag[is_roleplay_server]>:
        - if <player.has_flag[current_character]>:
            - define list:|:<script[magic_sidebar_config].data_key[lines_character]>
        - else if <player.has_flag[character_override]>:
            - define list:|:<script[magic_sidebar_config].data_key[lines_ooc]>
        - else:
            - define list:|:<script[magic_sidebar_config].data_key[lines_nochar]>
        - if <player.has_flag[quests.focused]>:
            - define list:|:<script[magic_sidebar_config].data_key[lines_quest]>
    - if <player.has_flag[turn_system_current]>:
        - define list:|:<script[magic_sidebar_config].data_key[lines_initiative]>
        - define init_id <player.flag[turn_system_current]>
        - define turns <server.flag[turn_system.<[init_id]>]||<map>>
        - if <[turns].contains[timer]>:
            - define time <[turns].get[timer].sub[<util.time_now.to_utc.duration_since[<[turns].get[turn_start]>]>]>
            - define "list:->:<&f>Timer: <&[emphasis]><[time].in_seconds.is_less_than[1].if_true[Time's up!].if_false[<[time].formatted>]>"
    - define list:|:<script[magic_sidebar_config].data_key[lines_split_1]>
    - define list:|:<script[magic_sidebar_config].data_key[lines_core_1]>
    - if <player.world.name> == danary:
        - define list:|:<script[magic_sidebar_config].data_key[lines_time]>
    - define list:|:<script[magic_sidebar_config].data_key[lines_core_2]>
    - determine <[list].parse[parsed.proc[sidebar_line_process]]>

magic_sidebar_command:
    type: command
    debug: false
    name: sidebar
    usage: /sidebar
    aliases:
    - sb
    description: Toggles your sidebar on or off.
    permission: dscript.sidebar
    script:
    - if !<player.flag[character_mode]> == ic && !<player.proc[cc_has_flag].context[verified]>:
        - narrate "<&[error]>You cannot disable the new-character checklist."
        - stop
    - if <player.has_flag[sidebar_disabled]>:
        - flag player sidebar_disabled:!
        - narrate "<&[emphasis]>Sidebar enabled."
    - else:
        - flag player sidebar_disabled
        - narrate "<&[emphasis]>Sidebar disabled."
        - wait 1
        - sidebar remove players:<player>
