itemrarity_command:
    type: command
    debug: false
    permission: dscript.itemrarity
    name: itemrarity
    usage: /itemrarity [type]
    aliases:
    - rarity
    description: Sets the rarity of your held item.
    tab completions:
        1: <script[rarity_data].data_key[rarities]>
    script:
    - if !<player.item_in_hand.has_display>:
        - narrate "<&[error]>Only lore items can have rarities (set at least a display name)."
        - stop
    - define index <script[rarity_data].data_key[rarities].find[<context.args.first||null>]||-1>
    - if <[index]> == -1:
        - narrate "<&[error]>Unknown rarity. Allowed: <&[warning]><script[rarity_data].data_key[rarities].parse_tag[<script[rarity_data].parsed_key[colors.<[parse_value]>]><[parse_value]>].formatted>"
        - stop
    - define rarity <script[rarity_data].data_key[rarities].get[<[index]>]>
    - define item <player.item_in_hand>
    - if <[item].has_flag[rarity]>:
        - narrate "<&[warning]>Previous item rarity '<[item].flag[rarity]><&[warning]>' removed."
        - adjust def:item lore:<[item].lore.remove[last]||<list>>
    - if <[item].has_flag[lore_sign]>:
        - adjust def:item lore:<[item].lore.remove[last]||<list>>
    - adjust def:item hides:all
    - adjust def:item lore:<list[<[item].lore||<list>>].include[<script[rarity_data].parsed_key[colors.<[rarity]>]><&lb><[rarity]><&rb>]>
    - if <[item].has_flag[lore_sign]>:
        - adjust def:item lore:<list[<[item].lore||<list>>].include[<[item].flag[lore_sign]>]>
    - adjust def:item flag:rarity:<[rarity]>
    - inventory set d:<player.inventory> slot:<player.held_item_slot> o:<[item]>
    - narrate "<&[base]>Set your held item's rarity to <script[rarity_data].parsed_key[colors.<[rarity]>]><[rarity]><&[base]>."

rarity_data:
    type: data
    debug: false
    rarities:
    - Common
    - Uncommon
    - Rare
    - Epic
    - Legendary
    - Artifact
    - Crafting
    - Decoration
    colors:
        common: <&f>
        uncommon: <&color[#8bd54c]>
        rare: <&color[#4B9CF3]>
        epic: <&color[#BD4EEE]>
        legendary: <&6>
        artifact: <&color[#EC2D2D]>
        crafting: <&e>
        decoration: <&e>
