---
title: "One Engine: 231,000 Lines Deleted, Five Engine Releases, Four Coordinated Halts"
author: Nine High Studios
date: 2026-10-20
tags: [Build Log, Engine, Releases, Omaha, Security]
---

# One Engine: 231,000 Lines Deleted, Five Engine Releases, Four Coordinated Halts

*The TypeScript engine is gone, the Go engine shipped five releases in four days, scheduled tournaments and pot-limit Omaha reached the chain, and two ways to see the deck were closed.*

Between **12 October and 18 October 2026** we merged **55 pull requests** across the three Block 52 repositories, adding **16,285 lines** and removing **237,022**. The removal figure is almost entirely one pull request, and it is the headline of the week: Block 52 now has one poker engine, not two.

## The scoreboard

| Repository | Merged PRs | Lines added | Lines removed | Total changed |
|---|---:|---:|---:|---:|
| **UI** (the client) | 14 | 3,125 | 821 | 3,946 |
| **PVM** (the Poker Virtual Machine) | 27 | 10,997 | 235,656 | 246,653 |
| **Chain** (the settlement chain) | 14 | 2,163 | 545 | 2,708 |
| **Total** | **55** | **16,285** | **237,022** | **253,307** |

The honest footnote: of the PVM's 235,656 removed lines, **231,180 are the deletion of `pvm/ts`**, the original TypeScript engine, in one pull request. Leave it out and the week removed 5,842 lines. By pull-request count this was the busiest week since the Go port, and 27 of the 55 landed in the engine.

## One engine

The Go engine has been the only engine that runs at a table since September: it is compiled into every validator and executed inside consensus. The TypeScript engine stayed in the repository as a reference, and that had a cost. Two engines means two readings of every rule, and every time they disagreed somebody had to work out which was right.

So the TypeScript engine was removed and archived, with its full history, in a public repository of its own. Where the two genuinely disagree, the difference is logged there as an issue, with the Go behaviour and the rule it follows. Twelve divergences are recorded so far. Nothing that runs on the chain changed. What changed is that there is now exactly one answer to "what does the engine do here".

## Five engine releases, four coordinated halts

Changing the engine changes consensus, so every engine release reaches the chain through a coordinated halt: every validator stops at the same block, the deploy waits until all of them have, and they restart together on the new binary. This week used it four times.

- **v1.0.21** on 12 October carried Omaha.
- **v1.0.22** and **v1.0.23** on 13 and 14 October carried the rules fixes below, each under its own halt, about fourteen minutes from arming to every host reporting stopped.
- **v1.0.24** on 14 October carried scheduled single-table tournaments, and went wrong in a way worth writing down. The merge happened four and a half minutes before the halt was armed, so the halt queued behind the deploy it was meant to protect, and the validators rolled onto the new engine one at a time. No hand-affecting transaction landed in that window, so nothing forked. The runbook now says it plainly: **confirm the halt run reports every host stopped before anyone clicks merge.**
- **v1.0.25** on 15 October lets the engine post the blinds and deal instead of waiting for clients. It is released but not yet pinned by the chain.

The chain cut **13 releases** in the week, v0.1.174 to v0.1.186. A second footnote, found after the week closed: v0.1.186 built and published but never deployed. A transient failure pushing the Docker image failed the job before the deploy step, and the next release's tag push was rejected, which left the automatic release broken for the rest of the week. The validators ran v0.1.185 from Wednesday on. It was found and fixed on 20 October, and the pipeline change that stops a Docker failure from skipping a deploy is open.

## What the fuzzer and the dataset found

Two tools we wrote about last week joined the engine's own test suite: the session fuzzer, which plays whole multi-hand sessions and checks invariants after every action, and the scene DSL, which it now uses to print every failure as a readable, minimised hand. Between them and a replay of the full Poker Hand History dataset, **21.6 million hands**, the week fixed a run of rules bugs that single-hand tests had never reached:

- A table could **stall between hands**, a blind could be posted by a seat **not dealt in**, and a player's **uncalled excess was lost** when they left mid-hand.
- A **short all-in bet or raise was not treated as something the others must call**. The dataset found it: real hands diverged from the engine's answer.
- Blind positions are now **fixed per hand**: no drift onto empty seats, no seat handed somebody else's big blind, and positions that collapsed onto one seat at a bust-out are recovered.
- Two chip-destroying bugs fixed earlier on a branch reached main: a new hand started mid-hand **wiped the pot**, and blinds posted all-in **lost it**.

Alongside the fixes, a six-step cleanup went through the engine: one serializer, a shared player projection, 733 lines of managers orphaned by the clockwise showdown deleted, and 28 corpus tests that had been skipped as "blocked on a gap" ported now that the gaps are closed, which is where most of the week's added test lines come from. The engine's CI now runs `staticcheck` and a dead-code check on every change.

## Pot-limit Omaha, every layer

Omaha reached every layer this week. The engine gained a four-card evaluator, the pot-limit betting cap, and dealing and showdown that know their variant. The SDK carries the betting limit on creation and computes Omaha equity. The chain refused Omaha tables until it could pass the variant to the engine, then started passing it, in two pull requests a few hours apart. The client shows four hole cards at an Omaha seat, offers variant and limit when creating a table, and names the game with its limit in the lobby, so a table reads "Pot-Limit Omaha". There is no Omaha table on the main chain yet. That is the next test night.

## Scheduled tournaments

A sit-and-go used to start when the table filled. A scheduled single-table tournament starts at a set time with whoever has registered, from **2 to 9 players**, pays out at every size, and cancels with refunds below the minimum. The engine, the SDK (v1.8.0), the chain and the client all shipped their part on 14 October, with a countdown and a **Start now** button in the client.

At the same time the chain started refusing the `tournament` format at creation. Multi-table tournaments are being built on a branch, and until their director is on the chain, a "tournament" was a sit-and-go that settled incorrectly. Legacy ones now settle like a sit-and-go, and the client dropped the type from its create forms.

## Two ways to see the deck, closed

Both were found in review and fixed the same day, each under its own halt. The chain had a **public query that returned the deck**, undealt cards included, to anyone who asked for a game by ID. It is disabled. And a client could **supply its own deck** when starting a hand. The chain now rejects a client-chosen deck; our own bot was the only legitimate caller, and it sends a seed instead. With the previous week's change that stopped publishing the deck in the hand-started event, the deck is no longer readable from outside the engine at any point in a hand.

## The rest

- **Chain.** The engine's `timeout` action is accepted from any seated player, with a ten-second grace after the deadline. Action events carry the hand number, action index and block height, and a `hand_completed` event fires when a hand settles. A halt-recovery runbook was written, and the indexer was deployed as a non-validating full node so it halts with the validators.
- **Client.** A pre-action bar lets a player queue "check/fold" or "call any" before their turn, contributed in three pull requests. Other players' NFT avatars no longer depend on one gateway. Route-level code splitting cut the first-load JavaScript. Pot presets below the minimum bet are greyed out instead of silently resized.
- **Engine.** Sitting out is refused in sit-and-go and tournament games, matching the client.

## Where that leaves it

One engine, in one place, with a fuzzer, a dataset and a readable test language pointed at it. Scheduled tournaments and pot-limit Omaha are on the chain. The halt procedure has been run four times in a week and has one new rule. What the week did not do is put an Omaha table or a scheduled tournament in front of real players on the main chain, and the engine release that lets the engine start hands by itself is still waiting for the chain. Those are next.

---

*9 High Studios builds Block 52 — a provably fair, real-money poker platform where every hand is shuffled by verifiable randomness and settled on a public blockchain. Want to build a poker platform? [Get in touch.](https://ninehighstudios.com/contact.html)*
