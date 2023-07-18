fishing_block:
    type: world
    debug: false
    events:
        on player fishes item:
        - if !<context.item.material.name.is[==].to[air]||true>:
            - determine "caught:<list[cod|salmon|pufferfish|tropical_fish].random>[lore=<&7>A fish, caught by <&[emphasis]><player.name>]"
