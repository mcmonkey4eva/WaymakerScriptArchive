discord_bridge_world:
    type: world
    debug: false
    events:
        on discord message received group:123|123:
        #- stop
        - if <context.new_message.author.is_bot>:
            - stop
        - if !<context.new_message.text.starts_with[!link]>:
            - stop
        - define name <context.new_message.text.after[!link].trim>
        - announce to_console "Attempted link from <context.new_message.author.id>/<context.new_message.author.name> to <[name]>"
        - if <[name].length> == 0:
            - ~discordmessage id:relaybot channel:<context.channel> "] **Bridge Bot**: You need to specify a minecraft username to link, like `!link notch`"
            - stop
        - define match <server.match_player[<[name]>]||null>
        - if <[match]> == null || <[match].name||null> != <[name]>:
            - ~discordmessage id:relaybot channel:<context.channel> "] **Bridge Bot**: That account isn't valid or doesn't seem to be online. You must log in to minecraft to link your account."
            - stop
        - if <server.has_flag[discord_bridges.<context.new_message.author.id>]>:
            - define linked <server.flag[discord_bridges.<context.new_message.author.id>]>
            - if <[linked].uuid> == <[match].uuid>:
                - ~discordmessage id:relaybot channel:<context.channel> "] **Bridge Bot**: Your account is already linked."
                - stop
            - run discord_clear_link_roles_task player:<[linked]> def:<context.new_message.author.id>
            - flag server discord_bridges.<context.new_message.author.id>:!
            - flag <[linked]> discord_account:!
            - ~discordmessage id:relaybot channel:<context.channel> "] **Bridge Bot**: Your Discord account was already linked to `<[linked].name>` ... this link has been removed."
        - if <[match].has_flag[discord_account]>:
            - ~discordmessage id:relaybot channel:<context.channel> "] **Bridge Bot**: That account already has a discord link. You can remove a Discord link by using `/discordunlink` in-game."
            - stop
        - flag <[match]> discord_verification_inprog:<context.new_message.author.id>
        - flag server discord_verification_inprog.<context.new_message.author.id>:<[match]>
        - narrate "<&[base]>Discord user <&[emphasis]><context.new_message.author.name><&[base]> is attempting to verify as you." targets:<[match]>
        - narrate "<&[base]>Is this your Discord account? <element[(Yes)].custom_color[clickable].on_hover[Click to confirm].on_click[/discordlink confirm <context.new_message.author.id>]> <element[(No)].custom_color[clickable].on_hover[Click to deny].on_click[/discordlink deny <context.new_message.author.id>]><&[base]> (Click one)" targets:<[match]>
        - ~discordmessage id:relaybot channel:<context.channel> "] **Bridge Bot**: Link request sent. Check your Minecraft game window."
        on player joins:
        - flag player role_notif_dedup:!
        - if <player.has_flag[must_clear_discord]>:
            - run discord_clear_link_roles_task def:<player.flag[must_clear_discord]>
        - else if <player.has_flag[discord_account]>:
            - run discord_update_link_roles_task
        - else:
            - wait 1t
            - narrate "<&[base]>You haven't linked your Minecraft and Discord accounts together yet."
            - narrate "<&[base]>To link accounts, post a message in the Waymaker Discord's <&[emphasis]>#bot-spam<&[base]> channel with the text <&[emphasis]>!link <player.name> <&[base]>to link your account."
            - wait 10m
            - if <player.is_online> && !<player.has_flag[discord_account]>:
                - narrate "<&[base]>You haven't linked your Minecraft and Discord accounts together yet."
                - narrate "<&[base]>To link accounts, post a message in the Waymaker Discord's <&[emphasis]>#bot-spam<&[base]> channel with the text <&[emphasis]>!link <player.name> <&[base]>to link your account."
        after discord user role changes group:123:
        - define role_ids <context.added_roles.parse[id]>
        - define new_rank_up <empty>
        - if <[role_ids].contains[123]>:
            - define new_rank_up Wayfinder
        - if <[role_ids].contains[123]>:
            - define new_rank_up Wayfinder+
        - if <[role_ids].contains[123]> && !<context.user.has_flag[announced_founder]>:
            - flag <context.user> announced_founder
            - define new_rank_up Founder
        - if <[new_rank_up].length> > 0:
            - run discord_send_message def.channel:<server.flag[discord_chat_channel]> "def.message:Wow! <context.user.mention> just became a **<[new_rank_up]>** at <&lt>https://example.com/<&gt>!"
            - announce "<&[base]>Wow! <&[emphasis]><context.user.nickname[relaybot,123]||<context.user.name>> <&[base]>just became a <bold><[new_rank_up]><&[base]> at <&9>https://example.com/ <&[base]>!"
        - if !<context.user.flag[minecraft_account].is_online||false>:
            - stop
        - define __player <context.user.flag[minecraft_account]>
        - define groups <player.groups>
        - ~run discord_update_link_roles_task
        - define newroles <player.groups.exclude[<[groups]>]>
        - if <[newroles].any>:
            - narrate "<&[base]>Your roles have been updated."
            - if <[newroles].contains_any[donator_one|donator_two|founder]>:
                - playsound sound:ENTITY_PLAYER_LEVELUP <player> volume:0.5
                - playeffect at:<player.location.find_blocks.within[2]> effect:VILLAGER_HAPPY

discord_unlink_command:
    type: command
    debug: false
    name: discordunlink
    usage: /discordunlink
    description: Unlinks your minecraft account from your Discord account, which is useful for when you have a new Discord account.
    permission: dscript.discordlink
    script:
    - if !<player.has_flag[discord_account]>:
        - narrate "<&[error]>You don't have a linked Discord account."
        - stop
    - define account <player.flag[discord_account]>
    - run discord_clear_link_roles_task def:<[account]>
    - flag server discord_bridges.<[account]>:!
    - flag player discord_account:!
    - narrate "<&[base]>Discord link removed. Please link your new one ASAP."

discord_link_command:
    type: command
    debug: false
    name: discordlink
    usage: /discordlink [confirm|deny] [id]
    description: Links your minecraft account to your Discord account.
    permission: dscript.discordlink
    script:
    - if <player.has_flag[discord_account]>:
        - narrate "<&[error]>You already have a linked Discord account."
        - stop
    - choose <context.args.first||null>:
        - case confirm:
            - define possible <player.flag[discord_verification_inprog]||null>
            - if <[possible]> == null || !<server.has_flag[discord_verification_inprog.<[possible]>]>:
                - flag <player> discord_verification_inprog:!
                - narrate "<&[error]>No in-progress Discord verification attempts."
                - stop
            - flag server discord_verification_inprog.<[possible]>:!
            - flag <player> discord_verification_inprog:!
            - flag <player> discord_account_must_link_notices:!
            - flag <player> discord_account:<[possible]>
            - flag server discord_bridges.<[possible]>:<player>
            - run discord_update_link_roles_task
            - narrate "<&[base]>Discord account link accepted. Your account is now linked."
        - case deny:
            - define possible <player.flag[discord_verification_inprog]||null>
            - if <[possible]> == null || !<server.has_flag[discord_verification_inprog.<[possible]>]>:
                - flag <player> discord_verification_inprog:!
                - narrate "<&[error]>No in-progress Discord verification attempts."
                - stop
            - flag server discord_verification_inprog.<[possible]>:!
            - flag <player> discord_verification_inprog:!
            - narrate "<&[base]>Discord account link denied. Please report to staff if somebody is trolling/spamming false link requests."
        - default:
            #- narrate "<&[error]>Send a message on Discord to <&[emphasis]><discord[relaybot].self_user.name><&[error]> with the text <&[emphasis]>!link <player.name> <&[error]>to link your account."
            - narrate "<&[error]>Post a message in the Discord's <&[emphasis]>#bot-spam<&[error]> channel with the text <&[emphasis]>!link <player.name> <&[error]>to link your account."

discord_clear_link_roles_task:
    type: task
    debug: false
    definitions: discord_id
    script:
    - if !<player.has_flag[discord_account]>:
        - stop
    - define roles <discord_user[relaybot,<player.flag[discord_account]>].roles[relaybot,123]||<list>>
    - if !<[roles].is_empty>:
        - discord id:relaybot remove_role user:<[discord_id]> group:123 role:123
    - if !<player.is_online>:
        - flag <player> must_clear_discord:<[discord_id]>
        - stop
    - group set default
    - flag player perm_groups:!
    - flag <player> must_clear_discord:!

discord_name_fix:
    type: task
    debug: false
    definitions: user
    script:
    - ~discord id:relaybot user:<[user]> group:123 rename <player.name>

discord_update_link_roles_task:
    type: task
    debug: false
    script:
    - if !<player.has_flag[discord_account]>:
        - stop
    - define user <discord_user[relaybot,<player.flag[discord_account]>]>
    - flag <[user]> minecraft_account:<player>
    - define roles <[user].roles[relaybot,123]||<list>>
    - if !<[roles].is_empty>:
        - ~discord id:relaybot add_role user:<[user]> group:123 role:123
        - if <[user].nickname[relaybot,123]||<[user].name||?>> != <player.name>:
            - run discord_name_fix def.user:<[user]>
    - if !<player.is_online>:
        - announce to_console "<player.name> logged off mid role sync"
        - stop
    # These are the three pronoun role IDs
    - if !<[roles].parse[id].contains_any[123|123|123]>:
        - if !<player.has_flag[role_notif_dedup]>:
            - flag <player> role_notif_dedup expire:12h
            - narrate "<&[base]>You haven't selected your personal Discord roles yet! Head over to <&[emphasis]>#role-selection<&[base]> on the Waymaker Discord to select your preferred pronouns and notification roles."
    - define applicable <list>
    - define staff_tier 0
    - foreach <[roles]> as:role:
        - choose <[role].id>:
            # trainee
            - case 123:
                - define staff_tier <[staff_tier].max[3]>
            # staff
            - case 123:
                - define staff_tier <[staff_tier].max[5]>
            # dept head
            - case 123:
                - define staff_tier <[staff_tier].max[10]>
            # admin
            - case 123:
                - define staff_tier <[staff_tier].max[15]>
    - if <player.in_group[trainee]> && <[staff_tier]> == 0:
        - define message "] <&lt>**`<player.name>`**<&gt> was staff but is no longer, and will be reset"
        - run discord_send_message def:<list[<server.flag[discord_slowlog_channel]>].include_single[<[message]>]>
        - if <player.world.name> != danary:
            - teleport <player> aurum_spawn_center
        - flag player vanished:!
        - flag player nightvision:!
        - flag player invisibility:!
        - adjust <player> remove_effects
    - choose <[staff_tier]>:
        - case 3:
            - group set trainee
            - flag player perm_groups.staff:trainee
        - case 5:
            - group set staff
            - flag player perm_groups.staff:staff
        - case 10:
            - group set dept_head
            - flag player perm_groups.staff:dept_head
        - case 15:
            - group set admin
            - flag player perm_groups.staff:admin
        - default:
            - group set default
            - flag player perm_groups.staff:default
    - announce to_console "Assigned staff tier <[staff_tier]> to <player.name>: <player.groups.formatted>"
    - define applicable <list>
    - foreach <[roles]> as:role:
        - choose <[role].id>:
            #- case 123:
            #    - define applicable:->:greeter
            - case 123:
                - define applicable:->:founder
            - case 123:
                - define applicable:->:donator_one
            - case 123:
                - define applicable:->:donator_one
                - define applicable:->:donator_two
            - case 123:
                - define applicable:->:booster
            - case 123:
                - define applicable:->:build_team
    - flag player perm_groups.other:<[applicable]>
    - foreach <[applicable]>:
        - if !<player.in_group[<[value]>]>:
            - group add <[value]>
    - if <player.flag[character_mode]> in working|spectator && !<player.has_permission[dscript.staff_working_card]>:
        - run cc_set_mode def.mode:ooc
    - announce to_console "Final join-roles for <player.name> are <player.groups.separated_by[, ]>"
    - wait 5t
    - if <player.is_online>:
        - run name_suffix_character_card
