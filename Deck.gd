## Deck.gd
## Manages a collection of cards. All shuffle/random ops use SeedManager.

class_name Deck
extends RefCounted

var cards: Array[Card] = []
var discard_pile: Array[Card] = []

static func build_standard() -> Deck:
	var deck = Deck.new()
	for suit in Card.Suit.values():
		for val in range(2, 15):
			var c = Card.new()
			c.value = val
			c.suit = suit
			c.ability = Card.Ability.NONE
			deck.cards.append(c)
	deck.shuffle()
	return deck

static func build_player_start() -> Deck:
	var full = build_standard()
	var half = Deck.new()
	half.cards = full.cards.slice(0, 26)
	return half

static func build_enemy_start(_player_deck: Deck) -> Deck:
	var full = build_standard()
	var enemy = Deck.new()
	enemy.cards = full.cards.slice(26, 52)
	return enemy

## Boss deck: cat-boss themed, weighted high values
static func build_boss_deck(boss_level: int) -> Deck:
	var deck = Deck.new()
	for _i in range(30):
		var c = Card.new()
		c.value = SeedManager.enemy_randi_range(7, 14)
		c.suit = Card.Suit.values()[SeedManager.enemy_randi() % 4]
		if SeedManager.enemy_randf() < 0.3 + boss_level * 0.05:
			var abilities = [
				Card.Ability.SHIELD, Card.Ability.DOUBLE,
				Card.Ability.POISON, Card.Ability.DRAIN
			]
			c.ability = abilities[SeedManager.enemy_randi() % abilities.size()]
		c.is_boss_card = true
		deck.cards.append(c)
	deck.shuffle()
	return deck

func shuffle() -> void:
	# Use seeded RNG
	var shuffled = SeedManager.shuffle_array(cards)
	cards.clear()
	for c in shuffled:
		cards.append(c)

func draw() -> Card:
	if cards.is_empty():
		if not discard_pile.is_empty():
			recycle_discard()
		else:
			return null
	return cards.pop_front()

func add_to_bottom(card: Card) -> void:
	cards.append(card)

func add_to_top(card: Card) -> void:
	cards.push_front(card)

func discard(card: Card) -> void:
	discard_pile.append(card)

func recycle_discard() -> void:
	cards.append_array(discard_pile)
	discard_pile.clear()
	shuffle()

func count() -> int:
	return cards.size()

func total_count() -> int:
	return cards.size() + discard_pile.size()

func is_empty() -> bool:
	return cards.is_empty() and discard_pile.is_empty()

func inject_ability_cards(ability: Card.Ability, count: int) -> void:
	for _i in range(count):
		var c = Card.new()
		c.value = SeedManager.deck_randi_range(5, 13)
		c.suit = Card.Suit.values()[SeedManager.deck_randi() % 4]
		c.ability = ability
		cards.append(c)
	shuffle()

func cull_weak_cards(n: int) -> void:
	cards.sort_custom(func(a, b): return a.value < b.value)
	for _i in range(min(n, cards.size())):
		cards.pop_front()
	shuffle()

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
