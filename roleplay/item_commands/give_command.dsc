give_command:
    type: command
    debug: false
    name: give
    usage: /give [player]
    description: Gives your held item directly to a player.
    permission: dscript.giveplayeritem
    script:
    - if !<player.has_flag[waymaker_verified]>:
        - narrate "<&[error]>You cannot use this command until you are verified."
        - stop
    - if <context.args.is_empty>:
        - narrate "<&[error]>/give [player] <&[warning]>- to give your held item to a player."
        - stop
    - define target <server.match_player[<context.args.first>]||null>
    - if <[target]> == null:
        - narrate "<&[error]>Unknown player '<&[emphasis]><context.args.first><&[error]>'."
        - stop
    - if <[target].world.name||?> != <player.world.name>:
        - narrate "<&[error]>That player is in a different world."
        - stop
    - if <[target].location.distance[<player.location>]> > 100:
        - narrate "<&[error]>That player is too far away to give an item to."
        - stop
    - define item <player.item_in_hand>
    - if <[item].material.name||air> == air:
        - narrate "<&[error]>You cannot /give air to somebody."
        - stop
    - if !<[target].inventory.can_fit[<[item]>]>:
        - narrate "<&[error]>That player does not have room in their inventory for that item."
        - stop
    - if !<[item].proc[bound_can_hold_proc].context[<[target]>]>:
        - narrate "<&[error]>This item is bound to <&[base]><[item].flag[bound_to].proc[proc_format_name].context[<player>]> <&[error]>and cannot be given to other players."
        - stop
    - take iteminhand quantity:<[item].quantity>
    - run give_safe_item def.item:<[item]> def.drop_extra:false def.inventory:<[target].inventory> save:given
    - define leftover_qty <entry[given].created_queue.definition[leftover_qty]>
    - if <[leftover_qty]> == <[item].quantity>:
        - narrate "<&[error]>That player does not have room in their inventory for that item."
        - run give_safe_item def.item:<entry[given].created_queue.definition[leftover]>
        - stop
    - if <[leftover_qty]> > 0:
        - narrate "<&[error]>Cannot give all items... <[leftover_qty].custom_color[emphasis]> returned back to you."
        - run give_safe_item def.item:<entry[given].created_queue.definition[leftover]>
    - narrate "<&[base]>Gave your <[item].proc[embedder_for_item]> to <proc[proc_format_name].context[<[target]>|<player>]>."
    - define player <player>
    - narrate "<proc[proc_format_name].context[<[player]>|<[target]>]><&[base]> gave you item: <[item].proc[embedder_for_item]>" targets:<[target]>
    - announce to_console "<&7>ITEM LOG PLAYER <player.name> at <player.location.simple||?> gave item to <[target].name> at <[target].location||?>: <proc[item_loggable_proc].context[<[item]>]>"
