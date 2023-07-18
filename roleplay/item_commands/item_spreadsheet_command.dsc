item_spreadsheet_command:
    type: command
    name: item_spreadsheet
    aliases:
    - spreadsheet_item
    - spreadsheet
    - spreadsheetitem
    - itemspreadsheet
    debug: false
    usage: /item_spreadsheet
    description: Converts your held item into something wot fits on a spreadscript.
    permission: dscript.item_spreadsheet
    script:
    # Creator	ItemName	ItemType	Description	Rarity	RollBonus	Receiver	Status
    - define detail <empty>
    - foreach <player.inventory.list_contents.filter[has_flag[lore_sign_player]]> as:item:
        - define type (Type)
        - if <[item].material.name.ends_with[sword]>:
            - define type Weapon
        - else if <[item].material.name.ends_with[potion]>:
            - define type Drink
        - else if <[item].material.advanced_matches[*chestplate|*boots|*leggings|*helmet]>:
            - define type Armor
        - define detail <[detail]><[item].flag[lore_sign_player].name||Unknown><&chr[9]><[item].display.strip_color||Unknown><&chr[9]><[type]><&chr[9]><[item].lore.separated_by[ ].strip_color||None><&chr[9]><[item].flag[rarity]||Common><n>
    #- narrate "<[detail].replace[<&chr[9]>].with[    ]>"
    - ~discordmessage id:relaybot channel:<server.flag[discord_staff_channel]> "] item spreadsheet details for `<player.name>`" attach_file_name:item.txt attach_file_text:<[detail].replace[`].with[']>
    - narrate "<&[base]>Done, check discord #staff-chat-relay."
