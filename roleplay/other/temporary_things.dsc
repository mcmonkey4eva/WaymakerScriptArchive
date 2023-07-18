# placeholder so the file can be left empty if needed
temporary_things:
    type: data

hunger_disable_world:
    type: world
    debug: false
    events:
        on delta time minutely:
        - foreach <server.online_players> as:player:
            - feed <[player]>
