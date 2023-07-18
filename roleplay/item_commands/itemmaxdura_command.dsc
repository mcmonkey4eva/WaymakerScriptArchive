itemmaxdurability_command:
    type: command
    debug: false
    permission: dscript.itemmaxdurability
    name: itemmaxdurability
    usage: /itemmaxdurability [#]
    aliases:
    - itemmaxdura
    - maxdura
    - maxdurability
    - imaxdurability
    - imaxdura
    description: Changes your held tool's maximum durability.
    script:
    - if <player.item_in_hand.material.max_durability||0> > 1:
        - narrate "<&[base]>Your held item's native max durability is <&[emphasis]><player.item_in_hand.material.max_durability><&[base]>."
        - if <player.item_in_hand.has_flag[custom_max_durability]>:
            - narrate "<&[base]>Your held item's custom max durability is <&[emphasis]><player.item_in_hand.flag[custom_max_durability]><&[base]>."
    - else:
        - narrate "<&[error]>Your held item does not have durability."
        - stop
    - if <context.args.is_empty>:
        - narrate "<&[error]>/itemmaxdurability [#]"
        - stop
    - if !<context.args.first.is_integer> || <context.args.first> < 2:
        - narrate "<&[error]>Max durability must be at least 2 uses."
        - stop
    - inventory flag d:<player.inventory> slot:<player.held_item_slot> custom_max_durability:<context.args.first>
    - inventory flag d:<player.inventory> slot:<player.held_item_slot> custom_durability:0
    - inventory adjust d:<player.inventory> slot:<player.held_item_slot> durability:0
    - narrate "<&[base]>Set your held item's maximum durability to <&[emphasis]><context.args.first><&[base]>."

itemmaxdurability_world:
    type: world
    debug: false
    events:
        on player breaks block priority:100 with:item_flagged:custom_max_durability:
        - define current_dura <player.item_in_hand.flag[custom_durability].add[1]>
        - define max_dura <player.item_in_hand.flag[custom_max_durability]>
        - if <[current_dura]> >= <[max_dura]>:
            - animate <player> animation:BREAK_EQUIPMENT_MAIN_HAND
            - take iteminhand quantity:1
        - else:
            - inventory flag d:<player.inventory> slot:<player.held_item_slot> custom_durability:++
            - inventory adjust d:<player.inventory> slot:<player.held_item_slot> durability:<[current_dura].div[<[max_dura]>].mul[<player.item_in_hand.material.max_durability>].round_down.max[1]>
