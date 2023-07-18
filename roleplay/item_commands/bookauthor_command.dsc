bookauthor_command:
    type: command
    debug: false
    permission: dscript.bookauthor
    name: bookauthor
    usage: /bookauthor [name]
    aliases:
    - author
    description: Changes your held book item's author.
    script:
    - if <context.args.is_empty>:
        - narrate "<&[error]>/bookauthor [name]"
        - stop
    - if <player.item_in_hand.material.name> != written_book:
        - narrate "<&[error]>Only WRITTEN_BOOKs can have an author."
        - stop
    - inventory adjust d:<player.inventory> slot:<player.held_item_slot> book_author:<context.raw_args.parse_color>
    - narrate "<&[base]>Set book author to <&[emphasis]><context.raw_args.parse_color><&[base]>."

bookunsign_command:
    type: command
    debug: false
    permission: dscript.bookunsign
    name: bookunsign
    usage: /bookunsign
    aliases:
    - unsign
    description: Unsigns a held signed book item.
    script:
    - define item <player.item_in_hand>
    - if <[item].material.name> != written_book:
        - narrate "<&[error]>Only WRITTEN_BOOKs can be unsigned."
        - stop
    - define new_item <item[writable_book]>
    - adjust def:new_item book_pages:<[item].book_pages>
    - inventory set d:<player.inventory> slot:<player.held_item_slot> o:<[new_item]>
    - narrate "<&[base]>Unsigned your book."
