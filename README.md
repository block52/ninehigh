# 9 High Studios

Poker software development company building the future of digital poker.

## About

9 High Studios is a specialized software development company focused exclusively on poker applications. We combine deep understanding of poker mechanics with cutting-edge technology to create products that players love.

Our team brings together experienced poker players, game theorists, and software engineers united by a passion for building the best poker software in the industry.

## Player First

**Every feature we ship gets tested at our own home games first. If it doesn't feel right at 2am with real money on the line, it doesn't ship.**

We're not a team of developers who read about poker. We're players who learned to code. That difference shows in every decision we make - from the snap-responsive fold button to the shuffle algorithm we spent months perfecting.

- **We play what we build** - Weekly home games are our first QA environment
- **Details matter** - Milliseconds, animations, chip sounds - we sweat it all
- **Trust is everything** - Provably fair isn't a feature, it's a requirement
- **No shortcuts** - We'd rather delay than ship something we wouldn't play

## Block 52

Our flagship product is **Block 52** - a next-generation poker platform built from the ground up with modern architecture, provably fair mechanics, and seamless multiplayer experiences.

### Features

- **Real-time Multiplayer** - Sub-second latency for smooth gameplay
- **Provably Fair** - Cryptographic verification ensures every shuffle and deal can be independently audited
- **Tournament & Cash Games** - Full tournament management with customizable structures
- **Cross-Platform** - Native experiences across web, iOS, Android, and desktop
- **Deep Analytics** - Comprehensive hand histories, statistics tracking, and performance insights
- **White Label Ready** - Fully customizable branding for operators launching their own poker room

## Research

### CardLang

We develop **CardLang**, a domain-specific language for formally specified card games. By treating fundamental card game concepts as language primitives, we enable game definitions that are both human-readable and mathematically precise.

Key contributions:
- **Primitive Types** - Minimal set of types (`Rank`, `Suit`, `Card`, `Deck`) that capture the essential structure of card games
- **Deterministic Shuffling** - Fisher-Yates algorithm with cryptographic seeding for provably fair, reproducible shuffles
- **Commitment-Based Seeds** - Multi-party seed generation preventing manipulation in adversarial multiplayer settings
- **Verified Compilation** - Compiler generates correct-by-construction implementations

### Fisher-Yates Shuffle Algorithm

Our shuffle implementation uses the Fisher-Yates algorithm with a 256-bit cryptographic seed:

```
Input:  Deck D = [c₀, c₁, ..., cₙ₋₁], seed s ∈ {0,1}²⁵⁶
Output: Permuted deck D'

1. Initialize RNG with seed s
2. For i = n-1 downto 1:
   a. j ← random(0, i)    // Uniform in [0, i]
   b. Swap D[i] and D[j]
3. Return D
```

Combined with our commitment scheme, no coalition of fewer than n players can predict or influence the shuffle outcome.

## Tech Stack

- Static website built with HTML/CSS
- Modern responsive design
- Hosted via GitHub Pages

## Contact

**Email:** hello@9highstudios.com

## License

Copyright 2025 9 High Studios. All rights reserved.
