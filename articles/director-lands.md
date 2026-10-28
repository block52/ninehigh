---
title: "The Director Lands: Multi-Table Tournaments Merge, and Their First Pieces Reach the Sit-and-Go"
author: Nine High Studios
date: 2026-10-28
tags: [Build Log, Tournaments, Engine, Releases]
---

# The Director Lands: Multi-Table Tournaments Merge, and Their First Pieces Reach the Sit-and-Go

*A month of multi-table tournament work left its branch for main, and the parts of it that already make sense at one table reached the chain the same week.*

Between **19 October and 25 October 2026** we merged **53 pull requests** across the three Block 52 repositories, adding **39,733 lines** and removing **3,772**. The engine cut **three releases**, the SDK **five** and the chain **five**, three of them behind a coordinated halt. The biggest change is the multi-table tournament engine reaching main. The changes players can use today are three new ways to set up a sit-and-go: a blind structure, late registration and fixed-limit betting.

## The scoreboard

| Repository | Merged PRs | Lines added | Lines removed | Total changed |
|---|---:|---:|---:|---:|
| **UI** (the client) | 28 | 6,875 | 611 | 7,486 |
| **PVM** (the Poker Virtual Machine) | 18 | 29,547 | 2,335 | 31,882 |
| **Chain** (the settlement chain) | 7 | 3,311 | 826 | 4,137 |
| **Total** | **53** | **39,733** | **3,772** | **43,505** |

The honest footnote: **16,604** of the PVM's added lines are two generated files in one pull request, the multi-table golden corpus (15,209 lines of JSON) and its readable rendering (1,395). Another **1,955** lines, added and removed in equal number, are hand-history fixtures re-baselined after deliberate changes to what the engine records. Leave the golden corpus out and the engine added 12,943 lines and the week 23,129.

## The tournament director reaches main

Multi-table tournaments have been built since early October on one branch, so the whole stack could be tested end to end before any of it touched main. On 23 October it merged: a tournament director that owns the field, the clock and the payouts; directed tables, which take their players, blinds and hand starts from the director instead of from clients; blind structures; big-blind antes; the tournament dealer rule; a leaderboard; and the golden corpus.

The golden corpus is what holds it in place. It runs a **20-entrant, three-table tournament** down to the final table: **76 hands** and **589 inputs**, players moved between tables at hand boundaries as the field shrinks, and **2 tables broken**. No client acts in it at all. The director starts every hand and the action clock plays every turn, so it tests the parts of a tournament that must work when nobody is clicking. The file pins the SHA-256 of the state after every input, so an engine change that alters one byte of one state fails the test until the corpus is regenerated on purpose.

What it is not yet is playable. Engine **v1.0.27** carries all of it and the chain has pinned it since 23 October, so the code is in every validator. But there is no message to create a multi-table tournament, and the director needs the engine to start hands by itself, which the chain does not yet allow. The chain's new tournament leaderboard query serves the engine's ranking verbatim; until a tournament exists, it answers "not found".

## What reached the sit-and-go

Blind structures were built for multi-table tournaments, but nothing about them needs a second table, so sit-and-gos adopted them now. A sit-and-go used to have one schedule, with the blinds doubling every so many minutes. It can now be created with:

- **A preset.** Hyper-turbo (three-minute levels from 50/100), turbo (five minutes), standard (ten) and deep stack (fifteen minutes, blinds rising by half each level). Each adds a big-blind ante a few levels in.
- **A structure of your own**: doubling, linear or percentage growth, or an explicit table of levels with their own blinds, antes and durations. The SDK reads and writes a text form, so a structure can be written by hand as `BLINDS turbo` or a `BLINDS custom { … }` block.

The chain checks a structure at creation with the engine's own validation, so a bad one is refused before the table exists rather than stranding it later. The create form has a structure selector with a preview of the levels, and sit-and-go tables have a **Blinds** tab with every level, the ante and a countdown to the next.

**Late registration** came to scheduled sit-and-gos. A table can stay open after its start time while the blind level is below a number set at creation, and closes as soon as anyone has finished in the money. A late entrant gets the full starting stack and waits for the big blind. All four layers shipped it on 24 October, and it was tested on the main chain before the week was out.

**Fixed-limit hold'em** joins no-limit and pot-limit. Bets and raises are one big blind before the flop and on the flop, two on the turn and river, with four bets a street at most; before the flop the big blind counts as the first. A contributor wrote the engine half, their first pull request to the engine. The chain accepts fixed-limit for hold'em and still refuses it for Omaha, because the fuzzing so far covers hold'em. The client creates fixed-limit tables, and its bet controls show the single legal amount.

## Three engine releases, three halts

- **v1.0.26** on 20 October fixed the order winners of a pot are listed in, and froze blind positions from the blinds actually posted instead of recomputing them from whoever is active. It went out as **v0.1.188**, under the halt during which last week's stalled release pipeline was found and restarted. The pipeline fix followed the next morning as **v0.1.189**, so a failed Docker push no longer skips the deploy.
- **v1.0.27** on 23 October carried multi-table tournaments and blind structures, and went out as **v0.1.190** with the chain's blind-structure field and the leaderboard query. It also carries the engine half of commit-and-reveal dealing, which removes trust in the dealing validator and stays dormant until the chain half lands.
- **v0.1.191** on 24 October retired a chain message the client no longer needs. The engine already records each finisher's result on the action that busts them, so a sit-and-go claim now just leaves the table.
- **v1.0.28** on 24 October carried late registration and fixed-limit hold'em, as **v0.1.192**.

Two of these needed the client to move first, and this time the order was planned rather than discovered. The claim change was one. The other was the winning hand's wording, such as "Full House, Eights over Sevens", which used to be part of the state the chain stores, so changing a word was a hard fork. The engine now reports only the cards and the SDK derives the words. It needs the board as well as the hand to tell a "Set of Sevens" from "Trip Sevens". The client switched to the SDK's words before v1.0.27 was released, so no winner went unlabelled in between.

## What the fuzzer found

Within three days of the blind-position fix, the session fuzzer found a case it missed. If both blinds post, both players leave before the deal and come straight back, and only the small blind sits in again, the big blind's seat stayed the big blind with its player out of the hand. That is fixed in v1.0.27. The production sit-and-go payouts are now pinned by a test, and so is the guarantee the claim change relies on: a bust's result is recorded the moment it happens and stays put while the rest of the field plays on.

## The client

- **At the table.** An observer can call the clock on a stalled opponent. A replay control steps through the session's hands at the table, showing the hole cards the viewer actually knew at each step. Chips are photoreal marble by default with a flat option, in dollars and cents at cash tables and plain points at tournaments. The pot can be shown as chips.
- **Winning.** A banner names the last pot's winner and hand, a "+amount" pill rises from the winning seat, and the celebration can be switched off.
- **Betting.** Opening-raise buttons for 2×, 2.5×, 3× and 5× the big blind. Pot presets a stack can't cover are greyed out instead of turning into a shove. An armed **Call {amount}** no longer calls a raise that lands just before the player's turn; only **Call Any** does.
- **Creating.** The create form offers Cash Game, Sit & Go and Tournament, where a Tournament is a scheduled sit-and-go. **Start now** follows the start time and minimum players. Admins can set late registration from the tables page.
- **Fixed.** Recent Transactions no longer shows other players' joins as your own debit.

Thirteen of the client's 28 pull requests came from two contributors. The client's main branch now requires a code-owner approval and green build, unit and end-to-end checks before anything merges.

## Where that leaves it

The multi-table engine is on main, released and running inside every validator, but no one can enter a tournament on the chain yet. What changes that is the chain side of the director, and it waits on the engine starting its own hands. Meanwhile a sit-and-go can be created with a blind structure, kept open for late entrants or played fixed-limit, and late registration has already been tested on the main chain. The halt procedure ran three times without incident, with the client deployed first where it had to be.

---

*9 High Studios builds Block 52 — a provably fair, real-money poker platform where every hand is shuffled by verifiable randomness and settled on a public blockchain. Want to build a poker platform? [Get in touch.](https://ninehighstudios.com/contact.html)*
