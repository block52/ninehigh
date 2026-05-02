# Why Poker Is Not Solved — and Likely Never Will Be

## 1. What Does "Solved" Actually Mean?

Before we can argue that poker is unsolved, we need a precise definition of what it means to *solve* a game. Game theorists distinguish three increasingly demanding levels of solution:

- **Ultra-weak solution** — a proof of the game-theoretic value of the *initial position only* (win, loss, or draw under perfect play). The proof can be non-constructive; it need not tell you a single move. Strategy-stealing arguments fall in this category.
- **Weak solution** — an algorithm that, starting from the initial position, produces a strategy guaranteeing the proven value against any opponent. You can actually play it.
- **Strong solution** — an optimal move is known from *every legal position* the game can reach, not just the start. Endgame tablebases are the classic example.

These distinctions are central to the field and were popularized in Allis's PhD work and the subsequent literature.

## 2. Games That Have Been Solved

### 2.1 Tic-Tac-Toe — Strongly Solved (Trivially)

Tic-tac-toe is small enough that the entire game tree (≈ 26,830 positions, or 765 once symmetries are removed; 5,478 reachable game states under standard rules) can be enumerated by hand or trivially by computer. Perfect play by both sides results in a draw. It is *strongly* solved: the optimal move is known from every legal position.

### 2.2 Connect Four — Weakly Solved (1988)

Connect Four was solved independently in October 1988 by James D. Allen and, fifteen days later, by Victor Allis in his M.Sc. thesis *A Knowledge-Based Approach of Connect-Four* at Vrije Universiteit Amsterdam. Allis built a Shannon Type-C program, **VICTOR**, using nine domain-specific strategic rules ("claimeven," "baseinverse," "Aftereven," etc.) to prune the search.

Result: **with perfect play, the first player wins by playing the center column on move one.** Any other opening allows the second player to force a draw. The game tree was estimated at roughly 4.5 × 10¹² nodes — large, but tractable when combined with knowledge-based pruning.

### 2.3 Checkers — Weakly Solved (2007)

Checkers (English draughts) was weakly solved by Jonathan Schaeffer's group at the University of Alberta and published in *Science* in 2007 ("Checkers Is Solved"). The proof required ~50 computers running for nearly two decades of cumulative effort and combined three components:

1. An endgame database for all positions with ≤ 10 pieces (~3.9 × 10¹³ positions).
2. A proof tree starting from the opening position.
3. The **Chinook** search engine connecting the two.

Result: **perfect play leads to a draw.** Checkers has roughly 5 × 10²⁰ legal positions, making it about a million times larger than Connect Four and the most complex popular game solved to date.

## 3. Chess — Not Solved, and Effectively Unsolvable by Brute Force

Chess is the canonical example of a game that is known to be theoretically determinate (it is finite, perfect-information, and has no chance), yet remains unsolved.

### 3.1 The Shannon Number

In his 1950 paper *Programming a Computer for Playing Chess*, Claude Shannon estimated a lower bound on the chess game-tree complexity as:

$$10^{120}$$

derived from an average branching factor of ~30 and a typical game length of ~80 plies. Allis later refined this lower bound to ~10¹²³ using a branching factor of 35.

### 3.2 Why That Number Kills Brute Force

For perspective:

| Quantity | Approximate magnitude |
|---|---|
| Atoms in the observable universe | 10⁸⁰ |
| Microseconds since the Big Bang | ~10²⁴ |
| Shannon's lower bound for chess | 10¹²⁰ |

Even a hypothetical machine evaluating one chess variation per microsecond would require roughly **10⁹⁰ years** to evaluate the consequences of a single opening move — an interval that exceeds the age of the universe (~1.4 × 10¹⁰ years) by some 80 orders of magnitude.

This is why Shannon's paper itself argued *against* brute-force solution and proposed selective search and heuristics — the framework that eventually produced Deep Blue, Stockfish, and AlphaZero. Those engines play *very strongly*, but none of them solves the game in any of the three formal senses.

## 4. Poker — A Different Animal Entirely

Poker introduces three properties that none of the games above share:

1. **Imperfect information** — opponents' hole cards are hidden.
2. **Stochasticity** — community cards are dealt randomly.
3. **Bluffing / mixed strategies** — optimal play is generally non-deterministic; a "solution" is a probability distribution over actions, not a single move.

A "solution" to poker is therefore not a min-max game tree but a **Nash equilibrium strategy profile** — and equilibria in imperfect-information games are dramatically harder to compute and reason about than min-max trees.

### 4.1 The One Variant That Has Been (Essentially) Solved

In January 2015, Bowling, Burch, Johanson, and Tammelin published *"Heads-Up Limit Hold'em Poker Is Solved"* in *Science*. Their program **Cepheus** essentially weakly solved the smallest variant of poker played competitively by humans:

- **Game size:** 3.16 × 10¹⁷ reachable states; 3.19 × 10¹⁴ decision points (information sets).
- **Algorithm:** **CFR+** (Counterfactual Regret Minimization Plus), capable of solving extensive-form games three orders of magnitude larger than prior methods.
- **Compute:** ~4,000 CPUs evaluating 6 billion hands per second for two months — roughly 68.5 days of wall-clock time.
- **Definition of "essentially solved":** a lifetime of play (200 hands/hour, 12 hours/day, 70 years) cannot statistically distinguish Cepheus's strategy from a true Nash equilibrium at 95% confidence. The strategy is exploitable by less than one milli-big-blind per hand.

This was the **first non-trivial imperfect-information game played competitively by humans to be solved**. Note the careful hedging: it is *essentially* solved, *weakly*, and only the *heads-up limit* variant.

### 4.2 Why Heads-Up *No-Limit* Hold'em Is Not Solved

Removing the betting cap explodes the game tree. Two independent measurements:

- Johanson's 2013 technical report estimated **~6.31 × 10¹⁶¹ information sets** for HUNL with full bet granularity.
- The Libratus paper (Brown & Sandholm, *Science* 2018) describes the HUNL search space as exceeding **10¹⁶⁰ decision points** — comparable in scale to Go.

That is forty orders of magnitude larger than the heads-up limit version Cepheus solved, and roughly **10⁴⁰ times more states than chess's Shannon number**. CFR+ does not scale to it. **Libratus** (2017) and its descendants beat top professionals at HUNL not by solving the game, but by computing a Nash equilibrium of a *much smaller abstracted* game and resolving subgames in real time. Brown and Sandholm explicitly describe the result as an **approximation** — there is no proof that Libratus's strategy is a Nash equilibrium of the unabstracted game, and there are demonstrably exploitative counter-strategies.

### 4.3 Why Multiplayer Poker May Not Be Solvable Even In Principle

When we move from heads-up to three-or-more-player poker — i.e., real poker as it is actually played — two foundational problems appear:

**(a) Nash equilibrium ceases to be a winning strategy.** In two-player zero-sum games, playing a Nash equilibrium *guarantees* you cannot lose in expectation. With three or more players, this guarantee disappears: a player using an equilibrium strategy can be *exploited* by collusion or by opponents who themselves deviate. Brown and Sandholm acknowledged this directly when introducing **Pluribus** (*Science*, 2019), the six-player no-limit AI: Pluribus *abandons* theoretical equilibrium guarantees because in multiplayer settings "playing a Nash equilibrium can be a losing strategy."

**(b) Computing equilibria is computationally intractable.** Daskalakis, Goldberg, and Papadimitriou's celebrated result *The Complexity of Computing a Nash Equilibrium* established that finding a Nash equilibrium in general games is **PPAD-complete** — believed to admit no polynomial-time algorithm. For multi-player games (m ≥ 3), deciding whether refinements such as Pareto-optimal or strong Nash equilibria exist is **∃ℝ-complete** (Bilò & Mavronicolas, 2019), an even harder class.

Combine (a) and (b) and you arrive at an uncomfortable conclusion: for multiplayer no-limit hold'em, we do not even have a *target* to aim at. There is no single-strategy object whose existence we can prove, whose computation is tractable, and whose play guarantees a non-losing outcome. "Solving poker" is not merely an engineering problem awaiting bigger computers — it is, in the strongest variants, *not even well-defined* in the way checkers or chess are.

### 4.4 The Brute-Force Wall, Quantified

A back-of-envelope demonstration of intractability for HUNL:

- Information sets: ~10¹⁶¹.
- Suppose we had a machine performing 10¹⁸ operations per second (roughly current exascale).
- Time to visit each information set once: 10¹⁶¹ / 10¹⁸ = **10¹⁴³ seconds** ≈ 10¹³⁵ years.

The universe is ~10¹⁰ years old. We would need to repeat the entire history of the universe approximately 10¹²⁵ times to enumerate the game tree once — and that is just to *visit* each node, not to perform CFR-style iterative refinement, which requires many passes.

## 5. Summary Table

| Game | Status | Result | Year | Method |
|---|---|---|---|---|
| Tic-tac-toe | Strongly solved | Draw | Antiquity | Exhaustive enumeration |
| Connect Four | Weakly solved | First player wins | 1988 (Allen, Allis) | Knowledge-based + α-β |
| Checkers | Weakly solved | Draw | 2007 (Schaeffer) | Endgame DB + proof tree |
| Chess | Unsolved | Unknown (likely draw) | — | Shannon # 10¹²⁰ blocks brute force |
| HU Limit Hold'em | Essentially weakly solved | Small SB advantage | 2015 (Bowling) | CFR+ on ~3 × 10¹⁴ infosets |
| HU No-Limit Hold'em | Unsolved | Unknown | — | ~10¹⁶¹ infosets; only abstractions |
| 3+ Player No-Limit Hold'em | Unsolved & arguably ill-defined | Nash not winning, PPAD-hard | — | Pluribus drops equilibrium guarantee |

## 6. Conclusion

Tic-tac-toe was solved by enumeration. Connect Four and checkers were solved by combining domain knowledge with massive but finite computation. Chess sits beyond brute-force reach but remains theoretically determinate. Poker is qualitatively different.

- **Heads-up limit hold'em** is solved, but only "essentially," only "weakly," and only because it is by far the smallest poker variant of practical interest.
- **Heads-up no-limit hold'em** has a state space (10¹⁶¹) so vast that solving it by any known technique is physically impossible in our universe.
- **Multiplayer no-limit hold'em** is not just computationally hopeless — its game-theoretic foundation collapses, because Nash equilibria in n ≥ 3 player non-zero-sum games are neither guaranteed to be winning nor tractable to compute (PPAD-complete; refinements ∃ℝ-complete).

Poker, as it is actually played in casinos and online — six- or nine-handed no-limit hold'em — is therefore not just *unsolved*. It is, in any rigorous game-theoretic sense, **unsolvable**: too large to brute-force, too multiplayer for Nash equilibrium to mean what we want it to mean, and too computationally hard for the equilibria that do exist to be found.

This is not a temporary state of affairs awaiting better hardware. It is a structural property of the game.

---

## Sources

- [Solved game — Wikipedia](https://en.wikipedia.org/wiki/Solved_game)
- [Allis, V. (1988). *A Knowledge-Based Approach of Connect-Four* (PDF)](https://tromp.github.io/c4/connect4_thesis.pdf)
- [Schaeffer et al. (2007). *Checkers Is Solved*, Science](https://www.science.org/doi/10.1126/science.1144079)
- [Schaeffer et al. — Checkers Is Solved (PDF, Cornell mirror)](https://www.cs.cornell.edu/courses/cs6700/2013sp/readings/06-b-Checkers-Solved-Science-2007.pdf)
- [Shannon number — Wikipedia](https://en.wikipedia.org/wiki/Shannon_number)
- [Bowling, Burch, Johanson, Tammelin (2015). *Heads-up Limit Hold'em Poker is Solved*, Science](https://www.science.org/doi/abs/10.1126/science.1259433)
- [*Heads-Up Limit Hold'em Poker Is Solved* — Communications of the ACM (full text)](https://cacm.acm.org/research/heads-up-limit-holdem-poker-is-solved/)
- [Cepheus poker bot — Wikipedia](https://en.wikipedia.org/wiki/Cepheus_(poker_bot))
- [Johanson (2013). *Measuring the Size of Large No-Limit Poker Games* (arXiv 1302.7008)](https://arxiv.org/pdf/1302.7008)
- [Brown & Sandholm (2018). *Superhuman AI for heads-up no-limit poker: Libratus beats top professionals*, Science](https://www.science.org/doi/10.1126/science.aao1733)
- [Brown & Sandholm (2019). *Superhuman AI for multiplayer poker* (Pluribus), Science](https://www.science.org/doi/10.1126/science.aay2400)
- [Daskalakis, Goldberg, Papadimitriou — *The Complexity of Computing a Nash Equilibrium* (PDF)](https://people.csail.mit.edu/costis/simplified.pdf)
- [Bilò & Mavronicolas (2019). *On the Computational Complexity of Decision Problems about Multi-Player Nash Equilibria* (arXiv 2001.05196)](https://arxiv.org/abs/2001.05196)
