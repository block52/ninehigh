# Texas Hold'em — Core Rules Reference

> **Purpose:** Canonical rules reference for the Block52 poker engine.  
> **Audience:** AI coding assistants and developers implementing game logic.  
> **Last Updated:** February 2026

---

## 1. Authoritative Sources

| Source | Type | URL |
|--------|------|-----|
| Robert's Rules of Poker (v11) — Robert Ciaffone | Live cardroom standard | https://www.readybetgo.com/poker/rules/rules-of-holdem-poker-219.html |
| Poker TDA Rules 2024 (v1.0) | Tournament standard (3,000+ members, 64 countries) | https://www.pokertda.com/view-poker-tda-rules/ |
| PokerStars Rules | Online standard | https://www.pokerstarsmi.com/poker/games/rules/ |
| California Bureau of Gambling Control | Regulatory | https://oag.ca.gov/sites/all/files/agweb/pdfs/gambling/BGC_texas.pdf |
| Wikipedia — Texas Hold'em | General reference | https://en.wikipedia.org/wiki/Texas_hold_%27em |
| Wikipedia — Betting in Poker | Side pots & all-in | https://en.wikipedia.org/wiki/Betting_in_poker |
| University of Toronto (previously referenced) | Academic | — |

---

## 2. Game Overview

Texas Hold'em is played with a standard 52-card deck and no jokers. Each player receives two private hole cards dealt face-down. Five community cards are dealt face-up in three stages (flop, turn, river). Players make the best five-card hand from any combination of the seven available cards (their two hole cards plus five community cards). A player may use zero, one, or two of their hole cards.

**Source:** Robert's Rules of Poker — "In hold'em, players receive two downcards as their personal hand (holecards), after which there is a round of betting. Three boardcards are turned simultaneously (called the 'flop') and another round of betting occurs. The next two boardcards are turned one at a time, with a round of betting after each card."

---

## 3. Table Setup

### 3.1 Number of Players
- **Minimum:** 2 players (heads-up)
- **Maximum:** Typically 9–10 players per table
- **Standard online:** 6-max or 9-max tables

### 3.2 The Dealer Button
A marker ("button") indicates the nominal dealer position. After each hand, the button moves one position clockwise.

**Source (TDA Rule 34-B):** "Heads-up, the small blind is the button, is dealt the last card, and acts first pre-flop and last on all other betting rounds."

### 3.3 Dead Button Rule
**Source (TDA Rule 32):** "Tournament play will use a dead button."  
The button can sit in front of an empty seat. This ensures no player is forced to post the big blind twice consecutively.

---

## 4. Blinds

### 4.1 Structure
- **Small Blind (SB):** Posted by the player immediately left of the button. Usually half the big blind.
- **Big Blind (BB):** Posted by the player two seats left of the button. Defines the minimum bet for the hand.

Blinds are **forced bets** placed before any cards are dealt. They create initial action and prevent indefinite folding.

### 4.2 Heads-Up Exception
When only two players remain:
- The **button posts the small blind** and is dealt the last card.
- The button **acts first pre-flop** and **last on all post-flop rounds**.

**Source (Wikipedia):** "When only two players remain, special 'head-to-head' or 'heads up' rules are enforced and the blinds are posted differently. In this case, the person with the dealer button posts the small blind, while their opponent places the big blind. The dealer acts first before the flop. After the flop, the dealer acts last."

### 4.3 Live Blinds
The big blind is considered a "live" bet pre-flop. If no one raises, the big blind player has the **option** to check or raise (this is the "big blind option" or "walk" if all fold).

---

## 5. Dealing

### 5.1 Deal Order
1. Cards are dealt one at a time, starting with the player in the small blind position.
2. Each player receives their first card, then each receives their second card.
3. The player on the button receives the last card in each dealing round.

### 5.2 Burn Cards
Before dealing community cards, the dealer burns (discards) the top card of the deck face-down. This applies before the flop, turn, and river.

**Source (Robert's Rules):** Burn card procedures are detailed for error correction — if a dealer fails to burn a card, the error should be corrected if discovered before betting action begins for that round.

---

## 6. Betting Rounds

### 6.1 The Four Rounds

| Round | Community Cards | Cards on Board | First to Act |
|-------|----------------|----------------|--------------|
| **Pre-Flop** | None dealt yet | 0 | Player left of BB (UTG) |
| **Flop** | 3 cards dealt | 3 | First active player left of button |
| **Turn** | 1 card dealt | 4 | First active player left of button |
| **River** | 1 card dealt | 5 | First active player left of button |

**Pre-flop exception:** Action begins with the player to the left of the big blind (Under the Gun). The big blind acts last pre-flop.

**Post-flop:** Action begins with the first active player clockwise from the button.

### 6.2 Available Actions

| Action | Condition | Description |
|--------|-----------|-------------|
| **Check** | No bet facing you | Pass action; decline to bet |
| **Bet** | No bet has been made this round | Place the first wager |
| **Call** | Facing a bet | Match the current bet |
| **Raise** | Facing a bet | Increase the current bet |
| **Fold** | Any time facing action | Surrender your hand |
| **All-In** | Any time (NL) | Bet your entire remaining stack |

**Source (PokerStars):** "If nobody has yet made a bet, then a player may either check (decline to bet, but keep their cards) or bet. If a player has bet, then subsequent players can fold, call or raise."

### 6.3 Betting Round Completion
A betting round ends when every active player has either:
1. Matched the largest bet (or gone all-in for less), OR
2. Folded

The big blind has the option to raise even if all other players just call pre-flop.

---

## 7. No-Limit Betting Rules

### 7.1 Minimum Bet
The minimum bet is always equal to the big blind.

### 7.2 Minimum Raise
The minimum raise must be **at least the size of the previous bet or raise** in the same round.

**Algorithm:**
```
minimum_raise_increment = max(big_blind, last_raise_size)
minimum_total_raise = current_bet + minimum_raise_increment
```

**Source (Wikipedia):** "The minimum raise is equal to the size of the previous bet or raise. If someone wishes to re-raise, they must raise at least the amount of the previous raise. For example, if the big blind is $2 and there is a raise of $6 to a total of $8, a re-raise must be at least $6 more for a total of $14."

### 7.3 Maximum Bet
In No-Limit: A player may bet up to their entire stack (all-in) at any time.

### 7.4 Raise Examples

| Scenario | Big Blind | Previous Action | Min Raise To | Explanation |
|----------|-----------|-----------------|--------------|-------------|
| First raise pre-flop | $10 | BB=$10 | $20 | Raise increment = BB ($10) |
| Re-raise | $10 | Raise to $30 (increment of $20) | $50 | Increment = $20 (previous raise size) |
| 3-bet | $10 | Re-raise to $80 (increment of $50) | $130 | Increment = $50 |

### 7.5 All-In for Less Than Minimum Raise
A player who goes all-in for less than a full raise does **not** reopen betting to players who have already acted. The short all-in is treated as a call with extra chips.

**Source (Wikipedia — Betting in Poker):** "If a raise or re-raise is all-in and does not equal the size of the previous raise (or half the size in some casinos), the initial raiser cannot re-raise again."

---

## 8. Showdown

### 8.1 When Showdown Occurs
Showdown happens after the final betting round (river) is complete, if two or more players remain.

### 8.2 Cards Speak
**Source (TDA Rule 12):** "Cards speak to determine the winner. Verbal declarations of hand value are not binding at showdown but deliberately miscalling a hand may be penalized."

### 8.3 Showdown Order
**Source (TDA Rule 17-A):** "The last aggressive player on the final betting round must table first. If there was no final round bet, the player who would act first in a final betting round must table first (i.e. first seat left of the button in flop games)."

### 8.4 All-In Showdown
**Source (TDA Rule 16):** "All hands will be tabled without delay once a player is all-in and all betting action by all other players in the hand is complete."

### 8.5 Playing the Board
A player may use all five community cards as their hand. They must still show their hole cards to claim the pot.

**Source (Robert's Rules, Rule 9):** "You must declare that you are playing the board before you throw your cards away; otherwise you relinquish all claim to the pot."

---

## 9. Winning the Hand

A player wins the pot by either:
1. **Having the best hand at showdown** — evaluated using standard poker hand rankings.
2. **Being the last player remaining** — all other players have folded.

If two or more players have identical hands, the pot is split equally.

**Source (TDA Rule 20):** Odd chips from splits go to the first seat left of the button in board games.

---

## 10. Hand Rankings (Highest to Lowest)

| Rank | Hand | Example |
|------|------|---------|
| 1 | Royal Flush | A♠ K♠ Q♠ J♠ 10♠ |
| 2 | Straight Flush | 9♥ 8♥ 7♥ 6♥ 5♥ |
| 3 | Four of a Kind | Q♣ Q♦ Q♥ Q♠ 7♠ |
| 4 | Full House | K♣ K♦ K♥ 3♣ 3♦ |
| 5 | Flush | A♦ J♦ 8♦ 5♦ 2♦ |
| 6 | Straight | 10♣ 9♦ 8♠ 7♥ 6♣ |
| 7 | Three of a Kind | 8♣ 8♦ 8♥ K♠ 4♦ |
| 8 | Two Pair | A♣ A♦ 9♣ 9♦ 5♠ |
| 9 | One Pair | J♣ J♦ A♠ 8♣ 3♦ |
| 10 | High Card | A♠ K♦ 9♣ 7♠ 3♥ |

**Key rules:**
- All suits are equal in rank.
- The ace can play high (A-K-Q-J-10) or low (A-2-3-4-5) in straights. The lowest straight is A-2-3-4-5 ("wheel").
- Kickers break ties for hands of the same rank.
- Best five cards from seven are used — remaining cards are irrelevant.

**Source (California BGC):** "The order of highest to lowest rank shall be: ace, king, queen, jack, 10, 9, 8, 7, 6, 5, 4, 3, and 2. All suits shall be considered equal in rank."

---

## 11. Key Implementation Notes

### 11.1 Round Transition Logic
```
ANTE → (post blinds, deal) → PREFLOP → (flop cards) → FLOP → 
(turn card) → TURN → (river card) → RIVER → SHOWDOWN → END
```

### 11.2 Action Validation Checklist
Before allowing any action:
- [ ] Is it the player's turn?
- [ ] Is the player still active (not folded, not sitting out)?
- [ ] Is the action legal for the current game state?
- [ ] Does the player have sufficient chips?
- [ ] Is the bet/raise amount within legal bounds?

### 11.3 Round-End Detection
A round ends when:
1. All active players have acted at least once AND
2. All active players have matched the highest bet (or are all-in) AND
3. No player's last action was a bet/raise that hasn't been responded to by all others

### 11.4 Edge Cases
- **Single player remaining:** Award pot immediately, skip to next hand.
- **All players all-in:** Deal remaining community cards, go straight to showdown.
- **Big blind walk:** If all players fold to the big blind, BB wins the pot. No showdown needed.
- **Split pot with odd chip:** Award to first player left of the button.
