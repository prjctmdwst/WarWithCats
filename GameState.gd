## GameState.gd
## Autoload. Persistent run data, cat-themed upgrades, progression.

extends Node

var run_active: bool = false
var floor_number: int = 0
var max_floors: int = 10
var gold: int = 0

var player_deck: Deck = null
var enemy_deck: Deck = null

var player_hp: int = 3
var max_hp: int = 3
var shield_active: bool = false

var upgrades: Array[Dictionary] = []

# ── Cat-themed upgrades ──────────────────────────────────────────────────────
const ALL_UPGRADES = [
	{
		"id": "ace_high",
		"name": "🐾 Apex Predator",
		"description": "Aces count as 15. Top of the food chain.",
		"max_level": 1,
		"emoji": "🐾",
	},
	{
		"id": "war_veteran",
		"name": "😾 Battle-Scarred",
		"description": "Auto-win WAR ties. Been there, done that.",
		"max_level": 1,
		"emoji": "😾",
	},
	{
		"id": "lucky_draw",
		"name": "🎲 Lucky Litter",
		"description": "After each battle, 3 ability cards join your deck.",
		"max_level": 3,
		"emoji": "🎲",
	},
	{
		"id": "cull",
		"name": "✂️ Darwin's Claws",
		"description": "Remove 3 weakest cards at battle start.",
		"max_level": 2,
		"emoji": "✂️",
	},
	{
		"id": "resilience",
		"name": "❤️ Extra Life",
		"description": "+1 max HP and restore 1 HP. Cats have nine lives.",
		"max_level": 3,
		"emoji": "❤️",
	},
	{
		"id": "double_trouble",
		"name": "😸 Double Trouble",
		"description": "Add 3 'Nine Lives x2' ability cards.",
		"max_level": 3,
		"emoji": "😸",
	},
	{
		"id": "poison_ivy",
		"name": "🤢 Hairball Hoard",
		"description": "Add 3 'Hairball' ability cards.",
		"max_level": 3,
		"emoji": "🤢",
	},
	{
		"id": "mirror_shield",
		"name": "🪞 Copycat Guard",
		"description": "Add 2 'Copycat' + 2 'Fur Coat' ability cards.",
		"max_level": 2,
		"emoji": "🪞",
	},
	{
		"id": "catnip",
		"name": "🌿 Catnip Stash",
		"description": "Add 2 'Catnip Bomb' cards. Chaos reigns.",
		"max_level": 2,
		"emoji": "🌿",
	},
]

signal run_started
signal floor_changed(floor: int)
signal player_hp_changed(hp: int, max_hp: int)
signal upgrade_acquired(upgrade: Dictionary)
signal run_ended(victory: bool)

func start_new_run() -> void:
	run_active = true
	floor_number = 0
	gold = 0
	player_hp = 3
	max_hp = 3
	shield_active = false
	upgrades.clear()
	player_deck = Deck.build_player_start()
	run_started.emit()

func advance_floor() -> void:
	floor_number += 1
	floor_changed.emit(floor_number)

func is_boss_floor() -> bool:
	return floor_number % 5 == 0

func is_final_floor() -> bool:
	return floor_number >= max_floors

func get_boss_level() -> int:
	return floor_number / 5

func take_damage(amount: int = 1) -> void:
	if shield_active:
		shield_active = false
		return
	player_hp = max(0, player_hp - amount)
	player_hp_changed.emit(player_hp, max_hp)
	if player_hp <= 0:
		end_run(false)

func heal(amount: int = 1) -> void:
	player_hp = min(max_hp, player_hp + amount)
	player_hp_changed.emit(player_hp, max_hp)

func is_dead() -> bool:
	return player_hp <= 0

func has_upgrade(id: String) -> bool:
	for u in upgrades:
		if u["id"] == id:
			return true
	return false

func get_upgrade_level(id: String) -> int:
	for u in upgrades:
		if u["id"] == id:
			return u.get("level", 1)
	return 0

func acquire_upgrade(upgrade_data: Dictionary) -> void:
	for u in upgrades:
		if u["id"] == upgrade_data["id"]:
			u["level"] = u.get("level", 1) + 1
			_apply_upgrade_effect(upgrade_data["id"])
			upgrade_acquired.emit(u)
			return
	var entry = upgrade_data.duplicate()
	entry["level"] = 1
	upgrades.append(entry)
	_apply_upgrade_effect(upgrade_data["id"])
	upgrade_acquired.emit(entry)

func _apply_upgrade_effect(id: String) -> void:
	match id:
		"resilience":
			max_hp += 1
			heal(1)
		"lucky_draw":
			var abilities = [Card.Ability.SHIELD, Card.Ability.DOUBLE,
				Card.Ability.POISON, Card.Ability.RESURRECT]
			player_deck.inject_ability_cards(
				abilities[SeedManager.upgrade_randi() % abilities.size()], 3)
		"cull":
			player_deck.cull_weak_cards(3)
		"double_trouble":
			player_deck.inject_ability_cards(Card.Ability.DOUBLE, 3)
		"poison_ivy":
			player_deck.inject_ability_cards(Card.Ability.POISON, 3)
		"mirror_shield":
			player_deck.inject_ability_cards(Card.Ability.MIRROR, 2)
			player_deck.inject_ability_cards(Card.Ability.SHIELD, 2)
		"catnip":
			player_deck.inject_ability_cards(Card.Ability.BOMB, 2)

func get_upgrade_choices(count: int = 3) -> Array[Dictionary]:
	var available: Array[Dictionary] = []
	for u in ALL_UPGRADES:
		var current_level = get_upgrade_level(u["id"])
		if current_level < u.get("max_level", 1):
			available.append(u)
	# Use seeded shuffle for reproducible upgrade offerings
	var shuffled = SeedManager.shuffle_array(available)
	var result: Array[Dictionary] = []
	for i in range(min(count, shuffled.size())):
		result.append(shuffled[i])
	return result

func end_run(victory: bool) -> void:
	run_active = false
	run_ended.emit(victory)
