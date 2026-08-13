---
title: "Three Weeks, Three Repos, 66,000 Lines: Porting the Poker Engine to Go"
author: Nine High Studios
date: 2026-08-13
tags: [Build Log, Go, Engine, Provably Fair, Blockchain]
---

# Three Weeks, Three Repos, 66,000 Lines

*A short build log from the felt: what 102 merged pull requests actually bought us.*

Every so often it's worth stopping and counting. Over the last three weeks — from 23 July to 13 August 2026 — we merged **102 pull requests** across the three repositories that make up Block 52, and changed roughly **66,000 lines of code** doing it. Here's what those numbers were actually spent on.

## The scoreboard

| Repository | Merged PRs | Lines added | Lines removed | Total changed |
|---|---:|---:|---:|---:|
| **UI** (the client) | 15 | 1,139 | 1,708 | 2,847 |
| **PVM** (the poker engine) | 59 | 42,645 | 9,881 | 52,526 |
| **Chain** (settlement) | 28 | 8,725 | 2,213 | 10,938 |
| **Total** | **102** | **52,509** | **13,802** | **66,311** |

The Poker Virtual Machine dominates the count, and that isn't an accident. Almost the entire engine got a second life in a new language.

## The big one: porting the engine to Go

For most of the last year the **Poker Virtual Machine** — the code that owns the rules of poker, decides whose turn it is, what's legal, who wins the pot, and what a tournament pays out — has lived in TypeScript. It's correct, it's battle-tested, and it's been dealing real hands.

But the settlement chain is written in Go. Every time the chain needed the engine's answer, it had to reach across a language boundary. So over these three weeks we did something deliberately unglamorous and slightly terrifying: we ported the entire engine to Go, **one-to-one, phase by phase**, and proved it byte-for-byte identical to the original.

You can read the whole arc in the commit history:

- **Phase A–E** rebuilt `PerformAction` — the heart of the engine — piece by piece: the execute seam, player actions, sit-in/sit-out/top-up, the round dispatch spine, real card dealing, winner determination with side pots and rake, mucking, and finally wiring it all onto a live game so a full hand plays end to end.
- We ported the strategy-pattern managers 1:1 from TypeScript in a single 7,600-line move.
- Then came the part that lets us actually trust it: a **byte-for-byte parity harness**. We replayed a corpus of real poker hands — eventually a full sweep of roughly **2,000 No-Limit Hold'em hands** — through both the old TypeScript engine and the new Go engine, and demanded the output match exactly, field for field. It flushed out several genuine bugs in the process (a straight that mis-scored, an END-of-round "next to act" fallback, winner-seat and last-action details), and each one got fixed until parity hit 31/31, then held across the whole dataset.

We benchmarked the in-process Go engine, gave it an embedded entry point, and cut versioned Go-module release tags so the chain can pin an exact engine version — v1.0.0, then v1.0.2, v1.0.3, v1.0.4 as fixes landed. By the end of the three weeks the chain can run the poker engine **in-process**, in Go, behind a flag, with bots already playing on it.

That's the bulk of the 52,000 lines in the engine repo: a full second implementation, plus the test corpus that keeps the two honest.

## The chain: an authoritative deck and an optimistic oracle

While the engine was being reborn, the settlement chain got two significant upgrades.

**A chain-authoritative deck.** We moved the deck of cards so that the *chain* — not the client, not the engine — is the authoritative source of the shuffle for every hand, folding a player's own entropy seed and a VRF (verifiable random function) seed together. This closes a subtle "fork" where two parties could disagree about which deck was real. The client now sends its seed; the chain shuffles; everyone can check the result later.

**An optimistic mempool oracle.** Waiting for a block before you see your card is slow. So we built a flag-gated "optimistic oracle": the moment an action hits the chain's mempool, the WebSocket server can broadcast the result, reproducibly seeded, without waiting for final settlement underneath. The settlement still happens — it's just no longer standing between you and the felt on every action.

There was also the careful, boring, important stuff: letting a player *always* leave a cash game, forfeiting the pot correctly on a mid-hand leave, settling cash by on-chain balance delta, and replacing a "new block" heartbeat with real hand-lifecycle events so the UI learns what happened the instant it happens.

## The UI: getting out of the chain's way

The client's story over these three weeks is one of **deletion**. The headline UI change removed nearly 1,500 lines: we **retired the legacy gateway transport** entirely and made **chain-direct the default**. The client now talks to the chain directly, renders the relay's optimistic mempool push, and always carries the player's seed on new hands.

The rest was polish with real user impact: indexing players by seat to kill some O(n²) scans on every render, surfacing a stale action as a *retryable* error instead of silently wedging the table, decoding blockchain-explorer message types dynamically instead of from a hardcoded list, and — a personal favourite — fixing the Pixel Fold so an open-landscape fold is treated as mobile-landscape and no longer hides half the table behind a white gutter.

## The through-line

If there's a theme to these three weeks, it's the same one that's run through the whole project: **make it verifiable, then make it fast.**

Porting the engine to Go wasn't about the language — it was about being able to run the exact same rules *inside* the chain, so there's no gap between "what the engine decided" and "what got settled." The authoritative deck was about removing the last place where two honest parties could disagree about a shuffle. The optimistic oracle was about making all of that feel instant without giving up the receipts.

Sixty-six thousand lines is a lot to change in three weeks. But most of it exists to make one sentence true: *you can check for yourself.*

---

*9 High Studios builds Block 52 — a provably fair, real-money poker platform where every hand is shuffled by verifiable randomness and settled on a public blockchain. Want to build a poker platform? [Get in touch.](https://ninehighstudios.com/contact.html)*
