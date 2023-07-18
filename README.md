# Waymaker Scripts

[Denizen](https://denizenscript.com/) scripts I wrote for the Waymaker Minecraft Roleplay Server, mostly in the years 2020-2021. These are not high quality references.

## Rough Content Overview

The server was primarily focused on a single roleplay server, but we had experimented with branching out into a Bungee network with a Survival server and more-to-come. These experiments were never opened to real players and so those features are incomplete.

The scripts are
- systems/engines for core features (such as the advanced roleplay chat engine, character cards, combat turn tracking, businesses, etc.)
- commands and controls for various things (way too much script-space used for thorough commands)
- easter eggs and other fun bits (snowball war for staff to play with, clickables throughout the towns, etc)
- staff toolkits (better building tools for example)
- protections from player misbehavior and other issues
- Discord bot tools. Some key behaviors of our Discord bots were handled through minecraft (including a few that weren't meant to be, but the minecraft bot simply took the job as a quickfix when the correct bot for the job glitched out)
- experiments that might've become features in time but never got the chance due to the shutdown (eg lockpicking)

There were a variety of entirely novel features, or features that were *invented for* Waymaker but then spread elsewhere. For example, we have a dedicated hologram-based nameplate replacement that allows for long/complex/multi-lined nameplate (this is probably outdated now with 1.19/1.20's display entities).

## Technical Notes

Many of these scripts do not work on their own, they are all interconnected. At the very least, Waymaker had weird special requirements for things like playernames that don't apply elsewhere, and thus had to have special script calls for formatting playernames and the like.

A small amount of content (links, ids, etc) has been stripped from this repo, as they are not relevant to the archive and highly specific to Waymaker.

I have excluded the original git history, as the commits include notes related to the internal staff decision making, which has no relevance to this public archive.

*The Great Flag Rewrite* happened in the middle of this server's early evolution, and thus there may still be remnants lying around of tricks and hacks to make flags work well from before the rewrite.

Many features relate directly to our server-resource-pack (eg emojis, custom item models, etc), which is not provided here.

## Organization

I was working alone on scripting the whole time on this project, so the organization is whatever I personally slapped together at the time, spread over years.

Some things are organized in ways that made sense when they were put there, but stopped making sense as the server evolved.

I was partially working in an environment with misbehaving FTP that made it slightly annoying to move or rename files, thus, most things are placed and named however they were when they were first started, regardless of whether that placement continued making sense later.

## Quality Assessment

Script quality within this repo can be broadly sorted into 3 categories:

- Proper: some scripts were built for or taken from my public script repo, and thus are built to a highly proper spec
- Robust: some scripts are well written with care
- Slapped together: some scripts were written to add a feature or solve an issue very quickly, at times even live solutions while players were present on-server. These scripts can be a little weird.

Due to the weird development timeline of the server, many scripts are half-finished, or functional-but-unrefined.

Some features were developed but never used (eg the quest book).

For varying reasons, there are some script files that contain large blobs of data, which is obviously improper data handling.

## History

Waymaker was founded by Percuriam in July 2020 with a team of friends. I joined from the start to help my own friends within the staff team at the time. It launched to the public in January 2021 successfully - despite relatively small marketing of a server built by a group of friends, it had over 50 players online simultaneously for a launch-day event. In the time it was being built and after it was public, I became friends with several members of the staff team, and chose to continue working there to continue helping my friends there. There were, however, significant issues within the staff team that led to significant infighting and drama, eventually leading in May 2021 to Percuriam stepping down and transferring ownership to pixYcandi. We continued the server under her leadership for a while, until August 2021 when she made the decision to close the server on what she intended to be a temporary basis to rebuild and improve before relaunching. As is inevitable when such a decision is made, development rates dropped through the floor as most involved lost interest in building a server that no longer had a playerbase they were trying to build things for. Still, those that stayed tried our best, managing to majorly upgrade several things and prep a whole new main world for the server. The rate things happened slow more and more, until finally, in July 2023, pixY announced that the server would be finally closing for good. This script folder is released now after the server closed as a public reference of what we had, more intended for the Denizen community's viewing than anywhere else.

## Legal

All content herein is Copyright (C) Alex "mcmonkey" Goodwin 2020-2023.

This is provided to the public as a historical reference and nothing more, I do not authorize any usage outside of referencing and learning.
