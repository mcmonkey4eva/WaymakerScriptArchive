worlds_world:
    type: world
    debug: false
    events:
        # Extra worlds
        on server prestart:
        - createworld danary generate_structures:false
        - adjust <world[danary]> view_distance:15
        - createworld waymakerland generate_structures:false
        - adjust <world[waymakerland]> view_distance:15
        - createworld superflat generate_structures:false
        - adjust <world[superflat]> view_distance:20
        - createworld tutorial worldtype:FLAT generate_structures:false
        - createworld oceanevent generate_structures:false
        - createworld voidworld generator:denizen:void environment:the_end generate_structures:false
        #- createworld danary_test generator:denizen:void generate_structures:false
        # Slow time
        on system time secondly:
        #- repeat 4:
        #    - wait 5t
        - time <world[danary].time.add[1].mod[24000]>t danary
        # No mob spawning
        on mob spawns in:waymakerland|oceanevent|danary because breeding|build_*|chunk_gen|cured|default|egg|drowned|infection|jockey|lightning|natural|patrol|raid|reinforcements|silverfish_block|spawner|trap|village_*:
        - if !<list[tropical_fish|salmon|cod|shulker].contains[<context.entity.entity_type>]>:
            - determine cancelled
        on player death:
        - determine keep_inv
        on player right clicks block type:!*_door in:waymakerland:
        - if <player.flag[character_mode]> not in working|spectator:
            - determine cancelled
        on player right clicks entity in:waymakerland:
        - if <player.flag[character_mode]> not in working|spectator:
            - determine cancelled
        on player damages entity in:waymakerland:
        - if <player.flag[character_mode]> not in working|spectator:
            - determine cancelled
        on player left clicks block in:waymakerland:
        - if <player.flag[character_mode]> not in working|spectator:
            - determine cancelled
        #on time 5 in danary:
        # 500s = 30m
        #- wait 500s system
        #- announce "<&8>[!]<&7> As the sun can begin to be seen rising above the horizon, darkness retreats with it. A clanging of the clocktower's bells can be heard across Darroway. Dawn approaches!"
        #on time 18 in danary:
        # 500s = 30m
        #- wait 500s system
        #- announce "<&8>[!]<&7> The clocktower creaks to life as a loud clanging of bells can be heard across Darroway. The sun has set, and the night has begun."
