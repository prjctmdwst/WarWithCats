# ⚔ War Roguelike — Godot 4.x Starter Project

A roguelike card game built on the rules of War, with special card abilities,
persistent run upgrades, and escalating boss encounters.

---

## Quick Setup (5 minutes)

1. **Open Godot 4.x** and choose "Import" → select the `project.godot` file.

2. **Register the Autoload**
   - Go to `Project → Project Settings → Autoload`
   - Click the folder icon, select `res://scripts/GameState.gd`
   - Set the Node Name to `GameState`
   - Click **Add**

3. **Set the Main Scene**
   - Go to `Project → Project Settings → Application → Run`
   - Set `Main Scene` to `res://scenes/Main.tscn`

4. **Hit F5** — the game runs!

---

## Project Structure

```
war_roguelike/
├── project.godot
├── scripts/
│   ├── Card.gd           # Card data: values, suits, abilities
│   ├── Deck.gd           # Deck management: draw, shuffle, build
│   ├── GameState.gd      # AUTOLOAD — run state, upgrades, HP
│   ├── BattleManager.gd  # Core War game logic + ability resolution
│   ├── BattleScene.gd    # Battle UI controller
│   ├── CardVisual.gd     # Card display component
│   ├── UpgradeScreen.gd  # Post-battle upgrade picker
│   ├── UpgradeCard.gd    # Individual upgrade card UI
│   ├── MainMenu.gd       # Title screen
│   ├── GameOver.gd       # Death screen
│   └── Victory.gd        # Win screen
└── scenes/
    ├── Main.tscn          # Main menu
    ├── Battle.tscn        # Core gameplay
    ├── CardVisual.tscn    # Reusable card component
    ├── UpgradeScreen.tscn # Post-battle upgrade
    ├── UpgradeCard.tscn   # Upgrade option card
    ├── GameOver.tscn      # Death screen
    └── Victory.tscn       # Win screen
```

---

## How to Play

- **Goal**: Survive 10 floors by winning card battles against enemies.
- **Each Round**: Both players flip the top card of their deck. Higher value wins both cards.
- **WAR**: On a tie, 3 face-down cards are staked, then one more decides the winner.
- **Battle ends** when a player runs out of cards. Winner takes all winnings.
- **Lose HP** when you lose a battle. Reach 0 HP → Game Over.
- **Between floors**: Choose 1 of 3 upgrade options to power up your deck.

---

## Special Card Abilities

| Ability       | Effect |
|---------------|--------|
| **Shield**    | Block the next loss this battle |
| **Double Down** | Win? Collect 2× the cards |
| **Poison**    | Opponent discards a won card |
| **Resurrect** | Lose? Choose to flip again |
| **Drain**     | On win, steal 1 card from enemy's deck |
| **Mirror**    | Copies the opponent's card value |
| **Bomb**      | Both played cards are destroyed |
| **Gold**      | Worth double in final score tiebreaks |

Ability cards are added to your deck via Upgrades between floors.

---

## Upgrades (Roguelike Progression)

| Upgrade         | Effect |
|-----------------|--------|
| **Ace High**    | Aces count as 15 (max once) |
| **War Veteran** | Auto-win WAR ties |
| **Lucky Draw**  | Add 3 random ability cards post-battle (stackable) |
| **Card Cull**   | Remove your 3 weakest cards at battle start (stackable) |
| **Resilience**  | +1 max HP, restore 1 HP (up to 2×) |
| **Double Trouble** | Add 3 Double Down cards (stackable) |
| **Poison Ivy**  | Add 3 Poison cards (stackable) |
| **Mirror Shield** | Add 2 Mirror + 2 Shield cards (stackable) |

---

## Boss Floors

Every 5th floor is a **Boss Battle**:
- Enemy deck is 30 cards, biased toward high values (7–14)
- 30–45% of boss cards have abilities
- Boss difficulty scales with floor depth

---

## Extending the Game

**Add a new ability:**
1. Add entry to `Card.Ability` enum in `Card.gd`
2. Add name/description to the dicts in `Card.gd`
3. Handle the effect in `BattleManager._resolve_player_win()` or `_resolve_enemy_win()`

**Add a new upgrade:**
1. Add entry to `GameState.ALL_UPGRADES`
2. Handle the effect in `GameState._apply_upgrade_effect()`

**Add a new floor event (random events):**
1. Create a new scene (e.g. `EventScene.tscn`)
2. In `UpgradeScreen._proceed()`, randomly route to the event scene before Battle

---

## Architecture Notes

- `GameState` (autoload) persists across scenes — it's the single source of truth.
- `BattleManager` is pure logic — no UI. `BattleScene` wires signals to visuals.
- `Deck.duplicate_deep_ish()` is called in `BattleScene` — implement this as
  a copy of the cards array so the original `GameState.player_deck` isn't mutated
  mid-battle (only winnings are merged back at battle end).

### Implementing `duplicate_deep_ish()` on Deck:
Add this method to `Deck.gd`:

```gdscript
func duplicate_deep_ish() -> Deck:
    var d = Deck.new()
    for c in cards:
        var copy = Card.new()
        copy.value = c.value
        copy.suit = c.suit
        copy.ability = c.ability
        copy.is_boss_card = c.is_boss_card
        d.cards.append(copy)
    return d
```
