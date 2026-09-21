---
title: "Seven Pull Requests: A Clockwise Showdown and a Clock Anyone Can Call"
author: Nine High Studios
date: 2026-09-21
tags: [Build Log, Engine, Showdown, Determinism, Animation]
---

# Seven Pull Requests: A Clockwise Showdown and a Clock Anyone Can Call

*A short build log from the felt: a small week by count, spent on two rules every poker player already knows.*

This was a quiet week by the numbers. Between 14 September and 20 September 2026 we merged **7 pull requests** across the three Block 52 repositories, adding **6,580 lines** and removing **3,711**. A week that size gets a short article. But two of those seven changed how the engine behaves at the table, and both are worth explaining.

## The scoreboard

| Repository | Merged PRs | Lines added | Lines removed | Total changed |
|---|---:|---:|---:|---:|
| **UI** (the client) | 4 | 1,646 | 96 | 1,742 |
| **PVM** (the poker engine) | 3 | 4,934 | 3,615 | 8,549 |
| **Chain** (settlement) | 0 | 0 | 0 | 0 |
| **Total** | **7** | **6,580** | **3,711** | **10,291** |

Three honest footnotes. The UI row flatters us: one of its four PRs re-lands another that merged one branch short of main, so the same six files are counted twice. Counted once, the client added 998 lines and removed 48. Of the engine's 3,615 removed lines, 3,291 were a single PR deleting a smoke-test harness for the old WebSocket gateway, which is archived and had nothing left to talk to. And the chain row is a real zero, which matters for how to read everything that follows.

## The big one: showdown, in order

The largest change of the week — 4,157 lines added across 33 files — teaches the Go engine something every live dealer does without thinking: **hands are shown one at a time, clockwise, and a beaten player may muck.**

Until now, any live player could show or muck in any order. The best hand still won the pot, but it wasn't poker as played. At a real table the order matters: if the player before you has already shown the nuts, you're entitled to throw your cards away unseen.

The new showdown runs clockwise from the first seat after the dealer button:

- The **first player**, every **all-in player**, and anyone whose hand can **beat or tie** the best hand shown so far is revealed automatically. No button, no action to sign.
- Only a player who is **already beaten** pauses the sequence. They — and only they — are offered *show* or *muck*.
- Show and muck are now **turn-ordered**. If it isn't your reveal, the engine rejects the action.
- A player who mucks gets a new visible status, `mucked`. Internally they're still treated as folded, so none of the evaluation or round-end code had to change to accommodate it.

There's a cost, and it's worth stating plainly. Last month we wrote about proving the Go engine byte-for-byte identical to the TypeScript original. This change **deliberately breaks that parity at showdown**. The TypeScript engine is deprecated and won't learn the new behaviour, so the parity harnesses now skip showdown snapshots. Everything before showdown still matches byte-for-byte; the new behaviour is covered by its own tests, including one that drives the full sequence through the same entry point the chain uses.

## An action clock anyone can call

The second engine change is smaller — 777 lines added across 8 files. The engine now has an **action clock**, and it's implemented as a transaction rather than a timer.

We'd tried this before in TypeScript and reverted it. That version checked for expired turns while serialising the table, which meant *reading* a table could sit a player out. And with multiple validators, "has this player run out of time?" is a dangerous question: two hosts answering it against their own clocks can disagree, and disagreement is a consensus failure.

So the clock is now an explicit, **permissionless `timeout` action**. Any address can submit it. The engine checks that the table has a timeout configured and that the deadline for the player on the clock has passed — measured from the most recent recorded action in the hand, against the timestamp of the `timeout` action itself. If so, it plays that player's forced default *as them*: check if it's legal, otherwise fold; post the blind they owe; muck at showdown if they can, otherwise show.

Because expiry is a pure function of the stored state and the action's timestamp, every validator applying the same `timeout` at the same block time reaches the same bytes.

A timed-out player is **not** sat out. They stay active and get dealt into the next hand, so in a tournament they're blinded off and bust normally instead of stalling a heads-up finish.

One known gap: a hand with no recorded action yet has nothing to anchor the clock on, so the first blind poster can't be timed out. That gets closed by having the engine post blinds itself, not by a cleverer clock.

We cut **v1.0.17** of the Go engine module right after the clock merged. It carries the clock but not the new showdown, which landed two days later.

## The UI: cards that actually get dealt

All four client PRs were one feature: **animating the hole-card deal**. Today, cards simply appear in front of each seat. The plan is for them to fly from the deck, one at a time, clockwise from the seat after the button — the way a dealer pitches them.

What merged this week is deliberately the unglamorous half:

- A **350-line plan** first, as its own PR, so the design could be argued with before any code existed.
- **Phase 0:** one timing module that both the JavaScript and the CSS read, so the stylesheet can't drift from the animation budgets, plus the geometry of where the deck sits and where each seat's two cards land.
- **Phase 1:** a `cardsDealt` event and the decorator that puts seats in dealing order.

Phase 1 turned up a nice subtlety. The engine keeps hole cards through the end of a hand and only clears them when the next one starts, so a new deal never looks like "no cards, then cards" — it looks like "last hand's cards, then this hand's". An event that watched only for the first transition would have missed every deal after the first.

Nothing a player can see has changed yet. The rendering phase — the flying cards, the flip, a setting to turn it off, and an instant deal for anyone with reduced motion enabled — comes next. The plan's starting budget is a 90 ms stagger, a 200 ms flight and a 300 ms flip: about two seconds to deal a nine-handed table, under one heads-up.

## What hasn't shipped

Here's the part a scoreboard hides. With zero PRs merged to the chain, **neither engine change is live at a table yet.** The action clock needs the chain to accept `timeout` as a valid action and, eventually, to submit it for idle tables at block time. The showdown needs an engine tag, a chain bump, the `mucked` status in the SDK, and a client that drives show and muck from the engine's legal actions. Both change what validators compute, so they go out as a coordinated release rather than a quiet deploy.

So: a small week, mostly spent making the engine behave like a dealer would — reveal in order, let the loser muck, and don't let one player hold up the table forever. Next week's job is getting it to the felt.

---

*9 High Studios builds Block 52 — a provably fair, real-money poker platform where every hand is shuffled by verifiable randomness and settled on a public blockchain. Want to build a poker platform? [Get in touch.](https://ninehighstudios.com/contact.html)*
