publicunlock_command:
    type: command
    name: publicunlock
    debug: false
    usage: /publicunlock
    description: Gives you a publicunlock tool.
    permission: dscript.publicunlock
    script:
    - run give_safe_item def.item:publicunlock_tool
    - narrate "<&[base]>Gave a <&[emphasis]><element[Public Unlock Tool].on_hover[<script[publicunlock_tool].parsed_key[lore].separated_by[<n>]>]><&[base]>."

publicunlock_tool:
    type: item
    material: name_tag
    display name: <&[emphasis]>Public Unlock Tool
    lore:
    - <&[emphasis]>Left click<&[base]> a block to public-unlock it.
    - <&[emphasis]>Right click<&[base]> a block to relock it.
    enchantments:
    - luck_of_the_sea:1
    mechanisms:
        hides: all

publicunlock_tool_world:
    type: world
    debug: false
    events:
        on player right clicks entity with:publicunlock_tool priority:-10:
        - determine cancelled
        on player left clicks block with:publicunlock_tool priority:-10:
        - determine passively cancelled
        - if <context.location||null> == null:
            - stop
        - wait 1t
        - if <context.location.has_flag[public_unlocked]>:
            - narrate "<&[error]>That block is already publicly unlocked."
            - stop
        - flag <context.location> public_unlocked
        - narrate "<&[base]>Publicly unlocked the <&[emphasis]><context.location.material.translated_name><&[base]> at <&[emphasis]><context.location.simple><&[base]>."
        on player right clicks block with:publicunlock_tool priority:-10:
        - determine passively cancelled
        - if <context.location||null> == null:
            - stop
        - wait 1t
        - if !<context.location.has_flag[public_unlocked]>:
            - narrate "<&[error]>That block isn't publicly locked."
            - stop
        - flag <context.location> public_unlocked:!
        - narrate "<&[base]>Unlocked the <&[emphasis]><context.location.material.translated_name><&[base]> at <&[emphasis]><context.location.simple><&[base]>."
        on player breaks block priority:-5 location_flagged:public_unlocked:
        - flag <context.location> public_unlocked:!
        after player places block priority:100 location_flagged:public_unlocked:
        - flag <context.location> public_unlocked:!
        - narrate "<&[error]>Glitched public-unlock removed."
        - announce to_console "GLITCHED public-unlock at <context.location.simple> broken by place."
        # Prevent misuse
        on player drops publicunlock_tool:
        - remove <context.entity>
        on player clicks in inventory with:publicunlock_tool:
        - inject <script> path:abuse_prevention_click
        on player drags publicunlock_tool in inventory:
        - inject <script> path:abuse_prevention_click
    abuse_prevention_click:
        - if <context.inventory.inventory_type> == player:
            - stop
        - if <context.inventory.inventory_type> == crafting:
            - if <context.raw_slot||<context.raw_slots.numerical.first>> >= 6:
                - stop
        - determine passively cancelled
        - inventory update
