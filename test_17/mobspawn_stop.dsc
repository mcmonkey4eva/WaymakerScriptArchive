mobspawnstop_world:
    type: world
    debug: false
    events:
        on entity spawns:
        - if <list[pig|cow|sheep|fox|horse|llama].contains[<context.entity.entity_type>]>:
            - announce test<context.entity.entity_type><context.reason>
        on mob spawns in:test17 because breeding|build_*|chunk_gen|cured|default|egg|drowned|infection|jockey|lightning|natural|patrol|raid|reinforcements|silverfish_block|spawner|trap|village_*:
        #- announce mob<context.entity.entity_type>
        - if !<list[tropical_fish|salmon|cod|shulker].contains[<context.entity.entity_type>]>:
            - determine cancelled
