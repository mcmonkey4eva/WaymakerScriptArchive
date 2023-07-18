hologram_command:
    type: command
    debug: false
    name: hologram
    usage: /hologram [add/remove] [text]
    description: Manages holograms.
    permission: dscript.hologram
    tab completions:
        1: add|remove
    script:
    - choose <context.args.first||null>:
        - case add:
            - if <context.args.size> == 1:
                - narrate "<&[error]>/hologram add [text]"
                - stop
            - spawn hologram_entity <player.location> save:newholo
            - adjust <entry[newholo].spawned_entity> custom_name:<context.raw_args.after[ ].parse_color>
            - narrate "<&[base]>Hologram spawned."
        - case remove:
            - define holotarget <player.location.find_entities[hologram_entity].within[15].first||null>
            - if <[holotarget]> == null:
                - narrate "<&[error]>No hologram found to remove."
                - stop
            - define name <[holotarget].custom_name>
            - remove <[holotarget]>
            - narrate "<&[base]>Hologram '<&[emphasis]><[name]><&[base]>' removed."
        - default:
            - narrate "<&[error]>/hologram add [text]"
            - narrate "<&[error]>/hologram remove <&[warning]>- removes the hologram closest to you"

holograms_world:
    type: world
    debug: false
    events:
        on hologram_entity damaged:
        - determine cancelled
        on player right clicks hologram_entity:
        - determine cancelled

hologram_entity:
    type: entity
    debug: false
    entity_type: armor_stand
    mechanisms:
        marker: true
        visible: false
        custom_name_visible: true
        invulnerable: true
