# Texas Hold'em — Edge Cases, Irregularities & Online Rules

> **Purpose:** Reference for uncommon situations, error handling, and online-specific implementations.  
> **Audience:** AI coding assistants implementing robust poker game logic.  
> **Last Updated:** February 2026

---

## Sources

| Source | URL |
|--------|-----|
| Robert's Rules of Poker (v11) — Ciaffone | https://www.readybetgo.com/poker/rules/general-poker-rules-217.html |
| Robert's Rules — Hold'em Irregularities | https://www.readybetgo.com/poker/rules/rules-of-holdem-poker-219.html |
| Poker TDA Rules 2024 | https://www.pokertda.com/view-poker-tda-rules/ |
| PokerStars Rules | https://www.pokerstarsmi.com/poker/games/rules/ |
| Upswing Poker — Texas Hold'em Rules | https://upswingpoker.com/poker-rules/texas-holdem-rules/ |
| PokerListings — Betting Rules | https://www.pokerlistings.com/poker-guides/texas-holdem-betting-rules |

---

## 1. Misdeals

### 1.1 What Constitutes a Misdeal
**Source (Robert's Rules):** A misdeal is declared if (before two players have acted):
- The first or second hole card is exposed due to dealer error.
- Two or more cards are exposed.
- Two or more boxed (face-up) cards are found in the deck.
- Incorrect number of cards dealt to a player.
- Card dealt out of sequence.
- Cards dealt to wrong position or empty seat.
- A player entitled to a hand was dealt out.

### 1.2 Once Action Begins
**Source (Robert's Rules):** "Once action begins, a misdeal cannot be called. The deal will be played, and no money will be returned to any player whose hand is fouled."

### 1.3 Online Implementation
In online/blockchain poker, misdeals are largely eliminated because:
- Dealing is automated and deterministic.
- Cards cannot be physically exposed.
- Sequence errors are impossible with correct code.

**Engine recommendation:** Validate deck integrity and deal sequence in code. If the shuffle is ZK-verified, misdeal scenarios reduce to software bugs only.

---

## 2. Dead Hands

### 2.1 A Hand Is Dead When
**Source (Robert's Rules):**
- Player folds or announces they are folding when facing a bet.
- Player throws hand away in forward motion causing another player to act.
- Hand does not contain the proper number of cards.
- Player has the clock on them and exceeds the time limit while facing a bet.

### 2.2 Timeout/Disconnection (Online-Specific)
Online poker platforms implement timeout rules since players can disconnect or go idle:
- **Standard timeout:** 15–60 seconds per action (configurable).
- **If facing a bet and timeout expires:** Hand is folded.
- **If not facing a bet and timeout expires:** Hand is checked.

**Source (TDA Rule 29):** "A player on the clock has up to 25 seconds plus a 5 second countdown to act. If the player faces a bet and time expires, the hand is dead; if not facing a bet, the hand is checked."

**Engine implementation:**
```
if (timeExpired && facingBet) {
    autoFold(player);
} else if (timeExpired && !facingBet) {
    autoCheck(player);
}
```

---

## 3. Betting Irregularities

### 3.1 String Bets
A string bet (putting chips in incrementally while watching for reactions) is not allowed. 

**Source (TDA Rule 3):** "Official betting terms are simple, unmistakable, time-honored declarations like bet, raise, call, fold, check, all-in."

**Online implementation:** Not applicable — bets are submitted as single atomic actions.

### 3.2 Verbal Declarations
In live poker, verbal declarations are binding. "Raise" commits you to raising.

**Online implementation:** Actions are button clicks or API calls — the action itself is the declaration.

### 3.3 Bet Sizing Errors
**Source (TDA Rule 42 area):** If a player puts in less than the required amount (and has more chips), the bet must be corrected. If the bet is more than intended but already placed, it stands.

**Engine implementation:** Validate all bet amounts before recording:
```
if (amount < minimumRequired && player.chips >= minimumRequired) {
    throw new Error("Bet too small. Minimum is " + minimumRequired);
}
if (amount > player.chips) {
    throw new Error("Insufficient chips");
}
```

### 3.4 Acting Out of Turn
In live poker, acting out of turn may be binding or non-binding depending on house rules.

**Online implementation:** The engine should enforce strict turn order. Only the current-to-act player can submit an action.

---

## 4. Showdown Edge Cases

### 4.1 Last Aggressor Shows First
**Source (TDA Rule 17-A):** "The last aggressive player on the final betting round must table first."

### 4.2 Everyone Checks the River
If no bet is made on the river, the first player to the left of the button shows first.

### 4.3 Mucking at Showdown
**Source (TDA Rule 17-B):** "A non all-in showdown is uncontested if all but one player mucks face down without tabling. The last player with live cards wins and is not required to table the cards."

**Online implementation:** After the river, if only one player remains (others folded), they win without showing. If two or more remain, hands are compared automatically.

### 4.4 Cards Speak
The software determines the winner — not the player's declaration of their hand.

**Source (TDA Rule 12):** "Cards speak to determine the winner. Verbal declarations of hand value are not binding at showdown."

---

## 5. Special Situations

### 5.1 Running It Twice (or More)
Some cash games allow players to "run it twice" — dealing the remaining community cards twice when all players are all-in, splitting the pot between the two boards.

**Implementation:** This is optional and configurable. Each "run" creates a separate board and the pot is divided equally among the runs before determining winners.

### 5.2 Straddle
A straddle is a voluntary blind bet (usually double the BB) made by the player to the left of the big blind before cards are dealt. It gives the straddler last action pre-flop.

**Implementation:** Optional feature. If enabled:
- Straddle amount = 2 × BB (or house rules)
- Pre-flop action starts left of the straddle
- Straddler gets last option pre-flop

### 5.3 Missed Blinds
When a player returns to a game after missing their blinds:
- **Common rule:** They must post both the small blind (dead — goes to pot) and the big blind (live — counts as their bet) before being dealt in.
- **Online:** Usually handled by sitting the player out until the big blind comes around.

### 5.4 Rabbit Hunting
**Source (TDA Rule 28):** "Rabbit hunting (revealing cards that would have come if the hand had not ended) is not allowed."

**Online implementation:** Some platforms offer this as an optional feature after a hand ends. Not relevant to game logic.

---

## 6. Online-Specific Rules

### 6.1 Disconnection Protection
Most online platforms have disconnection protection:
- If a player disconnects mid-hand while facing a bet, they are treated as all-in for their current contribution.
- Remaining players create a side pot.
- If the disconnected player reconnects, they can only win the main pot.

**Engine recommendation for blockchain:** Since Block52 operates on-chain verification, implement a timeout mechanism rather than disconnection detection. After N seconds/blocks without action, auto-fold or auto-check.

### 6.2 Sit-Out
Players can sit out (temporarily not be dealt cards) without leaving the table:
- Sitting out players are skipped during dealing.
- In cash games, their seat is held for a configurable period.
- Blinds may or may not be posted while sitting out (configurable).

### 6.3 Auto-Actions
Common pre-selected actions in online poker:
- **Auto-fold:** Fold when it's your turn
- **Auto-check/fold:** Check if possible, fold if facing a bet
- **Auto-call any:** Call any bet

**Engine implementation:** These can be client-side features that submit the action when the turn arrives.

### 6.4 Hand History
Online platforms maintain complete hand histories. For blockchain poker, this maps naturally to the on-chain action log / previous actions array.

---

## 7. Tournament vs Cash Game Differences

| Feature | Cash Game | Tournament |
|---------|-----------|------------|
| **Blinds** | Fixed | Increase on schedule |
| **Buy-in** | Min/max range, can re-buy | Fixed, start equal |
| **Chips** | Represent real money 1:1 | No cash value until payout |
| **Leaving** | Any time | Eliminated when out of chips |
| **Table balancing** | N/A | Players moved to balance |
| **Dead button** | Optional | Required (TDA Rule 32) |
| **Antes** | Rare in cash | Common at higher levels |

---

## 8. Common Mistakes in Engine Implementation

### 8.1 Incorrect Minimum Raise Tracking
**Wrong:** Using the big blind as min raise in all cases.  
**Right:** Tracking the last raise increment per round. The min raise equals the last raise size, which may be larger than the BB after re-raises.

### 8.2 Not Resetting Bets Per Round
Each betting round starts fresh. A player who bet $100 in the flop round starts at $0 for the turn round. Track bets per-round, not cumulative (though cumulative tracking is needed for side pot calculation).

### 8.3 Big Blind Option Ignored
After all players call pre-flop, the big blind must still get the option to raise. The round is NOT over just because everyone matched the BB.

### 8.4 Heads-Up Blind Posting
In heads-up play, the button posts the small blind and acts first pre-flop. Many implementations get this wrong, especially when transitioning from multi-way to heads-up.

### 8.5 Side Pot Eligibility
A player who is all-in for the main pot cannot win any side pot, even if they have the best hand. Each pot is evaluated independently.

### 8.6 Folding Without a Bet
When no bet is facing a player (they can check), folding is technically allowed but nonsensical. Some engines block this; others allow it. Blocking it prevents accidental folds.

---

## 9. State Machine Summary

```
┌─────────┐     post blinds     ┌──────────┐     deal cards     ┌──────────┐
│  ANTE   │────────────────────→│  PREFLOP │←────────────────────│  DEAL    │
└─────────┘                     └──────────┘                     └──────────┘
                                     │
                              betting complete
                                     ↓
                                ┌──────────┐
                                │   FLOP   │  ← deal 3 community cards
                                └──────────┘
                                     │
                              betting complete
                                     ↓
                                ┌──────────┐
                                │   TURN   │  ← deal 1 community card
                                └──────────┘
                                     │
                              betting complete
                                     ↓
                                ┌──────────┐
                                │  RIVER   │  ← deal 1 community card
                                └──────────┘
                                     │
                              betting complete
                                     ↓
                                ┌──────────┐
                                │ SHOWDOWN │  ← evaluate hands, award pots
                                └──────────┘
                                     │
                                     ↓
                                ┌──────────┐
                                │   END    │  ← reset for next hand
                                └──────────┘

Early exit: If all but one player folds at ANY point → award pot → END
```

---

## 10. Quick Reference: Action Legality Matrix

| Game State | Check | Bet | Call | Raise | Fold | All-In |
|------------|-------|-----|------|-------|------|--------|
| Pre-flop, no raise yet (not BB) | ✗ | ✗ | ✓ (call BB) | ✓ | ✓ | ✓ |
| Pre-flop, BB option (no raise) | ✓ | ✗ | ✗ | ✓ | ✓* | ✓ |
| Post-flop, no bet | ✓ | ✓ | ✗ | ✗ | ✓* | ✓ |
| Post-flop, facing bet | ✗ | ✗ | ✓ | ✓ | ✓ | ✓ |
| Post-flop, facing raise | ✗ | ✗ | ✓ | ✓ | ✓ | ✓ |
| Showdown | Show | — | — | — | Muck | — |

*Folding when you can check is technically legal but irrational.
