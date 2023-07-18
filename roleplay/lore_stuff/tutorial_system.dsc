tutorial_system:
    type: world
    debug: false
    events:
        #after player enters tutorial_bouncewall:
        #- if !<player.has_flag[discord_account]>:
        #    - narrate "<&[error]>You must link your Discord account before you can leave.<n><&[base]>To do so, join the Waymaker Discord at<&9>https://discord.gg/xxx <&[base]>and type <&[emphasis]>!link <player.name><&[base]> in the <&[emphasis]>#bot-spam <&[base]>channel."
        #- else if !<player.has_flag[current_character]>:
        #    - narrate "<&[error]>You must create a character card before you can leave."
        #    - narrate "<&[error]>Go back to the information room from the main hall to learn how."
        #- else:
        #    - stop
        #- adjust <player> velocity:0,0.5,-1.5
        #on player enters tutorial_exit:
        #- if !<player.has_flag[current_character]>:
        #    - teleport <player> tutorial_spawn
        #- if !<player.has_flag[discord_account]>:
        #    - teleport <player> tutorial_spawn
        #- teleport <player> <location[tutorial_exit_center].add[<player.location.sub[tutorial_exit_center1].rotate_around_y[-<util.pi.div[2]>]>].with_pose[<player.location.pitch>,<player.location.yaw.add[90]>]>
        on player clicks block in:tutorial:
        - if !<player.has_permission[dscript.staffbuild]>:
            - actionbar "<&[error]>You cannot alter blocks in this world."
            - determine cancelled
        on player breaks block in:tutorial:
        - if !<player.has_permission[dscript.staffbuild]>:
            - actionbar "<&[error]>You cannot alter blocks in this world."
            - determine cancelled
        on player damages entity in:tutorial:
        - if !<context.entity.has_permission[dscript.staffbuild]>:
            - actionbar "<&[error]>You cannot damage entities in this world."
            - determine cancelled
        on player damaged in:tutorial priority:100:
        - determine cancelled
        on player right clicks entity in:tutorial:
        - if !<context.entity.is_npc> && !<player.has_permission[dscript.staffbuild]>:
            - actionbar "<&[error]>You cannot interact with entities in this world."
            - determine cancelled
        on player drops item in:tutorial:
        - if !<player.has_permission[dscript.staffbuild]>:
            - actionbar "<&[error]>You cannot drop items in this world."
            - determine cancelled

aurum_tutorial_world:
    type: world
    debug: false
    events:
        after player exits aurum_spawn_safezone:
        - run tutorial_forceback
        # Backup in case the main event gets missed
        on delta time minutely:
        - foreach <server.online_players.filter[location.is_within[aurum_spawn_safezone].not]> as:__player:
                - run tutorial_forceback
        after player enters tutorial_ship_boardexit:
        - if <player.flag[character_mode]> == ooc && !<player.flag[character_cards].keys.any||false>:
            - teleport <player> relative tutorial_ship_boardexit_returnpoint
            - ratelimit <player> 2m
            - narrate format:format_tutorial_firstmate "'Ey! Mate! Slow down will ya! You gotta get your papers. You know they ain't gonna letcha into town without 'em."
            - wait 2s
            - narrate "<&[error]>Welcome to Waymaker! This is a roleplay server, so you can't just walk in as a Minecraft player - you need to create your roleplay character!"
            - narrate "<&[error]>Think of your character's name, then type<n><element[<&[clickable]>/cc new Your Name Here].on_click[/cc new ].type[suggest_command].on_hover[click to try!]>"
            - flag player cc_create_should_encourage

tutorial_forceback:
    type: task
    debug: false
    script:
    - if <player.flag[character_mode]> != ic:
        - if <player.has_flag[waymaker_verified]>:
            - if <player.has_flag[discord_account]>:
                - stop
            - flag player discord_account_must_link_notices:++
            - if <player.flag[discord_account_must_link_notices]> < 10:
                - narrate "<&[error]>You do not have a Discord account linked. Please link one ASAP. You will be locked to the spawn region if you do not re-link to Discord.<n><&[base]>To do so, join the Waymaker Discord at<&9>https://discord.gg/xxx <&[base]>and type <&[emphasis]>!link <player.name><&[base]> in the <&[emphasis]>#bot-spam <&[base]>channel."
                - stop
    - else:
        - if <proc[cc_has_flag].context[verified]>:
            - stop
    - wait 1t
    - if !<player.is_online>:
         - stop
    - ratelimit <player> 1s
    - if !<player.has_flag[discord_account]>:
        - narrate "<&[error]>You must link your Discord account before you can leave.<n><&[base]>To do so, join the Waymaker Discord at<&9>https://discord.gg/xxx <&[base]>and type <&[emphasis]>!link <player.name><&[base]> in the <&[emphasis]>#bot-spam <&[base]>channel."
    - else if <player.flag[character_mode]> == ooc:
        - narrate "<&[error]>You must create a character card before you can leave."
        - narrate "<&[error]>Go back to the information room from the main hall to learn how."
    - else:
        - narrate "<&[error]>You have not yet been verified. Please ask a staff member to approve your character card before you can step out."
    - run discord_send_message def.channel:discord_logs_channel "def.message:] <&lt>**`<player.name>`**<&gt> **ATTEMPTS TO ESCAPE SPAWN** and will be teleported back"
    - narrate "<&b>[Guard] <&f>We got a runner! Stop 'em!"
    - cast darkness duration:12s <player> no_ambient no_icon hide_particles
    - wait 1s
    - cast confusion duration:5s <player> no_ambient no_icon hide_particles
    - repeat 30:
        - playsound <player> sound:item_armor_equip_<list[chain|diamond|iron|netherite].random> volume:<[value].div[40]>
        - wait 2t
    - title fade_in:0.5s fade_out:3s title:<&0><&font[waymaker:special_titles]>9
    - wait 1s
    - teleport <player> aurum_spawn_center
    - playsound <player> sound:entity_horse_armor
    - narrate "<&[way_emote]>[The guards rush to grab you, and drag you back to the ship you came from. The guards look pretty annoyed, and you can hear one mutter something about dealing with this stuff too often.]"

irl_dob_command:
    type: command
    debug: false
    name: irldob
    aliases:
    - dobirl
    - dob
    usage: /irldob yyyy/mm/dd
    description: Configures your IRL Date of Birth.
    permission: dscript.irldob
    tab complete:
    - if <context.raw_args> == <empty>:
        - determine 19|20|yyyy/mm/dd
    - choose <context.args.to_list.count_matches[/]>:
        - case 0:
            - if <context.raw_args.length> < 4:
                - determine <util.list_numbers[from=0;to=9].parse_tag[<context.raw_args><[parse_value]>]>
            - else:
                - determine <context.raw_args.substring[1,4]>/
        - case 1:
            - determine <util.list_numbers_to[12].parse_tag[<context.raw_args.before_last[/]>/<[parse_value]>/]>
        - case 2:
            - determine <util.list_numbers_to[31].parse_tag[<context.raw_args.before_last[/]>/<[parse_value]>]>
    - determine <list>
    script:
    - if <player.has_flag[irl_dob]>:
        - narrate "<&[error]>Your date-of-birth has already been confirmed."
        - stop
    - if <context.args.is_empty> || <context.args.first.split[/].size> != 3 || <context.args.first> == yyyy/mm/dd:
        - narrate "<&[error]>/irldob yyyy/mm/dd <&[warning]>- indicate your date of birth, as year/month/day. For example, today is <util.time_now.format[yyyy/MM/dd].custom_color[emphasis]>"
        - narrate "<&[emphasis]><bold>WARNING: <&[emphasis]>Verifying your *real* age is required to play on Waymaker. Inputting a false year may result in a ban."
        - stop
    - define split <context.args.first.split[/]>
    - if <[split].first.length> != 4:
        - narrate "<&[error]>The year must be a 4-digit number. For example, the current year is <util.time_now.year.custom_color[emphasis]>"
        - stop
    - if <[split].parse[is_integer]> contains false || <[split].parse[is_less_than[1]]> contains true:
        - narrate "<&[error]>Invalid numeric input."
        - stop
    - define year <[split].get[1]>
    - define month <[split].get[2]>
    - define day <[split].get[3]>
    - if <[month]> < 1 || <[month]> > 12:
        - narrate "<&[error]><[month].custom_color[emphasis]> is not a valid month. Must be 1-12 (eg 1 for January, 2 for February, etc.)"
        - stop
    - if <[day]> < 1 || <[day]> > 31:
        - narrate "<&[error]><[day].custom_color[emphasis]> is not a valid day-of-month. Must be 1-31."
        - stop
    - if <[year]> < 1900 || <[year]> > <util.time_now.year.add[1]>:
        - run discord_send_message def.channel:discord_slowlog_channel "def.message:] <&lt>**`<player.name>`**<&gt> **ATTEMPTED A FALSE DATE OF BIRTH**: `<[year]>/<[month]>/<[day]>`."
        - narrate "<&[error]><[year].custom_color[emphasis]> is not a valid year. Must be between 1900 and <util.time_now.year.add[1]>."
        - stop
    - define time <time[<[year]>/<[month]>/<[day]>]||null>
    - if <[time]> == null:
        - run discord_send_message def.channel:discord_slowlog_channel "def.message:] <&lt>**`<player.name>`**<&gt> **ATTEMPTED A FALSE DATE OF BIRTH**: `<[year]>/<[month]>/<[day]>`."
        - narrate "<&[error]>That date is not a real date."
        - stop
    - define age <[time].from_now.in_years.round_down>
    - if <[age]> > 120 || <[age]> < 6:
        - run discord_send_message def.channel:discord_slowlog_channel "def.message:] <&lt>**`<player.name>`**<&gt> **ATTEMPTED A FALSE DATE OF BIRTH**: `<[year]>/<[month]>/<[day]>`."
        - narrate "<&[error]>That Date of Birth would make you <[age].custom_color[emphasis]> years old."
        - narrate "<&[emphasis]><bold>WARNING: <&[emphasis]>Verifying your *real* age is required to play on Waymaker. Inputting a false year may result in a ban."
        - stop
    - if <context.args.size> == 3 && <context.args.get[3]> == confirm && <context.args.get[2]> == <[time].epoch_millis>:
        - narrate "<&[base]>Thank you for confirming that you are <[age].custom_color[emphasis]> years old."
        - run discord_send_message def.channel:discord_slowlog_channel "def.message:] <&lt>**`<player.name>`**<&gt> **CONFIRMS THEIR AGE** as `<[age]>` per date-of-birth `<[year]>/<[month]>/<[day]>`."
        - if <[age]> < 13:
            - run discord_send_message def.channel:discord_slowlog_channel "def.message:] <&lt>**`<player.name>`**<&gt> **AUTO-BANNED** for being too young: `<[age]>` per date-of-birth `<[year]>/<[month]>/<[day]>`."
            - ban <player> "reason:You are too young to play on Waymaker, or any public Minecraft server.<n>Contact staff on Discord if this is in error." expire:<util.time_now.add[<element[13].sub[<[age]>]>y]> source:<empty>
            - stop
        - if <[age]> > 110:
            - run discord_send_message def.channel:discord_slowlog_channel "def.message:] <&lt>**`<player.name>`**<&gt> **AUTO-BANNED** for inputting false age: `<[age]>` per date-of-birth `<[year]>/<[month]>/<[day]>`."
            - ban <player> "reason:Input a false age.<n>Contact staff on Discord if this is in error." source:<empty>
            - stop
        - flag player irl_dob:<[time]>
        - if <[age]> < 16:
            - narrate "<&[error]>The minimum age that we allow on Waymaker is <&[emphasis]>16 years old<&[error]>. You are welcome to return when you are old enough."
        - stop
    - narrate "<&[base]>Please confirm that you input your age correctly as <&[emphasis]><[year]>/<[month]>/<[day]><&[base]>, making you <[age].custom_color[emphasis]> years old."
    - narrate "<&[base]>If this is correct, please <element[click here].custom_color[clickable].on_hover[click to verify].on_click[/irldob <[year]>/<[month]>/<[day]> <[time].epoch_millis> confirm]>"
    - narrate "<&[emphasis]><bold>WARNING: <&[emphasis]>Verifying your *real* age is required to play on Waymaker. Inputting a false year may result in a ban."

format_tutorial_firstmate:
    type: format
    debug: false
    format: <element[<&b>[Ardly Larc]].on_hover[<&f>Job: First Mate<n>Species: Human<n>Gender: Male]> <&f><[text]>

aurum_tutorial_firstmate_assign:
    type: assignment
    debug: false
    actions:
        on assignment:
        - trigger name:click state:true
        on click:
        - if <player.has_flag[cc_create_should_encourage]>:
            - narrate format:format_tutorial_firstmate "Look, if you've lost 'em, there's some blank forms in the hold. Just slap your name on one of 'em."
            - wait 2s
            - narrate "<&[error]>Welcome to Waymaker! This is a roleplay server, so you can't just walk in as a Minecraft player - you need to create your roleplay character!"
            - narrate "<&[error]>Think of your character's name, then type<n><element[<&[clickable]>/cc new Your Name Here].on_click[/cc new ].type[suggest_command].on_hover[click to try!]>"
        - else if <player.flag[character_mode]> == ic:
            - narrate format:format_tutorial_firstmate "Well <player.proc[cc_idpair].proc[embedder_for_character]>, I'm sure we'll see each other again, but I've supplies to get and people to ferry, so the quicker ye get in the city the quicker I can leave."

aurum_tutorial_quartermaster_assign:
    type: assignment
    debug: false
    actions:
        on assignment:
        - trigger name:click state:true
        on click:
        - narrate "<&[way_emote]>[Doing everything in their power to ignore you, you see the Quartermaster taking stock of the supplies.]"

format_tutorial_deskworker:
    type: format
    debug: false
    format: <element[<&b>[Deskworker Sybil Irriel]].on_hover[<&f>Job: Deskworker at the Immigration Office.<n>Species: Elf (Sephyrran)<n>Gender: Female]> <&f><[text]>

aurum_tutorial_deskworker_assign:
    type: assignment
    debug: false
    actions:
        on assignment:
        - trigger name:click state:true
        on click:
        - narrate "<&[way_emote]>[With great disinterest, the desk worker looks in your direction.]"
        - narrate format:format_tutorial_deskworker "What can I help you with?"
        - define c1 <element[Species].custom_color[clickable].on_click[/aurumtutorialinfo deskworker_species].on_hover[Click here]>
        - define c2 <element[Stats and Skills].custom_color[clickable].on_click[/aurumtutorialinfo deskworker_skills].on_hover[Click here]>
        - define c3 <element[Emoting].custom_color[clickable].on_click[/aurumtutorialinfo deskworker_emoting].on_hover[Click here]>
        - define c4 <element[Professions].custom_color[clickable].on_click[/aurumtutorialinfo deskworker_professions].on_hover[Click here]>
        - narrate "<&[base]>[Click one: <[c1]>, <[c2]>, <[c3]>, <[c4]>]"

format_tutorial_speciesnpc:
    type: format
    debug: false
    format: <element[<&b>[Josh Shep]].on_hover[<&f>Job: Cartographer<n>Species: Halfling<n>Gender: Male]> <&f><[text]>

aurum_tutorial_speciesnpc_assign:
    type: assignment
    debug: false
    actions:
        on assignment:
        - trigger name:click state:true
        - trigger name:proximity state:true radius:7
        on click:
        - narrate "<&[way_emote]>[The halfling nervously looks up from his half-finished map.]"
        - narrate format:format_tutorial_speciesnpc "Ah. Yes. Hello, h-how can I help you?"
        - narrate <&[base]>[<element[Can you tell me about the Species of Alm?].custom_color[clickable].on_hover[Click here].on_click[/aurumtutorialinfo speciesnpc_intro]>]
        on exit proximity:
        - if <player.has_flag[aurum_tutorial_speciesnpc_spoke_recent]>:
            - flag player aurum_tutorial_speciesnpc_spoke_recent:!
            - narrate format:format_tutorial_speciesnpc "O-ok bye. H-Hope I s-sufficiently helped you."
            - narrate "<&[way_emote]>[Using his hand to wipe his head, the halfling goes back to working on his map.]"

format_tutorial_skillsnpc:
    type: format
    debug: false
    format: <element[<&b>[Crystal]].on_hover[<&f>Job: Archivist<n>Species: Crestfallen<n>Gender: N/A]> <&f><[text]>

aurum_tutorial_skillsnpc_assign:
    type: assignment
    debug: false
    actions:
        on assignment:
        - trigger name:click state:true
        on click:
        - narrate "<&[way_emote]>[Without pausing their work, the crestfallen speaks to you with a monotone voice.]"
        - narrate format:format_tutorial_skillsnpc "Hello, I am Crystal, the Archivist of this facility. How may I help you?"
        - narrate "<&[base]>[<element[How do stats work?].custom_color[clickable].on_hover[Click here].on_click[/aurumtutorialinfo skillsnpc_stats]> or <element[Can you tell me how skills work?].custom_color[clickable].on_hover[Click here].on_click[/aurumtutorialinfo skillsnpc_skills]>]"

format_tutorial_chatnpc:
    type: format
    debug: false
    format: <element[<&b>[Hush Riddle]].on_hover[<&f>Job: Messenger<n>Species: Faefolke (Feline)<n>Gender: Male]> <&f><[text]>

aurum_tutorial_chatnpc_assign:
    type: assignment
    debug: false
    actions:
        on assignment:
        - trigger name:click state:true
        on click:
        - narrate "<&[way_emote]>[As you approach the lounging Faefolke, you see his tail swaying side to side and a content grin on his face. He speaks with a slight purr.]"
        - narrate format:format_tutorial_chatnpc "Hmm, always nice to see a new face. What can I do for you traveller?"
        - narrate "<&[base]>[<element[How do channels work?].custom_color[clickable].on_hover[Click here].on_click[/aurumtutorialinfo chatnpc_channels]>, <element[How do emotes work?].custom_color[clickable].on_hover[Click here].on_click[/aurumtutorialinfo chatnpc_emotes]>, or <element[What are embeds?].custom_color[clickable].on_hover[Click here].on_click[/aurumtutorialinfo chatnpc_embeds]>]"

format_tutorial_othernpc:
    type: format
    debug: false
    format: <&b>[<npc.name>] <&f><[text]>

aurum_tutorial_leona_tribet_assign:
    type: assignment
    debug: false
    actions:
        on assignment:
        - trigger name:click state:true
        on click:
        - narrate "<&[way_emote]>[The annoyed half-orc turns to you.]"
        - narrate format:format_tutorial_othernpc "If you are looking for a courier, I don't recommend that lazy cat, he's been ignoring me all day and is just lounging around."

aurum_tutorial_rilix_tikt_assign:
    type: assignment
    debug: false
    actions:
        on assignment:
        - trigger name:click state:true
        on click:
        - narrate "<&[way_emote]>[The small goblin, attempting to gain the attention of the desk work, hops up and down.]"
        - wait 2s
        - narrate format:format_tutorial_othernpc "Listen, miss, you need to let me in the city I have very important business to conduct."
        - wait 3s
        - narrate "<&[way_emote]>[The deskworker with a monotone voice responds with a well-practiced line.]"
        - wait 2s
        - narrate format:format_tutorial_deskworker "Sir, once again, your papers have been rejected. Unless you have some other form of approved identification, I cannot allow you into the city."
        - wait 2.5s
        - narrate "<&[way_emote]>[No longer paying attention to the goblin she turns back to her work.]"

aurum_tutorial_info_command:
    type: command
    debug: false
    name: aurumtutorialinfo
    description: Internal helper command, ignore.
    usage: /aurumtutorialinfo (...)
    script:
    - choose <context.args.first||none>:
        - case deskworker_species:
            - narrate format:format_tutorial_deskworker "For help regarding the species of Alm Head up to the Second floor and talk to <&b>Josh Shep<&f>, the man with the books."
        - case deskworker_skills:
            - narrate format:format_tutorial_deskworker "On the third floor, head left into the tower there you will meet <&b>Crystal<&f> who will help you."
        - case deskworker_emoting:
            - narrate format:format_tutorial_deskworker "On the second floor the messenger is normally loitering around, talk to them."
        - case deskworker_professions:
            - narrate format:format_tutorial_deskworker "That will be on the third floor. Speak to <&b>Moly<&f> for information about professions."
        - case speciesnpc_intro:
            - flag player aurum_tutorial_speciesnpc_spoke_recent expire:30m
            - narrate format:format_tutorial_speciesnpc "R-Right. Yes of course. Err. Ha, which ones would you like to know about?"
            - define options <list>
            - foreach Human|Goliath|Elf|Orc|Goblin|Vhyranni|Faefolke|Dwarf|Crestfallen|Halfling as:species:
                - define options:->:<[species].custom_color[clickable].on_hover[<&f>Click to learn about the <[species].custom_color[emphasis]> species].on_click[/aurumtutorialinfo speciesnpc_<[species]>]>
            - narrate <&[base]>[<[options].separated_by[, ]>]
        - case speciesnpc_human:
            - narrate format:format_tutorial_speciesnpc "Yes. Humans, t-they are spread all throughout Alm with a substantial amount of different cultures, a-and they have splendid technical control of their body <&[emphasis]>(+1 Technique)<&f>. If y-you want to know more I have a book around here somewhere."
            - narrate "<&[way_emote]>[He gingerly reaches for a book before presenting it to you.]"
            - narrate <proc[aurum_tutorial_specieslink].context[Human]>
        - case speciesnpc_goliath:
            - narrate format:format_tutorial_speciesnpc "G-Goliaths are s-said to be descendants of Titans and are related to giants, they are also naturally strong <&[emphasis]>(+1 Athletics)<&f>. I have a book on them if you w-want to know more."
            - narrate "<&[way_emote]>[Slightly shaking, he reaches for a book before presenting it to you.]"
            - narrate <proc[aurum_tutorial_specieslink].context[Goliath]>
        - case speciesnpc_elf:
            - narrate format:format_tutorial_speciesnpc "Elves are Quite f-fascinating some even live underground. They are known for being skilled in the finer arts <&[emphasis]>(+1 Proficiency)<&f>. I-If you want to know more, ..."
            - narrate "<&[way_emote]>[He gingerly reaches for a book before presenting it to you.]"
            - narrate <proc[aurum_tutorial_specieslink].context[Elf]>
        - case speciesnpc_orc:
            - narrate format:format_tutorial_speciesnpc "O-Of Course, Orcs are a diverse bunch, with some living in jungles while others live in the mountains. O-One of the reasons they have such a wide range of habitats is their ability to naturally heal a bit quicker than most <&[emphasis]>(+1 Recovery)<&f>. I-I'm sure I have a book about the intricacies of Orcs if you wish to know more."
            - narrate "<&[way_emote]>[With a nervous disposition, he gingerly presents a book to you.]"
            - narrate <proc[aurum_tutorial_specieslink].context[Orc]>
        - case speciesnpc_goblin:
            - narrate format:format_tutorial_speciesnpc "I-In terms of history, not much is widely known about the Goblins as they don't really keep any of it. But I-I do know that they are related to Hobgoblins and can get themselves out of sticky situations <&[emphasis]>(+1 Evasion)<&f>. [Mumbling] S-sorry I never read m-much about goblins, but here's a book about them if you what to learn more."
            - narrate "<&[way_emote]>[Slightly shaking, he places the book before you.]"
            - narrate <proc[aurum_tutorial_specieslink].context[Goblin]>
        - case speciesnpc_Vhyranni:
            - narrate format:format_tutorial_speciesnpc "The Vhyranni are descendants of dragons and have several different ideologies that are based on the beliefs of certain ancient dragons. V-Vhyranni are also known to be normally observant of their surroundings <&[emphasis]>(+1 Senses)<&f>. F-For more information I have a book about them, i-if you would like to read it."
            - narrate "<&[way_emote]>[Timidly, he places a book before you.]"
            - narrate <proc[aurum_tutorial_specieslink].context[Vhyranni]>
        - case speciesnpc_Faefolke:
            - narrate format:format_tutorial_speciesnpc "F-Faefolke are humanoid animals, believed to be created to p-protect the Fae realm. This c-connection to the Fae realm grants the Faefolke a natural affinity to understanding magic, if not a-academically, then instinctively <&[emphasis]>(+1 Obscura)<&f>. I have a book in my collection here, on Faefolke if you wish to know more."
            - narrate "<&[way_emote]>[With a shaking hand, the halfling gestures to the nearby books.]"
            - narrate <proc[aurum_tutorial_specieslink].context[Faefolke]>
        - case speciesnpc_Dwarf:
            - narrate format:format_tutorial_speciesnpc "Stout a-and hardy, D-Dwarves are known to be great engineers and inventors, with an incredible constitution allowing them to push on through tough situations <&[emphasis]>(+1 Endurance)<&f>. Um, I-I'm sure I have a book around here with more information."
            - narrate "<&[way_emote]>[The halfling gingerly gestures to his book collection.]"
            - narrate <proc[aurum_tutorial_specieslink].context[Dwarf]>
        - case speciesnpc_Crestfallen:
            - narrate format:format_tutorial_speciesnpc "R-Right. Crestfallen are sentient constructs, made with the use of s-something called a Soul Core. The a-artificial body of a Crestfallen helps them stay steadfast in the face of hardships <&[emphasis]>(+1 Composure)<&f>. One of the books in my collection may have more information if you w-would like to look."
            - narrate "<&[way_emote]>[A nervous hand gestures to the books nearby.]"
            - narrate <proc[aurum_tutorial_specieslink].context[Crestfallen]>
        - case speciesnpc_Halfling:
            - narrate format:format_tutorial_speciesnpc "W-well. Ha. I-I'm a Halfling and w-we have a n-natural connection to the environment around us which helps us with magic <&[emphasis]>(+1 Intuition)<&f> a-and, and, i-if you want to know more here's a book with more information."
            - narrate "<&[way_emote]>[Rapidly, the halfling takes a book from his collection and places it in front of you, before immediately going back to working on his map.]"
            - narrate <proc[aurum_tutorial_specieslink].context[Halfling]>
        - case skillsnpc_stats:
            - define body <element[Body].custom_color[clickable].on_hover[<&f>Click here for information about the Body stat].on_click[/aurumtutorialinfo skillnpc_stat_body]>
            - define magic <element[Magic].custom_color[clickable].on_hover[<&f>Click here for information about the Magic stat].on_click[/aurumtutorialinfo skillnpc_stat_magic]>
            - define speed <element[Speed].custom_color[clickable].on_hover[<&f>Click here for information about the Speed stat].on_click[/aurumtutorialinfo skillnpc_stat_speed]>
            - define vitality <element[Vitality].custom_color[clickable].on_hover[<&f>Click here for information about the Vitality stat].on_click[/aurumtutorialinfo skillnpc_stat_vitality]>
            - narrate format:format_tutorial_skillsnpc "That should be simple enough. The statistics that make up an individual are <[Body]>, <[Magic]>, <[Speed]>, and <[Vitality]>. Each of these stats governs over three skills and gives bonuses to said skills when used, some stats may also provide additional benefits."
        - case skillnpc_stat_body:
            - narrate format:format_tutorial_skillsnpc "Body - Provides a bonus to the skills <proc[aurum_tutorial_skill_info].context[Athletics]>, <proc[aurum_tutorial_skill_info].context[Resilience]>, and <proc[aurum_tutorial_skill_info].context[Technique]>"
        - case skillnpc_stat_magic:
            - narrate format:format_tutorial_skillsnpc "Magic - Provides a bonus to the skills <proc[aurum_tutorial_skill_info].context[Intuition]>, <proc[aurum_tutorial_skill_info].context[Psyche]>, and <proc[aurum_tutorial_skill_info].context[Obscura]>"
        - case skillnpc_stat_speed:
            - narrate format:format_tutorial_skillsnpc "(Bonus +1 to Initiative) Speed - Provides a bonus to the skills <proc[aurum_tutorial_skill_info].context[Senses]>, <proc[aurum_tutorial_skill_info].context[Evasion]>, and <proc[aurum_tutorial_skill_info].context[Proficiency]>"
        - case skillnpc_stat_vitality:
            - narrate format:format_tutorial_skillsnpc "(Bonus +3 to Max Health) Vitality - Provides a bonus to the skills <proc[aurum_tutorial_skill_info].context[Recovery]>, <proc[aurum_tutorial_skill_info].context[Endurance]>, and <proc[aurum_tutorial_skill_info].context[Composure]>"
        - case skillsnpc_skills:
            - narrate format:format_tutorial_skillsnpc "Of Course. Skills are used when a skill check is required. A skill check tests a creature's talent and training in an effort to overcome a challenge. A skill check is made when a creature attempts an action that has a chance of failure."
            - wait 2s
            - narrate format:format_tutorial_skillsnpc "Skills are divided into three categories: Active, Reactive, and Expertise. For combat purposes, you can tag one skill from each of these categories to set it as a combat Skill - in doing so, the chosen skill grants you a combat skill trait."
            - wait 2s
            - narrate "<&f>Active - <proc[aurum_tutorial_skill_info].context[Athletics]>, <proc[aurum_tutorial_skill_info].context[Intuition]>, <proc[aurum_tutorial_skill_info].context[Senses]>, <proc[aurum_tutorial_skill_info].context[Recovery]>"
            - narrate "<&f>Reactive - <proc[aurum_tutorial_skill_info].context[Resilience]>, <proc[aurum_tutorial_skill_info].context[Psyche]>, <proc[aurum_tutorial_skill_info].context[Evasion]>, <proc[aurum_tutorial_skill_info].context[Endurance]>"
            - narrate "<&f>Expertise - <proc[aurum_tutorial_skill_info].context[Technique]>, <proc[aurum_tutorial_skill_info].context[Obscura]>, <proc[aurum_tutorial_skill_info].context[Proficiency]>, <proc[aurum_tutorial_skill_info].context[Composure]>"
        - case chatnpc_channels:
            - narrate format:format_tutorial_chatnpc "Chatting is broken down into different channels: Global, Advert, Local, Whisper, and Mutter. You can swap between channels in multiple ways. You can for example swap to global chat with <&[emphasis]>/channel global<&f>, <&[emphasis]>/ch global<&f>, <&[emphasis]>/global<&f>, or <&[emphasis]>/g<&f>, this works with all channels. If you want to quickly send a message to a specific channel, you can do for example <&[emphasis]>/g hi<&f> or <&[emphasis]>g: hi<&f> - this will say <&[emphasis]>hi<&f> in Global, without changing your current channel."
        - case chatnpc_emotes:
            - narrate format:format_tutorial_chatnpc "While in the Local, Mutter, or Whisper channel, you can use special modifier symbols to format your text."
            - wait 1s
            - narrate format:format_tutorial_chatnpc "To emote, just add <&[emphasis]>+<&f> to the end of your texts. If you want to speak while emoting be sure to wrap your speech with <&[emphasis]><&dq><&f>quotes<&[emphasis]><&dq><&f>. To do a long-range emote use an <&[emphasis]>@<&f> instead of a <&[emphasis]>+<&f>."
            - wait 1s
            - narrate format:format_tutorial_chatnpc "While in Local, end a message with <&[emphasis]>!!<&f> to shout, with <&[emphasis]>!<&f> to exclaim, with <&[emphasis]>))<&f> to talk OOC, or with <&[emphasis]><&rb><&f> for environmental messages."
            - wait 1s
            - narrate format:format_tutorial_chatnpc "Note that Local, OOC, and Environmental messages can be read from 13 blocks away, Mutter 5, Whisper 2, Emote 20, Exclaim 18, Shout or Loud Emote 30"
            - narrate <&[base]>[<element[Can you show me some examples?].custom_color[clickable].on_hover[Click here].on_click[/aurumtutorialinfo chatnpc_emote_examples]>]
        - case chatnpc_emote_examples:
            - narrate format:format_tutorial_chatnpc "Sure! I'll do some now. Hover your mouse over a message to see how I did it!"
            - wait 1s
            - narrate <element[<&b>Hush Riddle <&f>says: <&color[#CCFFFE]><&dq>Hello<&dq>].on_hover[<&f>I typed: <&[emphasis]>Hello]>
            - wait 0.5s
            - narrate <element[<&b>Hush Riddle <&color[#B8A78F]><&o>does an emote].on_hover[<&f>I typed: <&[emphasis]>does an emote+]>
            - wait 0.5s
            - narrate <element[<&b>Hush Riddle <&color[#B8A78F]><&o>does an emote. <&color[#CCFFFE]><&dq>Wow I sure am great at emoting.<&dq>].on_hover[<&f>I typed: <&[emphasis]>does an emote <&dq>Wow I sure am great at emoting<&dq>+]>
            - wait 0.5s
            - narrate <element[<&color[#d9b577]>A thing happens near me.].on_hover[<&f>I typed: <&[emphasis]>A thing happens near me.<&rb>]>
            - wait 0.5s
            - narrate <element[<&b>Hush Riddle<&f> exclaims: <&color[#CCFFFE]><&dq>I am exclaiming at you!<&dq>].on_hover[<&f>I typed: <&[emphasis]>I am exclaiming at you!]>
            - wait 0.5s
            - narrate <element[<&b>Hush Riddle <&c><&l>shouts: <&color[#CCFFFE]><&dq>I am shouting at everyone!!<&dq>].on_hover[<&f>I typed: <&[emphasis]>I am shouting at everyone!!]>
            - wait 0.5s
            - narrate <element[<&b>Hush Riddle <&color[#777777]>mutters: <&color[#CCFFFE]><&dq>Hello<&dq>].on_hover[<&f>I typed: <&[emphasis]>Hello$]>
            - wait 0.5s
            - narrate <element[<&b>Hush Riddle <&color[#777777]>whispers: <&color[#CCFFFE]><&dq>Hello<&dq>].on_hover[<&f>I typed: <&[emphasis]>Hello*]>
            - wait 0.5s
            - narrate <element[<&color[#777777]>[OOC] Hush Riddle: This is out of character chat].on_hover[<&f>I typed: <&[emphasis]>This is out of character chat]>
        - case chatnpc_embeds:
            - narrate format:format_tutorial_chatnpc "You can embed your items, your character cards, etc! This works by typing two opening brackets, then a keyword, and then two closing brackets."
            - wait 1s
            - narrate format:format_tutorial_chatnpc "Type <&[emphasis]>[[helditem]]<&f> or <&[emphasis]>[[i]]<&f> in chat to embed your currently held item."
            - wait 0.5s
            - narrate format:format_tutorial_chatnpc "Type <&[emphasis]>[[character]]<&f> or <&[emphasis]>[[c]]<&f> in chat to embed your current character card."
            - wait 0.5s
            - narrate format:format_tutorial_chatnpc "Type <&[emphasis]>[[character:cardname]]<&f> or <&[emphasis]>[[character:playername]]<&f> or <&[emphasis]>[[character:playername:cardname]]<&f> to embed a different character."
            - wait 0.5s
            - narrate format:format_tutorial_chatnpc "Type just about anything else between brackets to automatically search. Character name, ability name, item name, etc, as long as it's close enough there's a good chance it'll figure out what you meant."
        - case none:
            - narrate "<&[error]>This command isn't for normal usage."
        - default:
            - debug error "[AurumTutorialInfo]: invalid input '<context.args.first>' from <player.name>"
            - narrate "<&[error]>Please report to a staff member: AurumTutorialInfo Error"

aurum_tutorial_specieslink:
    type: procedure
    debug: false
    definitions: species
    data:
        species_link_base: example.com
    script:
    - determine <element[<&9>[Species Lore: <[species]>]].click_url[<script.parsed_key[data.species_link_base]><[species].to_lowercase>].on_hover[<&f>Click to view the Lore site page for the <[species].custom_color[emphasis]> species]>

aurum_tutorial_skill_info:
    type: procedure
    debug: false
    definitions: skill
    script:
    - define stat <script[cc_data].parsed_key[skills.<[skill]>.stat]>
    - define color <script[cc_data].parsed_key[stats.<[stat]>.color]>
    - determine <[skill].color[<[color]>].on_hover[<&f><[skill]>: <script[cc_data].parsed_key[skills.<[skill]>.description]>]>
