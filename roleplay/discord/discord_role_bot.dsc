discord_role_bot_make_pronoun_post:
    type: task
    debug: false
    script:
    - define descrip "Choose a pronoun role by clicking one of the reactions below.<n>:man_gesturing_ok: for he/him, :woman_gesturing_ok: for she/her, :person_gesturing_ok: for they/them"
    - ~discordmessage id:relaybot channel:123 <discord_embed.with[title].as[Pronoun Choice].with[description].as[<[descrip]>]> save:msg
    - ~discordreact id:relaybot add channel:123 message:<entry[msg].message.id> reaction:🙆‍♀️
    - ~discordreact id:relaybot add channel:123 message:<entry[msg].message.id> reaction:🙆‍♂️
    - ~discordreact id:relaybot add channel:123 message:<entry[msg].message.id> reaction:🙆
    - flag server discord_role_selection_message:<entry[msg].message.id>

discord_role_bot_make_update_post:
    type: task
    debug: false
    script:
    - define descrip "Choose any optional notification roles to be pinged for related announcements.<n><n>Click :video_game: to be notified about **Community Events** (movie nights, game nights, etc).<n>Click :loudspeaker: to be notified about requests for **Player Feedback**."
    - ~discordmessage id:relaybot channel:123 <discord_embed.with[title].as[Notification Role Choice].with[description].as[<[descrip]>]> save:msg
    - ~discordreact id:relaybot add channel:123 message:<entry[msg].message.id> reaction:🎮
    - ~discordreact id:relaybot add channel:123 message:<entry[msg].message.id> reaction:📢
    - flag server discord_update_role_selection_message:<entry[msg].message.id>

# NOTE: Disabled for now
discord_role_bot_make_pingable_post:
    type: task
    debug: false
    script:
    - define descrip "Choose any character roles to be pinged for related in-character alerts.<n>Click :guard: for the **Guardsman** role.<n>Click :health_worker: for the **Healer** role."
    - ~discordmessage id:relaybot channel:123 <discord_embed.with[title].as[Character Role Choice].with[description].as[<[descrip]>]> save:msg
    - ~discordreact id:relaybot add channel:123 message:<entry[msg].message.id> reaction:💂
    - ~discordreact id:relaybot add channel:123 message:<entry[msg].message.id> reaction:🧑‍⚕️
    #- ~discordreact id:relaybot add channel:123 message:<entry[msg].message.id> reaction:🔨
    #- ~discordreact id:relaybot add channel:123 message:<entry[msg].message.id> reaction:⚔️
    - flag server discord_pingable_role_selection_message:<entry[msg].message.id>

discord_role_bot_make_optout_post:
    type: task
    debug: false
    script:
    - define descrip "Choose any default notification roles to **OPT OUT OF**. If you click these reacts you **WON'T** be notified!<n>(This is the opposite of the other role-selection buttons.)<n>Click :bell: to HIDE notifications about **Server Updates**.<n>Click :book: to HIDE notifications about **Roleplay Events**."
    - ~discordmessage id:relaybot channel:123 <discord_embed.with[title].as[Opt-Out of Default Roles].with[description].as[<[descrip]>]> save:msg
    - ~discordreact id:relaybot add channel:123 message:<entry[msg].message.id> reaction:🔔
    - ~discordreact id:relaybot add channel:123 message:<entry[msg].message.id> reaction:📖
    - flag server discord_optout_role_selection_message:<entry[msg].message.id>

discord_role_bot_monitor:
    type: world
    debug: false
    injection:
        get_role:
        - define mode add
        - define altMode remove
        - if <context.message.id> == <server.flag[discord_role_selection_message]>:
            - if <context.reaction.id> == 🙆‍♀️:
                # She/Her
                - define role 123
            - else if <context.reaction.id> == 🙆‍♂️:
                # He/Him
                - define role 123
            - else if <context.reaction.id> == 🙆:
                # They/Them
                - define role 123
            - else:
                - stop
        - else if <context.message.id> == <server.flag[discord_update_role_selection_message]>:
            - if <context.reaction.id> == 🎮:
                # Games
                - define role 123
            - else if <context.reaction.id> == 📢:
                # Feedback
                - define role 123
            - else:
                - stop
        - else if <context.message.id> == <server.flag[discord_pingable_role_selection_message]>:
            - if <context.reaction.id> == 💂:
                # Guardsman
                - define role 123
            - else if <context.reaction.id> == 🧑‍⚕️:
                # Healer
                - define role 123
        - else if <context.message.id> == <server.flag[discord_optout_role_selection_message]>:
            - define mode remove
            - define altMode add
            - if <context.reaction.id> == 🔔:
                # Updates
                - define role 123
            - else if <context.reaction.id> == 📖:
                # IC Events
                - define role 123
        - else:
            - stop
    events:
        on discord message reaction added for:relaybot:
        - inject <script> path:injection.get_role
        - ~discord id:relaybot <[mode]>_role user:<context.user> role:<[role]> group:123
        on discord message reaction removed for:relaybot:
        - inject <script> path:injection.get_role
        - ~discord id:relaybot <[altMode]>_role user:<context.user> role:<[role]> group:123
        after discord user joins:
        - wait 5s
        - define cur_roles <context.user.roles[relaybot,123]||null>
        - if <[cur_roles]> == null:
            - stop
        # Updates
        - ~discord id:relaybot add_role user:<context.user> role:123 group:123
        # Events
        - ~discord id:relaybot add_role user:<context.user> role:123 group:123
