pvp_blocker:
    type: world
    debug: false
    events:
        on player damages player in:danary priority:-10:
        - if !<context.damager.has_flag[pvp_access]> && !<context.entity.location.is_within[pvp_arena]>:
            - if <context.damager.in_group[founder]> && <context.entity.in_group[staff]>:
                - if <context.damager.flag[founder_staff_hit_cooldown]||0> < 3:
                    - flag <context.damager> founder_staff_hit_cooldown:++ duration:<context.damager.flag_expiration[founder_staff_hit_cooldown]||1h>
                    - playsound <player.location> ENTITY_PLAYER_ATTACK_SWEEP volume:1 pitch:0.1
                    - playsound <player.location> ENTITY_PLAYER_ATTACK_SWEEP volume:1 pitch:0.1
                    - determine 0.1
            - determine cancelled
        on player damages player in:oceanevent priority:-10:
        - if !<context.damager.has_flag[pvp_access]>:
            - determine cancelled
        on player damages player in:voidworld priority:-10:
        - if !<context.damager.has_flag[pvp_access]>:
            - determine cancelled
        on player damages player:
        - if <context.projectile||null> != null:
            - stop
        - define distance <context.damager.location.distance[<context.entity.location>]>
        - define message "<context.damager.name> at <context.damager.location.simple> damages <context.entity.name> at <context.entity.location.simple> for <context.damage> (yields <context.final_damage>) at distance <[distance]>"
        - announce to_console <[message]>
        - if <[distance]> > 3.5 && <context.damager.gamemode> != creative:
            - define message "Long-distance PvP hit: `<[message]>`"
            - run discord_send_message def:<list[<server.flag[discord_logs_channel]>].include_single[<[message]>]>
        on player death priority:-10:
        - if <context.damager.is_player||false>:
            - determine passively no_message
            - define recipients <player.location.find_players_within[40]>
            - define player <player>
            - define held_item <empty>
            - if <context.damager.item_in_hand.material.name> != air:
                - define held_item " using [<element[<&[emphasis]><context.damager.item_in_hand.display||<context.damager.item_in_hand.material.translated_name>>].on_hover[<context.damager.item_in_hand>].type[show_item]>]"
            - narrate "<proc[proc_format_name].context[<context.entity>|<player>]> was killed by <proc[proc_format_name].context[<context.damager>|<player>]><[held_item]>" t:<[recipients]> from:<player.uuid> per_player
            - if <[held_item].length> == 0:
                - define message "] <&lt>**`<player.name>`**<&gt> was **killed** by **`<context.damager.name>`** at `<player.location.simple>`"
            - else:
                - define message "] <&lt>**`<player.name>`**<&gt> was **killed** by **`<context.damager.name>`** at `<player.location.simple>` `<[held_item].proc[discord_escape]>`"
            - run discord_send_message def:<list[<server.flag[discord_local_channel]>].include_single[<[message]>]>
