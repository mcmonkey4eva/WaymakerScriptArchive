signitem_command:
    type: command
    debug: false
    permission: dscript.signitem
    name: signitem
    usage: /signitem
    aliases:
    - sign
    - itemsign
    description: Signs your held item.
    script:
    - if !<player.item_in_hand.has_display>:
        - narrate "<&[error]>Only lore items can be signed (set at least a display name)."
        - stop
    - define item <player.item_in_hand>
    - if <[item].has_flag[lore_sign]>:
        - narrate "<&[warning]>Previous item signature '<[item].flag[lore_sign]><&[warning]>' removed."
        - adjust def:item lore:<[item].lore.remove[last]||<list>>
    - adjust def:item hides:all
    - define lore_sign "<&6>[<player.name> <util.time_now.format[yyyy/MM/dd]>]"
    - adjust def:item lore:<list[<[item].lore||<list>>].include[<[lore_sign]>]>
    - adjust def:item flag:lore_sign:<[lore_sign]>
    - adjust def:item flag:lore_sign_player:<player>
    - adjust def:item flag:lore_sign_time:<util.time_now>
    - inventory set d:<player.inventory> slot:<player.held_item_slot> o:<[item]>
    - narrate "<&[base]>Signed your held item."

sign_updater:
    type: task
    debug: false
    definitions: inventory
    script:
    - repeat <[inventory].size> as:slot:
        - define item <[inventory].slot[<[slot]>]>
        - if <[item].has_flag[lore_sign]>:
            - repeat next
        - if !<[item].has_lore>:
            - repeat next
        - define possible_sign <[item].lore.last.strip_color.trim>
        - if !<[possible_sign].starts_with[<&lb>]> || !<[possible_sign].ends_with[<&rb>]> || !<[possible_sign].contains[<&sp>]>:
            - repeat next
        - define signer_name <[possible_sign].after[<&lb>].before[<&sp>].trim.replace_text[,].replace_text[.]>
        - if <[signer_name]> == gochni:
            - define signer_name gochnipunchni
        - define signer <server.match_offline_player[<[signer_name]>]||null>
        - if <[signer]> == null || <[signer].name> != <[signer_name]>:
            - repeat next
        - define lore_sign "<&6>[<[signer].name> <util.time_now.format[yyyy/MM/dd]>]"
        - adjust def:item flag:lore_sign:<[lore_sign]>
        - adjust def:item flag:lore_sign_player:<[signer]>
        - adjust def:item flag:lore_sign_time:<util.time_now>
        - adjust def:item lore:<[item].lore.remove[last].include[<[lore_sign]>]>
        - inventory set o:<[item]> d:<[inventory]> slot:<[slot]>
