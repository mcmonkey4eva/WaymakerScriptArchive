change_item_name_color_command:
    type: command
    debug: false
    name: itemnamecolor
    aliases:
    - changeitemnamecolor
    - coloritemname
    - recoloritemname
    usage: /itemnamecolor [#hex]
    description: Changes the color of the name of the item in your hand.
    permission: dscript.donor_itemnamecolor
    tab completions:
        1: <context.args.first.if_null[].proc[color_tabcomplete_proc]>
    script:
    - if <context.args.is_empty>:
        - narrate "<&[error]>/itemnamecolor [color] <&[base]>- set your held item's display name color. Use any RGB Hex Code, like <&[warning]>/itemnamecolor #00AABB <&[base]>... if confused, <element[<&9>click here for a color picker].click_url[https://www.google.com/search?q=color+picker]>"
        - narrate "<&[base]>Note that re-colored items will become bound to you, meaning you cannot give it to other players."
        - narrate "<&[base]>Or <&[error]>/itemnamecolor reset <&[base]>to reset the color to its default, and un-bind it."
        - stop
    - define item <player.item_in_hand>
    - if <[item].material.name> == air:
        - narrate "<&[error]>You must hold an item to rename it."
        - stop
    - if !<list[rare|uncommon|common|crafting].contains[<[item].flag[rarity]||common>]>:
        - narrate "<&[error]>You cannot change the color of items of this rarity."
        - stop
    - define name <[item].display.replace_text[<&r>]||null>
    - if <[name]> == null:
        - narrate "<&[error]>Only named items can be recolored."
        - stop
    - if !<[name].starts_with[<&ss>]>:
        - narrate "<&[error]>This item's name is colorless."
        - stop
    - if <[name].contains_text[<underline>]> || <[name].to_list.count[<&ss>]> > 7:
        - narrate "<&[error]>This item's name is too special to ruin by changing the color."
        - stop
    - inject set_color_command_prevalidate
    - if <[color].equals[reset]>:
        - if !<[item].has_flag[non_donor_nameplate]>:
            - narrate "<&[error]>This item has never been recolored, and therefore the color cannot be reset."
            - stop
        - adjust def:item display:<[item].flag[non_donor_nameplate]>
        - narrate "<&[base]>Item name reset to: <[item].display>"
        - adjust def:item flag:non_donor_nameplate:!
        - adjust def:item flag:bound_sources:<-:itemnamecolor
        - if <[item].flag[bound_sources].is_empty||true>:
            - adjust def:item flag:bound_sources:!
            - adjust def:item flag:bound_to:!
            - narrate "<&[base]>This item is no longer bound to you, and may now be given to other players if desired."
        - inventory set d:<player.inventory> slot:hand o:<[item]>
        - stop
    - if !<[item].proc[bound_can_hold_proc].context[<player>]>:
        - narrate "<&[error]>This item is bound to <&[base]><[item].flag[bound_to].proc[proc_format_name].context[<player>]><&[error]>. You must return it at once."
        - stop
    - define name <&color[<[color]>]><[name].strip_color>
    - if !<[item].has_flag[non_donor_nameplate]>:
        - adjust def:item flag:non_donor_nameplate:<[item].display>
    - define was_bound <[item].flag[bound_to].uuid.equals[<player.uuid>]||false>
    - if !<[was_bound]>:
        - adjust def:item flag:bound_to:<player>
    - if !<[item].flag[bound_sources].if_null[<list>].contains[itemnamecolor]>:
        - adjust def:item flag:bound_sources:->:itemnamecolor
    - adjust def:item display:<[name]>
    - inventory set d:<player.inventory> slot:hand o:<[item]>
    - narrate "<&[base]>Item name is now: <[name]>"
    - if !<[was_bound]>:
        - narrate "<&[base]>The item is now bound to you. You cannot give it to other players unless you use <&[error]>/itemnamecolor reset"
