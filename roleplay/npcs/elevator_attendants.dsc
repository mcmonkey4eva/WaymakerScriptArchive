
aurum_dockside_elevator_attendant_assign:
    type: assignment
    debug: false
    actions:
        on assignment:
        - trigger name:click state:true
        - trigger name:chat state:true radius:5
        on click:
        - run npc_speak_near "def.message:Eh? Which floor?"
        - narrate "<&7>[You may ask go to the <element[bottom].custom_color[warning].click_chat[bottom]>, <element[center].custom_color[warning].click_chat[center]>, or <element[top].custom_color[warning].click_chat[top]>]"
        on chat:
        - if <context.message> in top:
            - run aurum_dockside_elevator_attendant_command def:3|top
        - else if <context.message> in center|middle:
            - run aurum_dockside_elevator_attendant_command def:2|center
        - else if <context.message> in bottom|ground:
            - run aurum_dockside_elevator_attendant_command def:1|bottom
        - else:
            - stop
        - run player_forcespeak_near "def.message:Take me to the <context.message>"
        - determine cancelled

aurum_dockside_elevator_attendant_command:
    type: task
    debug: false
    definitions: to|label
    script:
    - wait 1t
    - if <server.has_flag[restarting_soon]>:
        - run npc_speak_near "def.message:Eh, sorry, elevators out. Rat's in the gears again I thinks."
        - stop
    - define from <server.flag[aurum_elevator_floor]>
    - if <[from]> == <[to]>:
        - run npc_speak_near "def.message:Ye daft, mate? We're at t'e <[label]>."
        - stop
    - if <server.has_flag[aurum_elevator_moving]>:
        - run npc_speak_near "def.message:Hold on, mate! Wait til we've stopped moving before we change course."
        - stop
    - if !<polygon[aurum_dockside_elevator].shift[0,<npc.location.y.sub[76]>,0].contains[<player.location>]>:
        - run npc_speak_near "def.message:Er... y'wanna step onta' the elevator before we get goin'?"
        - stop
    - flag server aurum_elevator_floor:<[to]>
    - flag server aurum_elevator_moving expire:5m
    - run npc_speak_near "def.message:Aye, ye got it."
    - wait 1s
    - run npc_emote "def.message:The attendant grabs a control chain with a mighty heave, and pulls the gears to life."
    - playsound <npc.location> sound:block_chain_place
    - repeat 10:
        - playsound <npc.location> volume:0.5 pitch:<[value].mul[-0.05].add[1.0]> sound:block_chain_fall
        - wait <element[12].div[<[value]>].round_down>t
    - run npc_emote "def.message:After a moment of whirring and clacking, the elevator lurches to life. This mighty marvel of machinery lifts your weight with ease."
    - run elevator_move_task def.data:<script[testevator].parsed_key[aurum_dockside]> def.from_id:<[from]> def.to_id:<[to]> save:q
    - define q <entry[q].created_queue>
    - while <[q].is_valid>:
        - wait 2t
        - playsound <npc.location> volume:0.5 pitch:0.5 sound:block_chain_fall
    - repeat 10:
        - wait <[value].mul[1.2].round_down>t
        - playsound <npc.location> volume:0.5 pitch:<[value].mul[0.05].add[0.5]> sound:block_chain_fall
    - run npc_speak_near "def.message:Alroight, 'ere we are."
    - flag server aurum_elevator_moving:!
