---
title: "Three Halts to the Felt: The Week the Engine Went Live"
author: Nine High Studios
date: 2026-09-24
tags: [Build Log, Engine, Releases, Consensus, Mobile]
---

# Three Halts to the Felt: The Week the Engine Went Live

*Last week's build log ended with a job for this one: get it to the felt. Four days in, it's there — and playing on it found things no test had.*

Last week's article closed on an awkward admission. Two changes had landed in the Go engine — a clockwise showdown and an action clock — and **neither was live at a table**, because the chain hadn't moved at all. The scoreboard's chain row was a real zero.

Between **21 September and 24 September 2026** — four days, not a full week — we merged **63 pull requests** across the three Block 52 repositories, adding **13,141 lines** and removing **4,284**. The chain row went from zero to twelve, and the engine went to the felt three separate times.

## The scoreboard

| Repository | Merged PRs | Lines added | Lines removed | Total changed |
|---|---:|---:|---:|---:|
| **UI** (the client) | 41 | 8,850 | 3,673 | 12,523 |
| **PVM** (the poker engine) | 10 | 1,816 | 339 | 2,155 |
| **Chain** (settlement) | 12 | 2,475 | 272 | 2,747 |
| **Total** | **63** | **13,141** | **4,284** | **17,425** |

Two honest footnotes, in the tradition of the last one. This is **four days, not seven** — Friday to Sunday are still to come, so every number here is a floor rather than a total. And the UI row double-counts again: mobile round 2 merged into a dead branch instead of main last week, so it was re-landed this week and both pull requests are in the count, 159 added and 117 removed twice over.

## Getting it to the felt

The blocker was never the engine. It was that shipping a consensus change is not a deploy.

If validators restart one at a time while the rules are changing underneath them, they disagree about what the same hand means, and disagreement is a fork. So the first thing that had to exist was the procedure itself: a **coordinated halt**. Every validator stops at an agreed block height, everyone upgrades against a stopped chain, everyone starts again on the new binary. It landed as two workflows — one to call the halt, one to cut the release — in 321 lines that add nothing a player can see and without which nothing else this week could have shipped.

Then we used it three times:

- **v1.0.18** — the sequenced clockwise showdown and the action clock, the two changes last week's article said were stranded.
- **v1.0.19** — an uncalled bet is returned rather than reported as a win, and the last aggressor shows first.
- **v1.0.20** — a showdown deadlock, found in production the same day it shipped.

Each halt was verified the same way: every validator reporting an **identical app hash at the halt block**. Same height, same bytes, same state. That check is the whole point — it's the difference between "the upgrade worked" and "the upgrade appears to have worked."

Twelve chain releases went out across the four days, `v0.1.156` through `v0.1.167`.

## What playing on it found

Three engine bugs reached production this week, and all three were found by people playing rather than by tests. That's worth being plain about.

**An uncalled bet was reported as a win.** If you shove and everyone folds, the portion nobody called is not winnings — it's your own chips coming back. The engine returned them correctly but announced them as a pot won, so the table showed you winning money you'd never risked. The fix returns the chips with no winner recorded at all.

**The wrong player showed first.** At a real showdown the last aggressor tables first, and everyone else reveals clockwise from there. The engine was ordering by seat number instead, which is the rule nobody plays by.

**And then a table wedged solid.** A player mucked at showdown, and the hand stopped — pot locked, no winner, no action any seat could take to finish it. The cause is a good illustration of how a chain differs from a server. `mucked` is a *presentation* status: internally such a player is simply folded, and every check in the engine is written against that. But the chain is **stateless per action** — every action rebuilds the game from its serialised form — so the display value was read straight back in as the real one. From that moment the player was genuinely "mucked", a status no check knew about. They counted as still live, so the showdown could never end; and they were never reset, so they were never dealt into another hand either.

The fix normalises the status back at the boundary where the game is rebuilt, which restores the invariant instead of teaching every check about a second status. It went out as v1.0.20 with a regression test built from the actual stuck table.

## One outbound queue

The other production problem had nothing to do with poker.

Every action a player takes is a signed transaction. Cosmos transactions carry an account sequence number, and if two are signed with the same one, the second is rejected. The client had several places that could each fire an action — the buttons, and a set of automatic hooks for posting blinds, dealing, folding on the clock, showing and mucking — and each held its own "am I busy?" flag. One signing key, several independent guards, nothing serialising between them.

At hand start three of those fire in a row. In an eleven-hand heads-up sit-and-go they collided ten times, and every rejection was written to the browser console and nowhere else. The manual "Post Small Blind" button players kept seeing wasn't a design choice — it was the fallback after the automatic post had been rejected.

It's fixed from both ends. The SDK now signs gameplay transactions as **unordered**, which removes the sequence from the equation entirely, and every automatic hook routes through the same submission queue the buttons use, so there is exactly one outbound path per account — and a rejection now reaches the player instead of the console.

## Mobile, and the merit of deleting things

Of the 41 client pull requests, the largest removed far more than it added: the mobile portrait rework is **+840 / −1,504**, a net deletion of 664 lines, and it produced a *better* table — native vertical layout, one-row header, the rest behind a hamburger. The refactor that routed those automatic actions through one queue is +683 / −712, near enough a wash.

A week measured only in lines added would call that a bad week.

## Two security fixes worth naming

The SDK had a `signWithdrawal()` helper that put an **Ethereum private key into a transaction**. It's gone — 272 lines removed against 85 added.

And the chain was logging its Ethereum RPC URL on startup, API key and all, into any log aggregator watching. It now logs the host and nothing else.

## Where that leaves it

The engine is on the felt, the release procedure exists and has been exercised three times, and the failures we're now finding are the ones you only get by playing on the thing. That's a better class of problem than "it hasn't shipped."

Three days of this week are still to come, so these numbers will move. The next job is the one playing has already made obvious: keep the feedback loop between a real table and a released engine as short as it was this week.

---

*9 High Studios builds Block 52 — a provably fair, real-money poker platform where every hand is shuffled by verifiable randomness and settled on a public blockchain. Want to build a poker platform? [Get in touch.](https://ninehighstudios.com/contact.html)*
