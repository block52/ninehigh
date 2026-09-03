# Texas Hold'em — All-In, Side Pots & Table Stakes

> **Purpose:** Detailed rules for all-in scenarios, side pot calculation, and table stakes enforcement.  
> **Audience:** AI coding assistants implementing pot distribution logic.  
> **Last Updated:** February 2026

---

## Sources

| Source | URL |
|--------|-----|
| Wikipedia — Betting in Poker | https://en.wikipedia.org/wiki/Betting_in_poker |
| PokerStars Rules | https://www.pokerstarsmi.com/poker/games/rules/ |
| PokerListings — Side Pot Calculator | https://www.pokerlistings.com/poker-tools/poker-side-pot-calculator |
| Poker TDA Rules 2024 | https://www.pokertda.com/view-poker-tda-rules/ |
| Upswing Poker — Betting Rules | https://upswingpoker.com/betting-rules/ |
| Robert's Rules of Poker (v11) | https://www.readybetgo.com/poker/rules/general-poker-rules-217.html |

---

## 1. Table Stakes

### 1.1 Definition
Table stakes means a player can only wager chips that are physically in front of them at the start of a hand. No player may add chips or remove chips during a hand.

**Source (PokerStars):** "You may have seen a poker scene in a movie or on TV where a player is faced with a bet for more chips than they have at the table, and is forced to wager a watch, a car or some other possession in order to stay in the hand." — This is fiction. Table stakes prohibit it.

### 1.2 Rules
- Players can only bet what's on the table when the hand starts.
- Money cannot be added mid-hand ("no ratholing" the other direction — can't remove either).
- Between hands, players may add chips (buy more) or leave the table.

**Source (Robert's Rules, Buy-In Rule 2):** "Adding to your stack is not considered a buy-in, and may be done in any quantity between hands."

---

## 2. All-In Rules

### 2.1 Basic All-In
A player who does not have enough chips to call a bet is declared all-in. They commit their entire remaining stack.

**Source (PokerStars):** "A player who does not have enough chips to call a bet is declared All-In. The player is eligible for the portion of the pot up to the point of his final wager."

### 2.2 Two-Player All-In
When only two players are in the hand:
1. The short-stack player goes all-in.
2. The larger-stack player matches only the short stack's amount.
3. Any excess is returned to the larger-stack player immediately.
4. The hand is dealt to completion.
5. Winner takes the pot.

**Example:**
```
Player A has $200, bets $200 (all-in)
Player B has $500, calls
→ Player B puts in $200, gets $300 back immediately
→ Pot = $400
→ Best hand wins $400
```

### 2.3 All-In for Less Than a Full Raise
A critical rule for the engine:

**Source (Wikipedia):** "If a raise or re-raise is all-in and does not equal the size of the previous raise, the initial raiser cannot re-raise again (in case there are other players also still in the game)."

**Engine implementation:**
```
if (allInAmount < currentBet + lastRaiseSize) {
    // This is a CALL with extra chips, NOT a raise
    // It does NOT reopen betting for players who already acted
    reopenBetting = false;
}
```

### 2.4 All-In and Showing Cards
**Source (TDA Rule 16):** "All hands will be tabled without delay once a player is all-in and all betting action by all other players in the hand is complete. No player who is either all-in or has called all betting action may muck their hand without tabling."

---

## 3. Side Pots

### 3.1 When Side Pots Form
Side pots are created when three or more players are involved and at least one player is all-in for less than the full bet.

**Source (PokerStars):** "All further action involving other players takes place in a 'side pot', which the All-In player is not eligible to win. If more than one player goes All-In during a hand, there could be more than one side pot."

### 3.2 Fundamental Principle
**A player can only win from each opponent an amount equal to what they themselves have invested.**

### 3.3 Side Pot Calculation Algorithm

```
function calculateSidePots(players: AllInPlayer[]): Pot[] {
    // Sort players by their total contribution (ascending)
    const sorted = players.sort((a, b) => a.totalBet - b.totalBet);
    const pots: Pot[] = [];
    let previousLevel = 0;
    
    for (let i = 0; i < sorted.length; i++) {
        const currentLevel = sorted[i].totalBet;
        const increment = currentLevel - previousLevel;
        
        if (increment > 0) {
            // Number of players eligible for this pot
            const eligibleCount = sorted.length - i;
            const potAmount = increment * eligibleCount;
            
            pots.push({
                amount: potAmount,
                eligiblePlayers: sorted.slice(i).map(p => p.id),
            });
        }
        
        previousLevel = currentLevel;
    }
    
    return pots;
}
```

### 3.4 Worked Example — Three Players

```
Player A: $50 total bet (all-in)
Player B: $120 total bet (all-in)  
Player C: $200 total bet (called)

Step 1: Main Pot
  → $50 from each player × 3 = $150
  → Eligible: A, B, C

Step 2: Side Pot 1
  → ($120 - $50) = $70 from each remaining player × 2 = $140
  → Eligible: B, C

Step 3: Side Pot 2
  → ($200 - $120) = $80 from C only = $80
  → This $80 is returned to C (no one to contest it)

Pot Distribution:
  Main Pot: $150 → Best hand among A, B, C
  Side Pot 1: $140 → Best hand among B, C
  Returned: $80 → Back to C
```

### 3.5 Worked Example — Five Players

```
Player A: $100 (all-in)
Player B: $75 (all-in)
Player C: $50 (all-in)
Player D: $25 (all-in)
Player E: $125

Sort by contribution: D($25), C($50), B($75), A($100), E($125)

Main Pot: $25 × 5 = $125 → Eligible: D, C, B, A, E

Side Pot 1: ($50-$25) × 4 = $100 → Eligible: C, B, A, E

Side Pot 2: ($75-$50) × 3 = $75 → Eligible: B, A, E

Side Pot 3: ($100-$75) × 2 = $50 → Eligible: A, E

Excess: ($125-$100) × 1 = $25 → Returned to E
```

### 3.6 Side Pot Award Order
Side pots are awarded from the **smallest/most-recent** to the **main pot**:
1. Each side pot is evaluated independently.
2. Only eligible players compete for each pot.
3. A player who wins a smaller side pot but loses the main pot keeps the side pot winnings.

**Source (TDA Rule 21):** "Each side pot will be split separately."

---

## 4. Pot Split Rules

### 4.1 Equal Hands
When two or more players have identical best five-card hands, the pot is divided equally.

### 4.2 Odd Chips
**Source (TDA Rule 20):** "First, odd chips will be broken into the smallest denomination in play. Board games with 2 or more high hands: the odd chip goes to the first seat left of the button."

### 4.3 Implementation
```
function awardPot(pot: bigint, winners: Player[]): Map<string, bigint> {
    const share = pot / BigInt(winners.length);
    const remainder = pot % BigInt(winners.length);
    const awards = new Map<string, bigint>();
    
    for (const winner of winners) {
        awards.set(winner.address, share);
    }
    
    // Odd chip goes to first winner left of button
    if (remainder > 0n) {
        const oddChipWinner = findFirstLeftOfButton(winners);
        const current = awards.get(oddChipWinner.address)!;
        awards.set(oddChipWinner.address, current + remainder);
    }
    
    return awards;
}
```

---

## 5. Special All-In Scenarios

### 5.1 All Players All-In
When all remaining players are all-in:
- No further betting occurs.
- All remaining community cards are dealt.
- All hands are tabled (face up).
- Pots are awarded per side pot rules.

### 5.2 All-In with Blind Posting
**Source (Wikipedia):** "If a player is all in for part of the ante, or the exact amount of the ante, an equal amount of every other player's ante is placed in the main pot, with any remaining fraction of the ante and all blinds and further bets in the side pot."

### 5.3 Short Stack All-In During Blinds
If a player in the blind doesn't have enough to post the full blind:
- They post whatever they have (all-in).
- Other players must still call the **full** big blind amount.
- A side pot is created for the difference.

### 5.4 Checking Down When a Player Is All-In
In cash games and tournaments, remaining active players may continue to bet against each other in side pots while the all-in player can only win the main pot. There is no rule requiring players to check it down (though it's common etiquette at tournament final tables).

---

## 6. Buy-In Rules (Cash Games)

### 6.1 Minimum / Maximum
**Source (Robert's Rules):** "When you enter a game, you must make a full buy-in. At limit poker, a full buy-in is at least ten times the maximum bet for the game being played."

For No-Limit cash games, minimum and maximum buy-ins are set by the house (typically 20–100 big blinds).

### 6.2 Re-buys
Players may add chips between hands up to the table maximum (in capped games).

### 6.3 Leaving the Table
In cash games, players may leave at any time and take their chips. Tournament play has no equivalent — chips stay in play until elimination.
