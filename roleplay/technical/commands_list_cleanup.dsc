commands_list_cleanup_world:
    type: world
    debug: false
    data:
        exclusions:
        # Exists for clickable usage only, tutorial_system
        - aurumtutorialinfo
    events:
        on player receives commands:
        - determine <context.commands.exclude[<script.parsed_key[data.exclusions]>]>
