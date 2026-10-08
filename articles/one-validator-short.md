---
title: "One Validator Short: Five Days Halted, and a Week Spent on Never Again"
author: Nine High Studios
date: 2026-10-08
tags: [Build Log, Validators, Infrastructure, Security]
---

# One Validator Short: Five Days Halted, and a Week Spent on Never Again

*The chain stopped because one machine went dark, and a network of three equal validators has no room to lose one. This week went on making sure that can't happen the same way twice.*

Between **28 September and 4 October 2026** we merged **10 pull requests** across the three Block 52 repositories. The raw count says **85,486 lines added** and **14,303 removed**. That headline is wrong, and the scoreboard explains why. Most of the real work this week went into one problem: what happens to the chain when a validator disappears.

## The scoreboard

| Repository | Merged PRs | Lines added | Lines removed | Total changed |
|---|---:|---:|---:|---:|
| **UI** (the client) | 3 | 1,681 | 119 | 1,800 |
| **PVM** (the poker engine) | 4 | 482 | 23 | 505 |
| **Chain** (settlement) | 3 | 83,323 | 14,161 | 97,484 |
| **Total** | **10** | **85,486** | **14,303** | **99,789** |

An honest footnote, larger than usual. Of the chain's 83,323 added lines, **82,474 are a single markdown file**, `BUG-NON-DETERMINISM.md`. A documentation refresh went wrong and replaced a 164-line note with one ten-line section repeated 5,880 times. It isn't code and it isn't work, and it gets fixed next week. Leave it out and the week added **3,012 lines** and removed **14,149**. It was a week of deleting things, which fits what the week was about.

## Why the chain stopped

On 25 September, node1, one of our three validators, went offline because of a lapsed hosting bill. The chain halted at block **344,712** and stayed halted for five days.

The two validators that were still up were healthy. They agreed on state, with an identical app hash. They still couldn't continue. A block needs signatures from validators holding **more than two-thirds** of the voting power, and two out of three equal validators hold exactly two-thirds. That's not enough. The chain didn't fork or lose anything. It just stopped.

While we looked into it we found a second problem. Every node in the network listed node1 as its **only** persistent peer, and peer exchange was switched off. Once node1 was gone, the two survivors couldn't even reach each other.

So two separate problems were hiding in that halt. The arithmetic was fragile: **three equal validators have zero fault tolerance**, and only a fourth validator fixes that. The topology was fragile too, because everything hung off one host. Fixing the topology doesn't change the arithmetic, but it means that once there are enough validators, losing one host can't cut the network in pieces.

## Fixing the topology

The chain's documentation had drifted far enough from reality to be dangerous, so the first pull request rebuilt it from the live chain. The validator table had listed five validators, and one node ID and pubkey were wrong. It now lists the three bonded validators exactly as they are. It also writes down the new pattern: **validators peer directly with each other, seed nodes exist only for discovery, and peer exchange is on everywhere**. Another node can now disappear without taking any connections down with it.

Along the way we found that the committed `genesis.json` had **zero genesis transactions**, so it couldn't have booted a chain at all. The live chain runs the September USDC reset genesis, and the repository now holds that file, with every pinned hash updated. **48 stale documents** describing earlier versions of the network were deleted. That one pull request removed 12,286 lines.

The follow-up made the embedded Go engine the default configuration, which is what every validator already runs. One node template had no engine section at all, so a node built from it panicked on startup. Every script that still priced gas in `stake` on a USDC-only chain was corrected; a node configured that way rejects every transaction it sees. The old PVM deployment tooling was removed. The `create-validator` scripts were fixed to use the JSON-file form our Cosmos SDK version requires, because the flag form they'd been using is rejected outright. Chain releases **v0.1.168** and **v0.1.169** went out the same morning.

## Making a fourth validator possible

Better peering keeps the network connected. It doesn't change the arithmetic. For that you need more validators, and until this week, adding one meant a set of shell commands and a conversation with us.

So the SDK gained `createValidator`, released as **sdk-v1.5.1**. It checks a validator registration against the same rules the chain enforces before anything is signed: a 32-byte Ed25519 consensus key, a commission rate at or below its maximum, and a self-delegation above zero. Its tests use the live encoding from one of our real validators.

On top of that, the client's `/nodes` page became a self-service node portal with three tabs:

- **Network & Genesis** shows live chain facts and the bonded validator set, plus the network's **current fault tolerance**. Today that number is zero. The genesis file is SHA-256 hashed in your browser and checked against the pinned hash, so you aren't trusting our server for it.
- **Run a Node** gives you copy-ready config. It includes the seed-and-PEX pattern above, plus state sync with a trust height read live from the chain.
- **Become a Validator** signs the registration from your Block 52 wallet.

The validator tab has one rule we're glad we added: it **refuses any bond that would give one validator a third or more of the voting power**. A validator that large can halt the chain by itself just by going offline. We've now seen what that looks like with only a third of the power at stake, and we'd rather the portal didn't let someone rebuild the same risk with more weight behind it.

## A security fix

Our payments proxy had an admin endpoint for manually bridging USDC onto the chain. It had **no authentication**. The browser-side CORS rules made it look protected, but they only restrict browsers, not anything else that sends a request. It's fixed. The bridge routes now require an admin key, compared in constant time. If that key is missing or too short, the routes **fail closed** for everyone, so a missing environment variable can never reopen them. Eight tests mount the real router, and six of them fail against the unguarded version.

## The rest

- **An engine rules fix.** A player joining a heads-up table with "post now" was charged both the entry big blind and the small blind. That's because the engine worked out the small blind's seat *before* the new player counted as active, and with three players the seat moves. Entrants who would land on a blind now wait a hand, and one who lands on the big blind just posts it. This changes how the game state evolves, so it ships with the next coordinated engine release.
- **Time bank, chain side.** The chain now accepts a `time-bank` action, but only from the player whose turn it is, and only with the embedded engine. It won't do anything until the next engine release includes it.
- **Client hygiene.** All **37** `catch (err: any)` sites in the client now use typed error narrowing, and a CI step fails the build if one comes back. A contributor also replaced per-seat array scans for showing cards with an indexed lookup.
- **Release plumbing.** The SDK's publish check had marked a good release as failed because the npm registry hadn't caught up yet. It now waits on the same data `npm install` reads, and retries.

## Where that leaves it

The chain is running, the topology no longer hangs off one host, and anyone can now register a validator without asking us. The fault-tolerance number on the new portal still reads **zero**, and it stays zero until a fourth validator bonds. That's the next thing to fix.

---

*9 High Studios builds Block 52 — a provably fair, real-money poker platform where every hand is shuffled by verifiable randomness and settled on a public blockchain. Want to build a poker platform? [Get in touch.](https://ninehighstudios.com/contact.html)*
