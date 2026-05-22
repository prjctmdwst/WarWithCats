# War With Cats 🐱⚔️

A roguelike deck-building card game with feline chaos and strategic depth. Built in **Godot** with fully seeded runs like Balatro.

## Overview

War With Cats is a turn-based roguelike where you battle an endless army of cats using a deck of cards you construct throughout your run. Combine powerful synergies, discover rare artifacts, and unlock new strategies to defeat increasingly difficult feline opponents.

Every run is seeded, meaning you can share seeds with friends for identical gameplay experiences, or chase high scores on the same randomly-generated battlefield.

## Features

- **Seeded Roguelike Runs** — Play the same seed for consistent replayability, or generate endless unique runs
- **Deck-Building Gameplay** — Collect and synergize cards to create powerful combos
- **Feline Art & Aesthetics** — Unique cat-themed visuals and enemy designs throughout
- **Strategic Depth** — Manage resources, plan ahead, and adapt to RNG for victory
- **Progressive Difficulty** — Face tougher cats with more complex mechanics as you advance

## How to Play

1. **Build Your Deck** — Start with basic cards and recruit new ones after each battle
2. **Battle Cats** — Deploy your cards strategically to defeat cat opponents
3. **Collect Synergies** — Discover powerful card combinations and artifacts
4. **Climb the Ranks** — Defeat progressively stronger feline enemies
5. **Chase Your Best Run** — Beat your high score or share seeds for friendly competition

## Technology

- **Engine:** Godot
- **Gameplay:** Turn-based card mechanics with seeded randomization
- **Art Direction:** Cat-focused visual theme with roguelike aesthetics

## Getting Started

### Prerequisites
- Godot (version X.X or later)

### Running Locally

```bash
git clone https://github.com/prjctmdwst/WarWithCats.git
cd WarWithCats
# Open project in Godot editor
godot --path .
```

### Building

Export builds are available through the Godot export templates. See the `export_presets.cfg` file for details.

## Contributing

Contributions are welcome! Feel free to submit issues for bugs or feature requests, or open a pull request with improvements.

## License

[Add your license here]

CHANGELOG V0.21
New file — SeedManager.gd (Autoload)

Balatro-style seeded RNG with cat-word seeds like PAWSZOOMIES4721
Separate sub-RNGs for deck shuffles, enemy generation, upgrades, and events — so each system is isolated and runs are fully reproducible from any seed

Updated MainMenu.gd

Seed input field on the title screen — type any seed or hit 🎲 for a random one
Displays the active seed string + numeric ID so you can share runs with friends

Updated Card.gd

Suits renamed: Paws 🐾, Claws 🐱, Whiskers 😸, Tails 🐈
Abilities renamed: Shield → Fur Coat, Double → Nine Lives x2, Poison → Hairball, Resurrect → Nine Lives, Drain → Kitten Tax, Mirror → Copycat, Bomb → Catnip Bomb, Gold → Golden Paw
Face cards get flavour text (Jester Cat, Queen Cat, King Cat, Ace Cat)

Updated Deck.gd — all randi()/randf() calls replaced with SeedManager.deck_randi() etc., plus duplicate_deep_ish() is now built in
Updated GameState.gd — upgrades are cat-themed (e.g. Apex Predator, Battle-Scarred, Lucky Litter, Darwin's Claws), upgrade shuffle uses seeded RNG
Updated BattleManager.gd — ability log messages use cat-flavored text, enemy RNG uses SeedManager.enemy_randi()

**Ready to wage war? Pick your seed and clash with cats!** 🐾
