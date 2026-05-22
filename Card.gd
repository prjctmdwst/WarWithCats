## Card.gd
## A playing card in War With Cats. Suits are cat-themed.
## Abilities have cat-flavored names.

class_name Card
extends Resource

enum Suit { PAWS, CLAWS, WHISKERS, TAILS }
enum Ability {
	NONE,
	SHIELD,       # Block the next loss (once per battle)
	DOUBLE,       # If you win, gain 2x the cards
	POISON,       # Opponent discards top card of their winnings
	RESURRECT,    # If you lose, flip again
	DRAIN,        # Steal 1 card from opponent's deck on win
	MIRROR,       # Copy opponent's card value this round
	BOMB,         # Both players discard played cards
	GOLD,         # Worth 2 points in scoring
}

const ABILITY_NAMES = {
	Ability.NONE:      "",
	Ability.SHIELD:    "Fur Coat",
	Ability.DOUBLE:    "Nine Lives x2",
	Ability.POISON:    "Hairball",
	Ability.RESURRECT: "Nine Lives",
	Ability.DRAIN:     "Kitten Tax",
	Ability.MIRROR:    "Copycat",
	Ability.BOMB:      "Catnip Bomb",
	Ability.GOLD:      "Golden Paw",
}

const ABILITY_DESCRIPTIONS = {
	Ability.NONE:      "",
	Ability.SHIELD:    "Absorbs the next loss this battle.",
	Ability.DOUBLE:    "Win? Collect 2× the cards.",
	Ability.POISON:    "Enemy discards a won card.",
	Ability.RESURRECT: "Lose? Challenge again!",
	Ability.DRAIN:     "On win, steal 1 card from enemy.",
	Ability.MIRROR:    "Copies the enemy's card value.",
	Ability.BOMB:      "Both played cards are destroyed.",
	Ability.GOLD:      "Worth double in tiebreaks.",
}

# Cat suit symbols
const SUIT_SYMBOLS = {
	Suit.PAWS:     "🐾",
	Suit.CLAWS:    "🐱",
	Suit.WHISKERS: "😸",
	Suit.TAILS:    "🐈",
}

const SUIT_NAMES = {
	Suit.PAWS:     "Paws",
	Suit.CLAWS:    "Claws",
	Suit.WHISKERS: "Whiskers",
	Suit.TAILS:    "Tails",
}

const VALUE_NAMES = {
	2: "2", 3: "3", 4: "4", 5: "5", 6: "6",
	7: "7", 8: "8", 9: "9", 10: "10",
	11: "J", 12: "Q", 13: "K", 14: "A"
}

# Cat breed names for face cards (flavour only)
const FACE_FLAVOUR = {
	11: "Jester Cat",
	12: "Queen Cat",
	13: "King Cat",
	14: "Ace Cat",
}

@export var value: int = 2
@export var suit: Suit = Suit.PAWS
@export var ability: Ability = Ability.NONE
@export var is_boss_card: bool = false

func get_display_value() -> String:
	return VALUE_NAMES.get(value, str(value))

func get_suit_symbol() -> String:
	return SUIT_SYMBOLS.get(suit, "?")

func get_suit_name() -> String:
	return SUIT_NAMES.get(suit, "?")

func get_ability_name() -> String:
	return ABILITY_NAMES.get(ability, "")

func get_ability_description() -> String:
	return ABILITY_DESCRIPTIONS.get(ability, "")

func get_flavour() -> String:
	return FACE_FLAVOUR.get(value, "")

func is_red() -> bool:
	return suit == Suit.WHISKERS or suit == Suit.TAILS

func get_effective_value(opponent_value: int = 0) -> int:
	if ability == Ability.MIRROR:
		return opponent_value
	return value

func to_string() -> String:
	return "%s%s" % [get_display_value(), get_suit_symbol()]
