
mailbox_command:
    type: command
    debug: false
    name: mailbox
    usage: /mailbox
    description: Opens your mailbox.
    permission: dscript.mailbox
    script:
    - define mailbox <inventory[mailbox_<player.uuid>]||null>
    - if <[mailbox]> == null || <[mailbox].stacks||0> == 0:
        - narrate "<&[base]>Your mailbox is empty."
        - stop
    - narrate "<&[base]>You have <&[emphasis]><[mailbox].stacks><&[base]> items in your mailbox..."
    - inventory open d:<[mailbox]>

sendletter_command:
    type: command
    debug: false
    name: sendletter
    usage: /sendletter [player]
    description: Sends a letter to somebody.
    permission: dscript.sendletter
    script:
    - if !<player.has_flag[waymaker_verified]>:
        - narrate "<&[error]>You cannot use this command until you are verified."
        - stop
    - if <context.args.is_empty>:
        - narrate "<&[error]>/sendletter [player] <&[warning]>while holding a signed book to send that letter to somebody. They can view it in their <&[error]>/mailbox"
        - stop
    - if <player.item_in_hand.material.name> != written_book:
        - narrate "<&[error]>You must be holding a letter (signed book item) to send it."
        - stop
    - if <player.item_in_hand.book_author> != <player.name>:
        - narrate "<&[error]>Mail fraud is illegal! (You must be the author of a letter to send it through the mail)."
        - stop
    - define target <server.match_offline_player[<context.args.first>]||null>
    - if <[target]> == null:
        - narrate "<&[error]>Unknown player '<&[emphasis]><context.args.first><&[error]>'."
        - stop
    - define mailbox <inventory[mailbox_<[target].uuid>]||null>
    - if <[mailbox]> == null:
        - note <inventory[mailbox_inventory]> as:mailbox_<[target].uuid> player:<[target]>
        - define mailbox <inventory[mailbox_<[target].uuid>]||null>
    - if <[mailbox].empty_slots||0> == 0:
        - narrate "<&[error]>That mailbox is full."
        - stop
    - define item <player.item_in_hand.with[quantity=1]>
    - take iteminhand
    - give <[item]> to:<[mailbox]>
    - narrate "<&[base]>Sent your letter to <proc[proc_format_name].context[<[target]>|<player>]>."
    - if <[target].is_online>:
        - narrate "<&7><&o>You hear a flutter and see a puff of feathers. A carrier bird has left a letter in your <element[<&[clickable]>/mailbox].on_click[/mailbox].on_hover[Click To View Mail]>." targets:<[target]>
    - define pages <[item].book_pages.separated_by[|].strip_color.replace_text[<n>].with[\n]>
    - if <[pages].length> > 1000:
        - define pages <[pages].substring[1,1000]>...
    - define message "] <&lt>**`<player.name>`** **SENDS LETTER** to **`<[target].name>`** titled `<[item].book_title.proc[discord_escape]>` with `<[item].book_pages.size>` pages: `<[pages].proc[discord_escape]>`"
    - run discord_send_message def:<list[<server.flag[discord_logs_channel]>].include_single[<[message]>]>

mailbox_helper_world:
    type: world
    debug: false
    events:
        after player closes mailbox_inventory:
        - define mail <inventory[mailbox_<player.uuid>].stacks||0>
        - if <[mail]||0> == 0:
            - note remove as:mailbox_<player.uuid>
        on player drags in mailbox_inventory:
        - determine cancelled
        on player clicks in mailbox_inventory:
        - if <context.cursor_item.material.name||air> != air && <context.clicked_inventory.script.name||null> == mailbox_inventory:
            - determine cancelled
        after player joins:
        - define mail <inventory[mailbox_<player.uuid>].stacks||0>
        - if <[mail]> > 0:
            - narrate "<&[base]>You have <&[emphasis]><[mail]><&[base]> item(s) in your mailbox... type <element[<&[clickable]>/mailbox].on_click[/mailbox].on_hover[Click To Use]> to view them."

mailbox_inventory:
    type: inventory
    inventory: chest
    size: 27
    title: <player.name||Nobody>'s Mailbox

mailbox_item:
    type: item
    debug: false
    material: player_head
    display name: <&color[#FF0060]>Mailbox
    lore:
    - <&f>A placeable mailbox block.
    enchantments:
    - luck:1
    mechanisms:
        hides: all
        skull_skin: 1a78c18a-1d06-4ec9-a27f-c5138cc56852|eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvMzBhZTNkNTA2NDIzNzllOThhNjRkNGEwNmJiNGVmOTRhMzRiNDc4NmRhMzc4NGE5MzBkOTM0NmVjNjExM2QyIn19fQ==

mailbox_block_world:
    type: world
    debug: false
    events:
        on block drops player_head from breaking location_flagged:mailbox_block priority:10:
        - determine passively cancelled
        - wait 1t
        - drop mailbox_item <context.location>
        after player breaks player_head location_flagged:mailbox_block priority:10:
        - flag <context.location> mailbox_block:!
        on player right clicks player_head location_flagged:mailbox_block priority:10:
        - determine passively cancelled
        - wait 1t
        - execute as_player mailbox
        after player places mailbox_item priority:10:
        - if <context.location.material.name||air> == player_head:
            - flag <context.location> mailbox_block
