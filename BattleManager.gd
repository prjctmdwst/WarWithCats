## BattleManager.gd
## Core War logic with cat-themed ability names. Seed-aware.

class_name BattleManager
extends Node

signal round_resolved(result: Dictionary)
signal war_triggered(cards_at_stake: int)
signal battle_ended(player_won: bool, cards_gained: int)
signal ability_triggered(who: String, ability: Card.Ability, description: String)

var player_deck: Deck
var enemy_deck: Deck
var player_winnings: Deck
var enemy_winnings: Deck

var round_number: int = 0
var is_battle_over: bool = false
var max_rounds: int = 30
var war_pile: Array[Card] = []

func _ready() -> void:
	player_winnings = Deck.new()
	enemy_winnings = Deck.new()

func setup(p_deck: Deck, e_deck: Deck) -> void:
	player_deck = p_deck
	enemy_deck = e_deck
	if GameState.has_upgrade("cull"):
		var cull_count = 3 * GameState.get_upgrade_level("cull")
		player_deck.cull_weak_cards(cull_count)

func play_round() -> Dictionary:
	if is_battle_over:
		return {}

	round_number += 1
	var result = {
		"round": round_number,
		"player_card": null,
		"enemy_card": null,
		"outcome": "",
		"cards_won": 0,
		"ability_effects": [],
	}

	var p_card: Card = player_deck.draw()
	var e_card: Card = enemy_deck.draw()

	if p_card == null or e_card == null:
		_resolve_empty_deck(p_card == null)
		return result

	result["player_card"] = p_card
	result["enemy_card"] = e_card

	# Catnip Bomb
	if p_card.ability == Card.Ability.BOMB or e_card.ability == Card.Ability.BOMB:
		result["outcome"] = "draw_bomb"
		result["ability_effects"].append("💥 Catnip Bomb! Both cards vanish!")
		ability_triggered.emit("both", Card.Ability.BOMB, "💥 Catnip Bomb — both cards destroyed!")
		war_pile.clear()
		round_resolved.emit(result)
		_check_battle_end()
		return result

	var p_val = p_card.get_effective_value(e_card.value)
	var e_val = e_card.get_effective_value(p_card.value)

	if p_card.ability == Card.Ability.MIRROR:
		ability_triggered.emit("player", Card.Ability.MIRROR, "🪞 Copycat mirrors enemy value!")
	if e_card.ability == Card.Ability.MIRROR:
		ability_triggered.emit("enemy", Card.Ability.MIRROR, "🪞 Enemy Copycat mirrors your value!")

	if GameState.has_upgrade("ace_high"):
		if p_card.value == 14: p_val = 15
		if e_card.value == 14: e_val = 15

	war_pile.append(p_card)
	war_pile.append(e_card)

	if p_val > e_val:
		result["outcome"] = "player"
		result["cards_won"] = _resolve_player_win(p_card)
	elif e_val > p_val:
		result["outcome"] = "enemy"
		_resolve_enemy_win(e_card)
	else:
		result["outcome"] = "war"
		_trigger_war()
		war_triggered.emit(war_pile.size())

	round_resolved.emit(result)
	_check_battle_end()
	return result

func _resolve_player_win(winning_card: Card) -> int:
	var all_cards = war_pile.duplicate()
	war_pile.clear()
	var multiplier = 1

	if winning_card.ability == Card.Ability.DOUBLE:
		multiplier = 2
		ability_triggered.emit("player", Card.Ability.DOUBLE, "😸 Nine Lives x2! Collecting double cards!")

	for c in all_cards:
		for _i in range(multiplier):
			player_winnings.add_to_bottom(c)

	if winning_card.ability == Card.Ability.DRAIN and not enemy_deck.is_empty():
		var stolen = enemy_deck.draw()
		if stolen:
			player_winnings.add_to_bottom(stolen)
			ability_triggered.emit("player", Card.Ability.DRAIN, "🐾 Kitten Tax! Stole 1 card!")

	if winning_card.ability == Card.Ability.POISON and not enemy_winnings.is_empty():
		enemy_winnings.cards.pop_back()
		ability_triggered.emit("player", Card.Ability.POISON, "🤢 Hairball! Enemy discards a won card!")

	return all_cards.size() * multiplier

func _resolve_enemy_win(winning_card: Card) -> void:
	var all_cards = war_pile.duplicate()
	war_pile.clear()

	for c in all_cards:
		enemy_winnings.add_to_bottom(c)

	if winning_card.ability == Card.Ability.DOUBLE:
		ability_triggered.emit("enemy", Card.Ability.DOUBLE, "😾 Enemy Nine Lives x2!")
		for c in all_cards:
			enemy_winnings.add_to_bottom(c)

	if winning_card.ability == Card.Ability.DRAIN and not player_deck.is_empty():
		var stolen = player_deck.draw()
		if stolen:
			enemy_winnings.add_to_bottom(stolen)
			ability_triggered.emit("enemy", Card.Ability.DRAIN, "😾 Enemy Kitten Tax! Lost 1 card!")

func _trigger_war() -> void:
	if GameState.has_upgrade("war_veteran"):
		ability_triggered.emit("player", Card.Ability.NONE, "😾 Battle-Scarred — auto-win the WAR!")
		_resolve_player_win(war_pile[war_pile.size() - 2])
		return

	for _i in range(3):
		var p = player_deck.draw()
		var e = enemy_deck.draw()
		if p: war_pile.append(p)
		if e: war_pile.append(e)
		if p == null or e == null:
			break

func _resolve_empty_deck(player_empty: bool) -> void:
	is_battle_over = true
	var player_won = not player_empty
	var gained = 0
	if player_won:
		gained = player_winnings.count()
		for c in player_winnings.cards:
			GameState.player_deck.add_to_bottom(c)
	else:
		GameState.take_damage(1)
	battle_ended.emit(player_won, gained)

func _check_battle_end() -> void:
	if is_battle_over:
		return
	if player_deck.is_empty() and enemy_deck.is_empty():
		var player_won = player_winnings.count() >= enemy_winnings.count()
		var gained = 0
		if player_won:
			gained = player_winnings.count()
			for c in player_winnings.cards:
				GameState.player_deck.add_to_bottom(c)
		else:
			GameState.take_damage(1)
		is_battle_over = true
		battle_ended.emit(player_won, gained)
	elif round_number >= max_rounds:
		var player_won = player_deck.count() + player_winnings.count() >= \
						 enemy_deck.count() + enemy_winnings.count()
		is_battle_over = true
		battle_ended.emit(player_won, player_winnings.count())

func get_player_card_count() -> int:
	return player_deck.count() + player_winnings.count()

func get_enemy_card_count() -> int:
	return enemy_deck.count() + enemy_winnings.count()
