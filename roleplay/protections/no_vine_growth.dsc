no_vine_growth_world:
    type: world
    debug: false
    events:
        on sugarcane|bamboo|cactus grows:
        - determine passively cancelled
        on block spreads type:sugarcane|bamboo|cactus:
        - determine passively cancelled
        on block spreads type:*vine*:
        - determine passively cancelled
        on block spreads type:*mushroom:
        - determine passively cancelled
