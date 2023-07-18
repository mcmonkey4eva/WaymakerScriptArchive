
ticket:
    type: command
    name: ticket
    debug: false
    aliases:
    - tick
    - ti
    usage: /ticket help
    description: Controls tickets.
    permission: dscript.ticket
    tab completions:
        1: <tern[<player.has_permission[denizen.ticket.staff]>].pass[list|create|cancel|pick|yield|done|recent|top].fail[create|cancel]>
        2: <tern[<context.args.first.is[==].to[create]||false>].pass[event|build|help].fail[<server.online_players.filter[has_flag[vanished].not].parse[name]>]>
        default: <server.online_players.filter[has_flag[vanished].not].parse[name]>
    script:
    - choose <context.args.get[1]||help>:
        - case l list:
            - if <player.has_permission[denizen.ticket.staff]>:
                - narrate "<&[emphasis]><server.flag[tickets.waiting].size||0><&[base]> tickets..."
                - foreach <server.flag[tickets.waiting]||<list>> as:ticket:
                    - narrate "<&[base]>Ticket from <&[emphasis]><[ticket].get[author]><&[base]>: <&f><[ticket].get[message]>"
        - case c create:
            - if <context.args.size> < 3:
                - narrate "<&[error]>/ticket create [type] [message]"
                - narrate "<&[error]>Types: <&[warning]>build, event, help"
                - stop
            - define message <context.raw_args.after[ ].after[ ]||>
            - if <[message].length> < 2:
                - narrate "<&[error]>/ticket create [type] [message]"
                - narrate "<&[error]>Types: <&[warning]>build, event, help"
                - stop
            - if !<server.flag[tickets.waiting].filter[get[author_player].is[==].to[<player>]].is_empty||true>:
                - narrate "<&[error]>You already have a ticket waiting. If this sounds wrongs, you can <&[warning]>/ticket cancel"
                - stop
            - if !<server.flag[tickets.picked].filter[get[author_player].is[==].to[<player>]].is_empty||true>:
                - narrate "<&[error]>You already have a ticket being handled by staff. If this sounds wrongs, you can <&[warning]>/ticket cancel"
                - stop
            - if !<list[build|event|help].contains[<context.args.get[2]>]>:
                - narrate "<&[error]>Unknown ticket type. Types: <&[warning]>build, event, help"
                - stop
            - flag server tickets.waiting:->:<map.with[author_player].as[<player>].with[author].as[<player.name>].with[type].as[<context.args.get[2]>].with[message].as[<[message]>].with[created].as[<util.time_now>]>
            - narrate "<&[base]>Created ticket."
            - narrate "<&[base]>Player <&[emphasis]><player.name> <&[base]>created a <&[emphasis]><context.args.get[2]> <&[base]>ticket: <&f><[message]>" targets:<server.online_players.filter[has_permission[denizen.ticket.staff]]>
            - if <[message].length> > 1500:
                - define message <[message].substring[1,400]>...
            - ~discordmessage id:relaybot channel:<server.flag[discord_ticket_channel]> "`<player.name>` **created** a **<context.args.get[2]>** ticket (at `<player.location.simple||?>`): `<[message].proc[discord_escape]>`<n>**REPLY to this message to send that player a message**" save:newmessage
            - define sentId <entry[newmessage].message.id||<entry[newmessage].message_id>>
            - flag server tickets.discord_ids.<[sentId]>:<player> duration:12h
            - flag player discord_ticket_ids:!|:<[sentId]>
            - flag player discord_repliable:!
        - case cancel:
            - if !<server.flag[tickets.waiting].filter[get[author_player].is[==].to[<player>]].is_empty||true>:
                - flag server tickets.waiting:!|:<server.flag[tickets.waiting].filter[get[author_player].is[!=].to[<player>]]>
                - narrate "<&[base]>Waiting ticket cancelled."
                - narrate "<&[emphasis]><player.name> <&[base]>cancelled their waiting ticket." targets:<server.online_players.filter[has_permission[denizen.ticket.staff]]>
                - ~discordmessage id:relaybot channel:<server.flag[discord_ticket_channel]> "`<player.name>` **cancelled** their waiting ticket"
            - else if !<server.flag[tickets.picked].filter[get[author_player].is[==].to[<player>]].is_empty||true>:
                - flag server tickets.picked:!|:<server.flag[tickets.picked].filter[get[author_player].is[!=].to[<player>]]>
                - define picker <server.online_players.filter[has_flag[ticket_picked]].filter[flag[ticket_picked].get[author_player].is[==].to[<player>]].first||null>
                - if <[picker]> != null:
                    - flag <[picker]> ticket_picked:!
                - narrate "<&[base]>Already-picked ticket cancelled."
                - narrate "<&[emphasis]><player.name> <&[base]>cancelled their ticket that was picked by <&[emphasis]><[picker].name||unknown><&[base]>." targets:<server.online_players.filter[has_permission[denizen.ticket.staff]]>
                - ~discordmessage id:relaybot channel:<server.flag[discord_ticket_channel]> "`<player.name>` **cancelled** their ticket that was picked by `<[picker].name||unknown>`"
            - else:
                - narrate "<&[error]>You don't have any waiting tickets."
            - foreach <player.flag[discord_ticket_ids]||<list>> as:id:
                - flag server tickets.discord_ids.<[id]>:!
            - flag player discord_ticket_ids:!
            - flag player discord_repliable:!
        - case p pick:
            - if <player.has_permission[denizen.ticket.staff]>:
                - if <player.has_flag[ticket_picked]>:
                    - narrate "<&[error]>You already have a ticket picked. Complete or yield it before picking a new one."
                    - stop
                - define target <context.args.get[2]||null>
                - if <[target]> == null:
                    - narrate "<&[error]>/ticket pick [name]"
                    - stop
                - define matches <server.flag[tickets.waiting].filter[get[author].is[==].to[<[target]>]]||<list>>
                - if <[matches].is_empty>:
                    - narrate "<&[error]>Unknown ticket creator name."
                    - stop
                - flag server tickets.picked:->:<[matches].first>
                - flag server tickets.waiting:<-:<[matches].first>
                - flag player ticket_picked:<[matches].first>
                - define ticket <[matches].first>
                - narrate "<&[base]>Ticket from <&[emphasis]><[ticket].get[author]><&[base]> picked: <[ticket].get[message]>"
                - narrate "<&[base]>Staff member <&[emphasis]><player.name> <&[base]>picked the ticket from <&[emphasis]><player.flag[ticket_picked].get[author]><&[base]>." targets:<server.online_players.filter[has_permission[denizen.ticket.staff]]>
                - if <[ticket].get[author_player].is_online>:
                    - narrate "<&[base]>Your ticket was picked by <&[emphasis]><player.name>" targets:<[ticket].get[author_player]>
                - ~discordmessage id:relaybot channel:<server.flag[discord_ticket_channel]> "`<[ticket].get[author]>`'s ticket was **PICKED** by staff member `<player.name>`"
        - case y yield:
            - if <player.has_permission[denizen.ticket.staff]>:
                - if !<player.has_flag[ticket_picked]>:
                    - narrate "<&[error]>You don't have any ticket currently picked."
                    - stop
                - narrate "<&[base]>Ticket yielded."
                - define authorname <player.flag[ticket_picked].get[author]>
                - define type <player.flag[ticket_picked].get[type]>
                - narrate "<&[base]>Staff member <&[emphasis]><player.name> <&[base]>yielded a <&[emphasis]><[type]> <&[base]>ticket from <&[emphasis]><[authorname]><&[base]>: <&f><player.flag[ticket_picked].get[message]>" targets:<server.online_players.filter[has_permission[denizen.ticket.staff]]>
                - if <player.flag[ticket_picked].get[author_player].is_online>:
                    - narrate "<&[base]>Your ticket was yielded by <&[emphasis]><player.name>" targets:<player.flag[ticket_picked].get[author_player]>
                - flag server tickets.waiting:->:<player.flag[ticket_picked]>
                - flag server tickets.picked:<-:<player.flag[ticket_picked]>
                - flag player ticket_picked:!
                - ~discordmessage id:relaybot channel:<server.flag[discord_ticket_channel]> "`<[authorname]>`'s **<[type]>** ticket was **YIELDED** by staff member `<player.name>`"
        - case d done:
            - if <player.has_permission[denizen.ticket.staff]>:
                - if !<player.has_flag[ticket_picked]>:
                    - narrate "<&[error]>You don't have any ticket currently picked."
                    - stop
                - narrate "<&[base]>Ticket completed."
                - define authorname <player.flag[ticket_picked].get[author]>
                - define author <player.flag[ticket_picked].get[author_player]>
                - if <[author].is_online>:
                    - narrate "<&[base]>Your ticket was completed by <&[emphasis]><player.name>" targets:<[author]>
                - flag server tickets.completed:->:<player.flag[ticket_picked].with[completer].as[<player.name>].with[time].as[<util.time_now>]>
                - flag server tickets.completed_by.<player.uuid>:++
                - flag server tickets.picked:<-:<player.flag[ticket_picked]>
                - flag player ticket_picked:!
                - ~discordmessage id:relaybot channel:<server.flag[discord_ticket_channel]> "`<[authorname]>`'s ticket was **COMPLETED** by staff member `<player.name>`"
                - foreach <[author].flag[discord_ticket_ids]||<list>> as:id:
                    - flag server tickets.discord_ids.<[id]>:!
                - flag <[author]> discord_ticket_ids:!
                - flag <[author]> discord_repliable:!
        - case recent:
            - if <player.has_permission[denizen.ticket.staff]>:
                - foreach <server.flag[tickets.completed]||<list>> as:ticket:
                    - narrate "<&7><[ticket].get[time].format> <&[base]>Ticket from <&[emphasis]><[ticket].get[author]><&[base]>, completed by <&[emphasis]><[ticket].get[completer]><&[base]>: <&f><[ticket].get[message]>"
        - case top:
            - if <player.has_permission[denizen.ticket.staff]>:
                - define tickets <server.flag[tickets.completed_by].sort_by_value>
                - foreach <[tickets].keys.reverse.get[1].to[10]> as:key:
                    - narrate "<&[emphasis]><player[<[key]>].name> <&[base]>has completed <&[emphasis]><[tickets].get[<[key]>]> <&[base]>ticket(s)."
        - case reply:
            - if !<context.args.get[2].is_integer||false>:
                - narrate "<&[error]>Incorrect command usage. Refer to <&[warning]>/ticket"
                - stop
            - if !<player.flag[discord_repliable].contains[<context.args.get[2]>]>:
                - narrate "<&[error]>Unknown ticket reply ID."
                - stop
            - define message <context.raw_args.after[<context.args.get[2]>].trim.proc[discord_escape]>
            - ~discordmessage id:relaybot channel:<server.flag[discord_ticket_channel]> reply:relaybot,<server.flag[discord_ticket_channel]>,<context.args.get[2]> "`<player.name>` replies: `<[message]>`"
            - narrate "<&[base]>Sent ticket reply: <&f><[message]>"
        - default:
            - if <player.has_permission[denizen.ticket.staff]>:
                - narrate "<&[warning]>/ticket list - <&[error]>Lists all tickets."
                - narrate "<&[warning]>/ticket pick [name] - <&[error]>Picks the ticket for the given playername, locking it to yourself."
                - narrate "<&[warning]>/ticket yield - <&[error]>Yields the ticket you picked back for other staff to handle."
                - narrate "<&[warning]>/ticket done - <&[error]>Marks the ticket you picked as done and handled."
                - narrate "<&[warning]>/ticket top - <&[error]>lists stats about ticket completions."
                - narrate "<&[warning]>/ticket recent - <&[error]>lists the tickets done this week."
            - narrate "<&[warning]>/ticket create [type] [message] - <&[error]>Creates a ticket for staff to view."
            - narrate "<&[warning]>/ticket cancel - <&[error]>Cancel your existing ticket."
            - if <player.has_flag[ticket_picked]>:
                - narrate "Ticket from <&[emphasis]><player.flag[ticket_picked].get[author]><&[base]>: <&f><player.flag[ticket_picked].get[message]>"

ticket_world:
    type: world
    debug: false
    events:
        on player quits:
        - if <player.has_flag[ticket_picked]>:
            - define authorname <player.flag[ticket_picked].get[author]>
            - define author <player.flag[ticket_picked].get[author_player]>
            - define type <player.flag[ticket_picked].get[type]>
            - narrate "<&[base]>Staff member <&[emphasis]><player.name> <&[error]>AUTO<&[base]> yielded a <&[emphasis]><player.flag[ticket_picked].get[type]> <&[base]>ticket from <&[emphasis]><[authorname]><&[base]>: <&f><player.flag[ticket_picked].get[message]>" targets:<server.online_players.filter[has_permission[denizen.ticket.staff]]>
            - flag server tickets.waiting:->:<player.flag[ticket_picked]>
            - flag server tickets.picked:<-:<player.flag[ticket_picked]>
            - flag player ticket_picked:!
            - flag <[author]> discord_repliable:!
            - ~discordmessage id:relaybot channel:<server.flag[discord_ticket_channel]> "`<[authorname]>`'s **<[type]>** ticket was **AUTO YIELDED** by staff member `<player.name>` due to logging off"
            - foreach <[author].flag[discord_ticket_ids]||<list>> as:id:
                - flag server tickets.discord_ids.<[id]>:!
            - flag <[author]> discord_ticket_ids:!
        - define matches <server.flag[tickets.waiting].filter[get[author_player].is[==].to[<player>]]||<list>>
        - if !<[matches].is_empty>:
            - flag server tickets.waiting:<-:<[matches].first>
            - narrate "<&[emphasis]><player.name> <&[base]>AUTO cancelled their ticket due to logging off." targets:<server.online_players.filter[has_permission[denizen.ticket.staff]]>
            - ~discordmessage id:relaybot channel:<server.flag[discord_ticket_channel]> "`<player.name>` **AUTO cancelled** their ticket by logging off"
            - foreach <player.flag[discord_ticket_ids]||<list>> as:id:
                - flag server tickets.discord_ids.<[id]>:!
            - flag player discord_ticket_ids:!
            - flag player discord_repliable:!
        on delta time minutely every:5:
        - define waiting <server.flag[tickets.waiting].filter[get[created].from_now.in_minutes.is[more].than[10]]||<list>>
        - if !<[waiting].is_empty>:
            - narrate "<&[base]>There are <&[emphasis]><[waiting].size> <&[base]>waiting ticket(s)." targets:<server.online_players.filter[has_permission[denizen.ticket.staff]]>
        - foreach <server.online_players_flagged[ticket_picked].filter[has_permission[denizen.ticket.staff]]>:
            - narrate "<&[base]>You are handling a ticket from <&[emphasis]><[value].flag[ticket_picked].get[author]><&[base]>..." targets:<[value]>
        on discord message received channel:123:
        - if <context.new_message.author.is_bot>:
            - stop
        - if <context.new_message.replied_to||null> == null:
            - stop
        - define relevant <server.flag[tickets.discord_ids.<context.new_message.replied_to.id>]||null>
        - if <[relevant]> == null:
            - stop
        - if !<[relevant].is_online>:
            - stop
        - flag <[relevant]> discord_repliable:->:<context.new_message.id>
        - narrate "<&6>[DISCORD TICKET REPLY] <&f><&lt><context.new_message.author.name><&gt><&co> <context.new_message.text_display><n><element[<&[clickable]>Click Here To Reply].on_hover[Click To Reply].on_click[/ticket reply <context.new_message.id> ].type[suggest_command]>" targets:<[relevant]>
