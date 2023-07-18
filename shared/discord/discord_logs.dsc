discord_logs_world:
    type: world
    debug: false
    events:
        on player teleports:
        - ratelimit <player> 5t
        - if <context.origin.simple> == <context.destination.simple>:
            - stop
        - define message "] <&lt>**`<player.name>`** **TELEPORTS** from `<context.origin.simple>` to `<context.destination.simple>`"
        - bungeerun roleplay discord_send_message def:<list[discord_logs_channel].include_single[<[message]>]>
        on player respawns priority:100:
        - define message "] <&lt>**`<player.name>`** **RESPAWNS** at `<context.location.simple>`"
        - bungeerun roleplay discord_send_message def:<list[discord_logs_channel].include_single[<[message]>]>
        on player edits book:
        - define pages <context.book.book_pages.separated_by[|].strip_color.replace_text[<n>].with[\n]>
        - define message "] <&lt>**`<player.name>`** **EDITS BOOK** with `<context.book.book_pages.size>` pages: `<[pages].proc[discord_escape]>`"
        - announce to_console <[message]>
        - if <[message].length> > 1650:
            - define message "<[message].substring[1,1600]>...` (Trimmed)"
        - bungeerun roleplay discord_send_message def:<list[discord_logs_channel].include_single[<[message]>]>
        on player signs book:
        - define pages <context.book.book_pages.separated_by[|].strip_color.replace_text[<n>].with[\n]>
        - define message "] <&lt>**`<player.name>`** **SIGNS BOOK** titled `<context.title.proc[discord_escape]||?>` with `<context.book.book_pages.size>` pages: `<[pages].proc[discord_escape]>`"
        - announce to_console <[message]>
        - if <[message].length> > 1650:
            - define message "<[message].substring[1,1600]>...` (Trimmed)"
        - bungeerun roleplay discord_send_message def:<list[discord_logs_channel].include_single[<[message]>]>
        on player death:
        - if <context.message||unknown> == null || <context.message.trim.length||0> == 0:
            - stop
        - define message "] <&lt>**`<player.name>`**<&gt> **dies** because **<context.cause||UNKNOWN>** with message `<context.message.strip_color||UNKNOWN>`"
        - bungeerun roleplay discord_send_message def:<list[discord_chat_channel].include_single[<[message]>]>
        on player prepares anvil craft item:
        - ratelimit <player.uuid><context.inventory.location.simple||unknown> 1m
        - define message "] <&lt>**`<player.name>`**<&gt> **uses an anvil** at `<context.inventory.location.simple||approx <player.location.simple>>`"
        - bungeerun roleplay discord_send_message def:<list[discord_logs_channel].include_single[<[message]>]>
        on command:
        - if <context.source_type> != player:
            - stop
        - define message "] <&lt>**`<player.name>`**<&gt> executes /<context.command.proc[discord_escape_simple_proc]> <context.raw_args.proc[discord_escape_simple_proc]>"
        - bungeerun roleplay discord_send_message def:<list[discord_logs_channel].include_single[<[message]>]>
        on player changes sign:
        - define message "] <&lt>**`<player.name>`**<&gt> edits sign at `<context.location.simple>` to: `<context.new.parse[proc[discord_escape]].separated_by[ ` / ` ]>`"
        - bungeerun roleplay discord_send_message def:<list[discord_logs_channel].include_single[<[message]>]>
