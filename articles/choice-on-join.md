---
title: "Choice on Join: A Week Spent on Sitting Down"
author: Nine High Studios
date: 2026-09-04
tags: [Build Log, UI, Release Engineering, Tournaments]
---

# Choice on Join: A Week Spent on Sitting Down

*Eighteen pull requests, 2,270 lines and nine chain releases — nearly all of it about the thirty seconds before your first hand.*

From 24 August to 30 August 2026 we merged **18 pull requests** across the three Block 52 repositories and changed **2,270 lines** doing it — 1,635 added, 635 removed, across 51 files. The settlement chain cut **nine releases** in those seven days. By line count this was a small week. By subject it was an unusually focused one: almost everything that shipped was about the moment a player joins a table and decides whether they are in *this* hand or the next one.

## The scoreboard

| Repository | Merged PRs | Lines added | Lines removed | Total changed |
|---|---:|---:|---:|---:|
| **UI** (the client) | 8 | 1,187 | 564 | 1,751 |
| **PVM** (the Poker Virtual Machine) | 0 | 0 | 0 | 0 |
| **Chain** (settlement) | 10 | 448 | 71 | 519 |
| **Total** | **18** | **1,635** | **635** | **2,270** |

The PVM repository recorded no merged pull requests at all this week. That row is a zero and we are going to leave it as a zero — the engine work that mattered arrived in the chain as version bumps, which is exactly what the Go port was for.

## Six pull requests about one screen

Six of the eight UI pull requests touch the same flow: what the client does when you arrive at a table.

It used to decide for you. On bootstrap, the client would fire a sit-in and seat you, which is fine right up until the table is mid-hand, or you are owed a big blind, or you wanted to watch a lap before committing money. So we took it apart over five merges in four days:

- **#546** (24 Aug, +56/&minus;1) restored the *Sit In And Wait for BB* button that had gone missing.
- **#547** (26 Aug, +70/&minus;15) taught the join path to handle a `WAITING_FOR_BIG_BLIND` status instead of treating it as an unexpected state.
- **#548** (26 Aug, +111/&minus;41) is the one the week is named after: choice-on-join. No auto-fire on bootstrap. You arrive, and you say what you want.
- **#549** (27 Aug, +67/&minus;78) turned those options into a radio panel that commits on select, with no separate confirm button. It is the first PR of the week to remove more than it added.
- **#555** (27 Aug, +153/&minus;17) then put the whole thing behind a `sitInOptions` toggle, with auto-sit-in as the default and the radio panel as opt-in.

That last step is worth being honest about. We spent four days removing an automatic behaviour and then shipped a toggle that restores it as the default. The difference is that the automatic path is now one branch of an explicit decision rather than the only thing the code knows how to do, and any table can turn it off. But the shape of the work was "make it a choice," not "make it stop."

## 723 lines in, 396 lines out

The single largest change in the UI this week was **#556** (27 Aug): a per-seat committed-action echo, a rebase of a long-lived branch onto main, **+723 lines across 6 files and not one deletion**. Every seat got a small bubble showing the action that player had just committed.

**#559** merged 28 hours later, on 28 August: *remove per-seat action echo bubble*, **&minus;396 lines across 5 files, zero additions**. It closed the issue the bubble itself had opened.

It did not work at the table. It read as noise on a busy board and duplicated information the seat already carried, so it came out. The underlying plumbing stayed; only the bubble went. Between them those two pull requests account for 723 of the UI's 1,187 additions and 396 of its 564 deletions — more than half the client's churn for the week is one feature arriving and mostly leaving again.

Shipping something for a day and pulling it is a cheaper way to find that out than arguing about it for a month.

## The chain: nine releases, six engine bumps

The chain merged 10 pull requests for only 519 changed lines, but recorded 25 commits and published nine releases, v0.1.131 through v0.1.139. Most of those commits are the automated version bump that follows each merge.

That release cadence exists because of the first fix of the week. **#310** (24 Aug, +7/&minus;0, one file) granted `packages:write` to the auto-tag workflow, which had been failing at startup and blocking every release since v0.1.130. v0.1.131 was published three minutes after it merged, and the tagger has not missed one since.

Six of the ten chain PRs are engine adoptions, pulling the embedded Go engine forward one version at a time:

- **v1.0.6** — rake payout fix (#309)
- **v1.0.7** — wait-for-BB heads-up rotation fix (#314)
- **v1.0.8** — choice-on-join, matching the UI work above (#315)
- **v1.0.9** — post-now entry blind and a small-blind-seat deadlock (#316)
- **v1.0.10** — SNG finalise fix (#317)
- **v1.0.11** — SNG sit-in bootstrap fix (#320)

Each of those is a three-line change to two files. Six engine fixes reached production for eighteen lines of chain code, because the engine is a pinned Go module rather than a service on the other side of a language boundary. That is the whole return on last month's port, showing up as a rounding error in the diff.

The chain's one real code fix was **#319** (28 Aug, +50/&minus;10): tolerate partial `Results` in `maybeFinalizeSNG`. Tournament finalisation assumed it would always be handed a complete result set, which is not true of a chop or of a tournament still working through multiple hands. It now finalises on what it actually has.

## The rest

**#313** (26 Aug, +361/&minus;35) was the largest single chain PR of the week: a Docker option for running the chain locally, so a local testnet is one command rather than an afternoon.

**#312** (+12/&minus;8) retired the node2 Docker deploy path, node2 having moved to bare-metal systemd — deleting a deploy route we no longer use before it rots.

And **#554** (+7/&minus;16) came from a Copilot agent, the only bot-authored merge of the week: the Top-Up Chips button is now always clickable while you are seated. A net deletion of nine lines to remove a disabled state nobody wanted.

## The through-line

Weeks like this do not photograph well. Two thousand lines is a slow week by any measure we have, and a meaningful slice of it was a feature that lasted a day.

But look at what the small numbers are made of. Six engine fixes shipped for eighteen lines. A stuck release pipeline was unblocked by seven lines and produced nine releases behind it. A feature that did not work at the table was gone the next morning without a migration. The join flow that used to be an assumption is now a setting.

Most of the leverage in a project this size is built in the loud weeks and spent in the quiet ones. This was a quiet one.

---

*9 High Studios builds Block 52 — a provably fair, real-money poker platform where every hand is shuffled by verifiable randomness and settled on a public blockchain. Want to build a poker platform? [Get in touch.](https://ninehighstudios.com/contact.html)*
