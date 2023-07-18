event_feedback_command:
    type: command
    name: eventfeedback
    debug: false
    usage: /eventfeedback (event type) (range # or player names)
    description: Asks for players in range to give feedback on event.
    permission: dscript.eventfeedback
    tab completions:
        1: crafting|hunting|story|major
        default: <server.online_players.filter[has_flag[vanished].not].parse[name].include[1|5|10|15|50|100]>
    script:
    - if <context.args.size> < 2:
        - narrate "<&[error]>/eventfeedback (event type) (range # or player names)"
        - narrate "<&[base]>For example: <&[warning]>/eventfeedback crafting 10"
        - narrate "<&[base]>Or: <&[warning]>/eventfeedback story Samwych Draconiix23 Spacebobo"
        - stop
    - define targets <list>
    - foreach <context.args.get[2].to[last]> as:arg:
        - if <[arg].is_integer>:
            - define targets <[targets].include[<player.location.find_players_within[<[arg]>]>].deduplicate>
        - else:
            - define new_target <server.match_offline_player[<[arg]>]||null>
            - if <[new_target]> == null:
                - narrate "<&[error]>Unknown player <&[emphasis]><[arg]>"
                - stop
            - define targets <[targets].include[<[new_target]>].deduplicate>
    - define targets <[targets].exclude[<player>]>
    - if <[targets].is_empty>:
        - narrate "<&[error]>Nobody to request feedback from."
        - stop
    - flag <[targets]> "event_feedback_request:type `<context.args.get[1].proc[discord_escape]>` from `<player.name>`" expire:48h
    - flag <[targets]> event_feedback_host:<player> expire:50h
    - flag <[targets]> event_feedback_type:<context.args.get[1]> expire:50h
    - foreach <[targets].filter[is_online]> as:player:
        - run show_event_feedback_request player:<[player]>

show_event_feedback_request:
    type: task
    debug: false
    script:
    - narrate "<&[base]>======= Event Feedback ======="
    - narrate "<&[base]>Your feedback on the last <player.flag[event_feedback_type]> event you took part in (hosted by <proc[proc_format_name].context[<player.flag[event_feedback_host]>|<player>]>) has been requested. Please rate the event overall on a scale of <&[emphasis]>1 to 5 stars<&[base]> by clicking the star buttons below. You will be given a command to enter automatically.<n><&[emphasis]>If you have any additional comments, please type them into the command line before pressing enter.<n><&[warning]>(Once you hit enter, your rating is locked in)"
    - define star <element[<&f>e].font[waymaker:waymaker]>
    - narrate "           <[star].on_hover[1/5 stars (awful)].on_click[/giveeventfeedback 1 ].type[SUGGEST_COMMAND]>   <[star].on_hover[2/5 stars (bad)].on_click[/giveeventfeedback 2 ].type[SUGGEST_COMMAND]>   <[star].on_hover[3/5 stars (average)].on_click[/giveeventfeedback 3 ].type[SUGGEST_COMMAND]>   <[star].on_hover[4/5 stars (good)].on_click[/giveeventfeedback 4 ].type[SUGGEST_COMMAND]>   <[star].on_hover[5/5 stars (amazing)].on_click[/giveeventfeedback 5 ].type[SUGGEST_COMMAND]>"

event_feedback_request_world:
    type: world
    debug: false
    events:
        after player joins flagged:event_feedback_request:
        - run show_event_feedback_request

giveeventfeedback_command:
    type: command
    debug: false
    name: giveeventfeedback
    usage: /giveeventfeedback (stars) (comments)
    description: Gives feedback on an event, when requested.
    permission: dscript.giveeventfeedback
    tab completions:
        default: <list>
    script:
    - if <player.flag[character_mode]> != ic:
        - narrate "<&[error]>You must be IC to use eventfeedback."
        - stop
    - if !<player.has_flag[event_feedback_request]>:
        - narrate "<&[error]>Event feedback is not currently requested from you. If you have additional comments about a recent event to share, speak directly to the event's DM or to staff."
        - stop
    - if <context.args.is_empty> || !<list[1|2|3|4|5].contains[<context.args.get[1]>]>:
        - narrate "<&[error]>Please use the clickable star buttons to give feedback."
        - stop
    - run discord_send_message def.channel:123 "def.message:**Event Feedback** from `<player.name>` regarding event <player.flag[event_feedback_request]>: **<context.args.get[1]>** stars, full input: `<context.raw_args.proc[discord_escape]>`"
    - flag player event_feedback_request:!
    - narrate "<&[base]>Thank you, your rating has been logged.<n><&[base]>Received <&6>5 TG<&[base]>."
    - money give quantity:5
    - run eco_log_gain def.amount:5 "def.reason:gave event feedback"
