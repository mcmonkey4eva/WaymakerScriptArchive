discord_join_world:
    type: world
    debug: false
    events:
        after player joins:
        - bungeerun roleplay fakejoin_for_relay
        - bungeerun roleplay bungee_send_data_out def:test_17
        #- adjust <player> resource_pack:example.com|A9834BD8D4455F28BD4A28C183E808C675AB3C0F
