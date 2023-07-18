cc_data:
    type: data
    species:
        Human:
            skill_perk: Technique
        Goliath:
            skill_perk: Athletics
        Orc:
            skill_perk: Recovery
        Goblin:
            skill_perk: Evasion
        Elf:
            skill_perk: Proficiency
        Crestfallen:
            skill_perk: Compsure
        Faefolke:
            skill_perk: Obscura
        Vhyranni:
            skill_perk: Senses
        Dwarf:
            skill_perk: Endurance
        Halfling:
            skill_perk: Intuition
    stats:
        Body:
            color: <&color[#ff5733]>
        Magic:
            color: <&color[#8165ed]>
        Speed:
            color: <&color[#1dbf8f]>
        Vitality:
            color: <&color[#ff44fd]>
    skill_type_color:
        Active: <&color[#ff0000]>
        Reactive: <&color[#ffff00]>
        Expertise: <&color[#00ff00]>
    skills:
        Athletics:
            stat: Body
            description: Using the body to jump, climb, throw, lift.<n>When active, +2 to Physical Attack rolls.
            type: Active
            cmd: 100030
        Resilience:
            stat: Body
            description: Using one's fitness to shrug off physical damage. Physical defense.<n>+2 to Physical Defense rolls.<n>When active, +1 to Physical Mitigation rolls.
            type: Reactive
            cmd: 100031
        Technique:
            stat: Body
            description: The form and execution of physical movements.<n>When active, +2 To Physical Damage rolls.
            type: Expertise
            cmd: 100032
        Intuition:
            stat: Magic
            description: Attuning oneself to their environment, catching up on atmospheric change, and the <&dq>sixth sense<&dq>.<n>When active, +2 to Magic Attack rolls.
            type: Active
            cmd: 100033
        Psyche:
            stat: Magic
            description: Using one's mental acuity to shrug off magical or spirital attacks. Magic defense.<n>+2 to Magic Defense rolls.<n>When active, +1 to Magic Mitigation rolls.
            type: Reactive
            cmd: 100034
        Obscura:
            stat: Magic
            description: The ability to uncover secrets and harness the unseen world.<n>When active, +2 To Magic Damage rolls.
            type: Expertise
            cmd: 100035
        Senses:
            stat: Speed
            description: Spotting and identifying things, especially through the use of senses and reflexes.<n>When active, Rolling a 19 counts as Critical.
            type: Active
            cmd: 100036
        Evasion:
            stat: Speed
            description: Moving out of danger by using one's reflexes.<n>When active, Rolling a 19 counts as Critical.
            type: Reactive
            cmd: 100037
        Proficiency:
            stat: Speed
            description: Dexterity of one's mechanical manipulation, for actions that require a finer control.<n>When active, +3 to the result of any Critical roll.
            type: Expertise
            cmd: 100038
        Recovery:
            stat: Vitality
            description: Healing of the body and soul through natural means.<n>+1 to all Mitigation rolls.<n>When active, +1 to Healing rolls.
            type: Active
            cmd: 100039
        Endurance:
            stat: Vitality
            description: Utilizing stamina and physical fitness over a long period of time.<n>+1 to any Defense roll.<n>When active, +1 to Healing rolls.
            type: Reactive
            cmd: 100040
        Composure:
            stat: Vitality
            description: The ability to maintain an activity in a changing, increasingly difficult situation.<n>+1 to any Damage or Mitigation roll.<n>When active, +1 to Healing rolls.
            type: Expertise
            cmd: 100041

characters_stat_selector_world:
    type: world
    debug: false
    data:
        column:
            0: Body
            2: Magic
            4: Speed
            6: Vitality
        row:
            1: 4
            2: 3
            3: 2
            4: 1
            5: 0
    events:
        on player clicks item in cc_stat_selector_inv:
        - if <player.flag[character_mode]> != ic || <proc[cc_has_flag].context[finalized]>:
            - stop
        - define column <context.slot.sub[1].mod[9]>
        - define row <context.slot.sub[1].div[9].round_down>
        - define stat <script.parsed_key[data.column.<[column]>]||none>
        - define val <script.parsed_key[data.row.<[row]>]||none>
        - if <[stat]> == none || <[val]> == none:
            - stop
        - define current <player.flag[current_character]>
        - define stats <proc[cc_flag].context[stats]>
        - define spare_points <element[6].sub[<[stats].values.sum>]>
        - define stat_cur <[stats].get[<[stat]>]>
        - if <[val].sub[<[stat_cur]>]> > <[spare_points]>:
            - stop
        - if <[val]> > <[stat_cur]>:
            - playsound <player> sound:block_amethyst_cluster_place pitch:1
        - else if <[val]> < <[stat_cur]>:
            - playsound <player> sound:block_amethyst_cluster_place pitch:0.5
        - flag player character_cards.<[current]>.stats.<[stat]>:<[val]>
        - run cc_refresh_attributes
        - run cc_open_stat_inv

cc_open_stat_inv:
    type: task
    debug: false
    script:
    - if <player.flag[character_mode]> != ic:
        - stop
    - define current <player.flag[current_character]>
    - define stats <proc[cc_flag].context[stats]>
    - define spare_points <element[6].sub[<[stats].values.sum>]>
    - define inventory <inventory[cc_stat_selector_inv]>
    - adjust def:inventory "title:<&f><&font[waymaker:gui]>-c=<&font[minecraft:default]><&7>Stats: <&b><[current].proc[cc_name]>"
    - repeat <[spare_points]> as:row:
        - inventory set d:<[inventory]> o:cc_invitem_stat_sparepoint slot:<[row].mul[9]>
    - foreach Body|Magic|Speed|Vitality as:stat:
        - define sub <[loop_index].mul[2]>
        - repeat <[stats.<[stat]>]> as:row:
            - inventory set d:<[inventory]> o:<proc[cc_invitem_stat].context[<[stat]>]> slot:<element[6].sub[<[row]>].mul[9].sub[10].add[<[sub]>]>
    - inventory open d:<[inventory]>

cc_invitem_stat:
    type: procedure
    debug: false
    definitions: stat
    script:
    - definemap data:
        custom_model_data: 100019
        display: <script[cc_data].parsed_key[stats.<[stat]>.color]><[stat]>
    - determine <item[book].with_map[<[data]>]>

cc_stat:
    type: procedure
    debug: false
    definitions: stat
    script:
    - if <player.flag[character_mode]> != ic:
        - determine 0
    - define current <player.flag[current_character]>
    - define stats <proc[cc_flag].context[stats]>
    - define val <[stats.<[stat]>]||null>
    - if <[val]> != null:
        - determine <[val]>
    - define skills <proc[cc_flag].context[skills]>
    - define val <[skills.<[stat]>]||null>
    - if <[val]> == null:
        - determine null
    - if <script[cc_data].parsed_key[species.<proc[cc_flag].context[species]>.skill_perk]||null> == <[stat]>:
        - define val:++
    - define stat <script[cc_data].parsed_key[skills.<[stat]>.stat]>
    - define val:+:<[stats.<[stat]>]||0>
    - determine <[val]>

cc_stat_selector_inv:
    type: inventory
    debug: false
    gui: true
    inventory: chest
    slots:
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [<proc[cc_invitem_stat].context[Body]>] [] [<proc[cc_invitem_stat].context[Magic]>] [] [<proc[cc_invitem_stat].context[Speed]>] [] [<proc[cc_invitem_stat].context[Vitality]>] [] []

cc_invitem_stat_sparepoint:
    type: item
    debug: false
    material: book[custom_model_data=100019]
    display name: <&f>Unspent Point

cc_skillpoints_inv:
    type: inventory
    debug: false
    gui: true
    inventory: chest
    slots:
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []

cc_skill_item:
    type: item
    debug: false
    material: book[custom_model_data=100019]

cc_skill_adder_item:
    type: item
    debug: false
    material: book

cc_skill_unspent_item:
    type: item
    debug: false
    material: book
    display name: <&f>Unspent Skill Points Count

cc_open_skills_inv:
    type: task
    data:
        slots:
            22: Athletics
            24: Resilience
            26: Technique
            31: Intuition
            33: Psyche
            35: Obscura
            40: Senses
            42: Evasion
            44: Proficiency
            49: Recovery
            51: Endurance
            53: Composure
    debug: false
    script:
    - define can_modify <proc[cc_has_flag].context[finalized].not>
    - define inventory <inventory[cc_skillpoints_inv]>
    - define current <player.flag[current_character]>
    - define stats <proc[cc_flag].context[stats]>
    - define skills <proc[cc_flag].context[skills]>
    - define spare_points <element[10].sub[<[skills].values.sum>]>
    - adjust def:inventory "title:<&f><&font[waymaker:gui]>-d=<&font[minecraft:default]><&7>Skills: <&b><[current].proc[cc_name]>"
    - if <[spare_points]> == 10:
        - inventory set slot:8 d:<[inventory]> o:<item[cc_skill_unspent_item].with[custom_model_data=100021]>
        - inventory set slot:9 d:<[inventory]> o:<item[cc_skill_unspent_item].with[custom_model_data=100020]>
    - else:
        - inventory set slot:9 d:<[inventory]> o:<item[cc_skill_unspent_item].with[custom_model_data=10002<[spare_points]>]>
    - define skill_data <script[cc_data].parsed_key[skills]>
    - define species <proc[cc_flag].context[species]>
    - define spec_perk <script[cc_data].parsed_key[species.<[species]>.skill_perk]>
    - foreach <script.parsed_key[data.slots]> as:skill_name key:slot:
        - define stat <[skill_data.<[skill_name]>.stat]>
        - define color <script[cc_data].parsed_key[stats.<[stat]>.color]>
        - define type <[skill_data.<[skill_name]>.type]>
        - define type_color <script[cc_data].parsed_key[skill_type_color.<[type]>]>
        - define desc <&7><[skill_data.<[skill_name]>.description]>
        - if <[spec_perk]> == <[skill_name]>:
            - define perk_add 1
            - define perk_text "<&[emphasis]>Has +1 from species."
        - else:
            - define perk_add 0
            - define perk_text <empty>
        - define cur <[skills.<[skill_name]>].add[<[perk_add]>]>
        - definemap adjusts:
            custom_model_data: <[skill_data.<[skill_name]>.cmd]>
            display: <&[emphasis]><[skill_name]>
            lore: <list[<[color]><[stat]><&7>, <[type_color]><[type]>].include[<[desc].split_lines_by_width[200].lines_to_colored_list>].include[<&[base]>Current: <&[emphasis]><[cur]>].include[<[perk_text]>]>
        - inventory set d:<[inventory]> slot:<[slot]> o:<item[cc_skill_item].with_map[<[adjusts]>]>
        - if <[can_modify]>:
            - definemap adder_adjusts:
                custom_model_data: 10002<[cur]>
                display: <&[base]>Modify skill: <&[emphasis]><[skill_name]>
                lore:
                - <&[base]>Current: <&[emphasis]><[cur]>
                - <[cur].equals[<[perk_add].add[5]>].if_true[<empty>].if_false[<&[base]>Left click: <&color[#00ff00]><[cur].add[1].min[<[perk_add].add[5]>]>]>
                - <[cur].equals[<[perk_add]>].if_true[<empty>].if_false[<&[base]>Right click: <&color[#ffff00]><[cur].sub[1].max[<[perk_add]>]>]>
        - else:
            - definemap adder_adjusts:
                custom_model_data: 10002<[cur]>
                display: <&[base]>Skill: <&[emphasis]><[skill_name]>
                lore:
                - <&[base]>Current: <&[emphasis]><[cur]>
        - inventory set d:<[inventory]> slot:<[slot].add[1]> o:<item[cc_skill_adder_item].with_map[<[adder_adjusts]>]>
        - inventory flag d:<[inventory]> slot:<[slot].add[1]> skill_name:<[skill_name]>
    - inventory open d:<[inventory]>

cc_skill_inv_world:
    type: world
    debug: false
    events:
        on player clicks cc_skill_adder_item in cc_skillpoints_inv:
        - if <player.flag[character_mode]> != ic || <proc[cc_has_flag].context[finalized]>:
            - stop
        - define skill <context.item.flag[skill_name]>
        - define cur <proc[cc_flag].context[skills.<[skill]>]>
        - if <context.click> == left:
            - define skills <proc[cc_flag].context[skills]>
            - define spare_points <element[10].sub[<[skills].values.sum>]>
            - if <[spare_points]> <= 0:
                - stop
            - if <[cur]> >= 5:
                - stop
            - define cur:++
            - playsound <player> sound:block_amethyst_cluster_place pitch:1
        - else if <context.click> == right:
            - if <[cur]> <= 0:
                - stop
            - define cur:--
            - playsound <player> sound:block_amethyst_cluster_place pitch:0.5
        - else:
            - stop
        - flag player character_cards.<player.flag[current_character]>.skills.<[skill]>:<[cur]>
        - run cc_open_skills_inv
