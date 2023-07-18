
serverswap_survival_command:
    type: command
    debug: false
    name: survival
    usage: /survival
    description: Switch to the survival server.
    permission: dscript.server.survival
    script:
    - if <bungee.server> == survival:
        - narrate "<&[error]>You're already in the survival server."
        - stop
    - if !<player.has_flag[waymaker_verified]>:
        - narrate "<&[error]>You cannot use this command until you are verified."
        - stop
    - if !<bungee.list_servers.contains[survival]>:
        - narrate "<&[error]>The survival server is down."
        - stop
    - adjust <player> send_to:survival

serverswap_roleplay_command:
    type: command
    debug: false
    name: roleplay
    usage: /roleplay
    description: Switch to the roleplay server.
    permission: dscript.server.roleplay
    script:
    - if <bungee.server> == roleplay:
        - narrate "<&[error]>You're already in the roleplay server. Did you meant to switch to <&[warning]>/local <&[error]>chat?"
        - stop
    - if !<bungee.list_servers.contains[roleplay]>:
        - narrate "<&[error]>The roleplay server is down."
        - stop
    - adjust <player> send_to:roleplay
