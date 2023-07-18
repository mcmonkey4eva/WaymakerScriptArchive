invsee_command:
    type: command
    debug: false
    permission: dscript.invsee
    name: invsee
    usage: /invsee [player] (creative/survival/history:#)
    description: Views a player's inventory.
    aliases:
    - inventorysee
    - viewinv
    - seeinv
    - invview
    tab completions:
        1: <server.online_players.filter[has_flag[vanished].not].parse[name]>
        2: creative|survival|history<&co>
    script:
    - if <context.args.is_empty>:
        - narrate "<&[error]>/invsee [player] (creative/survival/history:#)"
        - stop
    - define target <server.match_offline_player[<context.args.first>]||null>
    - if <[target]> == null:
        - narrate "<&[error]>Unknown target player."
        - stop
    - if <list[creative|survival].contains[<context.args.get[2]||null>]> && <[target].gamemode||neither> != <context.args.get[2]||null>:
        - define inv <inventory[gamemode_<context.args.get[2]>_inv_record_for_<[target].uuid>]||null>
        - if <[inv]>:
            - narrate "<&[error]>That player does not have a <context.args.get[2]> inventory on record."
            - stop
        - narrate "<&[base]>Opening <context.args.get[2]> inventory of <proc[proc_format_name].context[<[target]>|<player>]>"
        - inventory open d:<[inv]>
        - stop
    - if <context.args.get[2].starts_with[history:]||false>:
        - define index <context.args.get[2].after[:]>
        - if !<[index].is_integer> || <[index]> < 1 || <[index]> > 20:
            - narrate "<&[error]>The history index must be an integer between 1 and 20."
            - stop
        - if !<[target].has_flag[inv_history]>:
            - narrate "<&[error]>That player does not have any inventory history on record."
            - stop
        - if <[index]> > <[target].flag[inv_history].size>:
            - narrate "<&[error]>That player has only <[target].flag[inv_history].size> inventories in history."
            - stop
        - narrate "<&[base]>Opening a copy of <proc[proc_format_name].context[<[target]>|<player>]>'s historical inventory from <[index]> inventory saves ago."
        - define temp_inv <inventory[invsee_temp_inv]>
        - adjust def:temp_inv contents:<[target].flag[inv_history].reverse.get[<[index]>]>
        - inventory open d:<[temp_inv]>
        - stop
    - narrate "<&[base]>Opening inventory of <proc[proc_format_name].context[<[target]>|<player>]>"
    - inventory open d:<[target].inventory>

invsee_temp_inv:
    type: inventory
    inventory: chest
    size: 45
