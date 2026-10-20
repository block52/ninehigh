---
title: "The October Delta: Three Validators to Four, Two Engines to One"
author: Nine High Studios
date: 2026-10-20
tags: [Build Log, Monthly, Validators, Engine, Releases]
---

# The October Delta: Three Validators to Four, Two Engines to One

*Not what we did in October, but what is different about Block 52 on 20 October from what it was on 1 October, measured against where September left it.*

The weekly build logs count pull requests. This one counts state. Between **1 October and 20 October 2026** we merged **98 pull requests** across the three Block 52 repositories, adding **26,997 lines** and removing **240,581**. September, a full month, merged 134 and added 126,167. Both figures carry one distorting file: September's was an 82,474-line documentation accident, October's is the 231,180-line deletion of the TypeScript engine. Take those out and the two periods are the same size. What they changed is not.

## The scoreboard

| Repository | Merged PRs | Lines added | Lines removed | Total changed |
|---|---:|---:|---:|---:|
| **UI** (the client) | 44 | 10,545 | 2,375 | 12,920 |
| **PVM** (the Poker Virtual Machine) | 33 | 13,933 | 237,543 | 251,476 |
| **Chain** (the settlement chain) | 21 | 2,519 | 663 | 3,182 |
| **Total** | **98** | **26,997** | **240,581** | **267,578** |

For comparison, September's 134 pull requests split 71 client, 32 engine and 31 chain. The client's share fell and the engine's rose, which matches where the month went.

## What is different

### Validators: three to four

On 1 October the chain had three equal validators and a fault tolerance of **zero**. It had just come back from a five-day halt caused by losing one of them. On **7 October** a fourth validator, MDAssets, bonded at block **452,611**. Four validators of roughly equal weight can lose any one of them and keep producing blocks. The largest single share of voting power is now **25.6 per cent**, under the one-third that lets a single validator halt the chain by going offline. The chain produced **303,749 blocks** in the twenty days, from 359,772 to 663,521, and has not stopped once except on purpose.

### Engines: two to one

On 1 October the repository held two poker engines: the Go engine that runs in consensus, and the TypeScript engine it was ported from. On 14 October the TypeScript engine was removed, archived with its history in a public repository, and every disagreement between the two is now a logged issue there rather than an open question. There is one engine, and it is the one the validators run.

### Releases: the halt is routine now

September ended with the coordinated-halt procedure built and tested once. October ran it **five times**: on 13 October, three times on 14 October, and on 20 October. Four were clean. One was merged before the halt had taken hold, rolled the validators one at a time, and got away with it because no hand-affecting transaction landed in the window; the rule that prevents a repeat is on the runbook. The engine went from **v1.0.20 to v1.0.26**, six releases, and the chain from **v0.1.170 to v0.1.188**, nineteen.

The pipeline also failed quietly. From 14 October the automatic release was broken by a rejected tag push, and the release before that had published without deploying. Two chain changes merged that fortnight, the engine's timeout handling and the tournament-format guard, did not reach the validators until the 20 October halt carried them. That was found while running that halt, and the fix is open.

### Games: hold'em only to hold'em and pot-limit Omaha

On 1 October the platform played Texas hold'em. By 14 October pot-limit Omaha existed at every layer: four-card evaluation, the pot-limit cap and variant-aware dealing in the engine; the betting limit in the SDK; the variant passed through by the chain; four hole cards, equity and creation options in the client. No Omaha table has been opened on the main chain yet.

### Tournaments: sit-and-go to scheduled

On 1 October the only tournament format was a sit-and-go that started when the table filled. On 14 October scheduled single-table tournaments shipped end to end: a start time, **2 to 9 players**, payouts at every size, cancel-and-refund below the minimum, and a countdown with a Start now button in the client. Multi-table tournaments advanced on a branch through the month: a tournament director, directed tables, blind schedules with presets, big-blind antes, the tournament dealer rule and a byte-pinned golden run of a 20-entrant, three-table tournament. None of that is on the chain. It waits on the engine's hand-start release being pinned.

### Testing: single hands to whole sessions

Two tools were open-sourced in the month and then pointed at our own engine: a scene DSL that lets a test read like a hand history, and a session fuzzer that plays multi-hand sessions and checks invariants after every action. Together with a replay of the **21.6 million-hand** Poker Hand History dataset, they found and fixed, in October alone: a stall between hands, a blind posted by a seat not dealt in, uncalled excess lost on leaving, a short all-in that did not have to be called, blind positions drifting onto empty seats, positions collapsing at a bust-out, a mid-hand new hand wiping the pot, all-in blinds losing it, an entry post leaving a player active with nothing, a winners list whose order depended on a live lookup, and blind markers shifting when the big blind's post put them all-in. The engine's CI gained a static-analysis and a dead-code gate.

### Security

The payment proxy's manual-bridge endpoint, which had no authentication, now requires an admin key and fails closed without one (4 October).

### Money: deposits and withdrawals that were stuck

A customer's partially paid card deposit was not being bridged; those are now bridged exactly once, and the bridge admin page lists "paid but not credited" payments with a retry. Pending withdrawals that had been signed but never redeemed can now be redeemed from the client with a validator's on-demand signature.

### The client

In twenty days the client gained a hand-history page and a `?hand=N` link that opens any hand's final state, an in-table replay with a media transport through the session's hands that shows the cards the viewer actually knew, a clock that any observer can call on a stalled opponent, a pre-action bar, a single floating panel in place of two fly-outs, NFT viewing without a wallet, route-level code splitting, and the Omaha work above.

### Process

All three repositories now carry the same rule for filing work: search the open and closed issues of all three, grep the code of all three, then file one issue per idea with labels. A halt-recovery runbook exists. The indexer runs as a non-validating full node and halts with the validators.

## What did not move

- The engine release that lets the engine post blinds and deal on its own is built and released but **held off the chain**, so hands still start from the client and the multi-table director cannot go on-chain yet.
- No Omaha table and no scheduled tournament has been played on the main chain with real money.
- Fault tolerance is one, not two. A fifth validator would make it two.
- The commit-and-reveal shuffle that removes trust in the dealing validator is designed, not built.

## Where that leaves it

Four validators, one engine, two game variants, two tournament formats, and a release procedure that has now been run under pressure five times. The month's biggest number is a deletion, and the month's most important change is one bonded validator. The next delta should include a hand of pot-limit Omaha on the main chain, and the engine starting its own hands.

---

*9 High Studios builds Block 52 — a provably fair, real-money poker platform where every hand is shuffled by verifiable randomness and settled on a public blockchain. Want to build a poker platform? [Get in touch.](https://ninehighstudios.com/contact.html)*
