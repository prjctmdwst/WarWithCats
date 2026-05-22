## BattleScene.gd
## Root script for the Battle scene. Wires up BattleManager to UI.

extends Node

# ── Node references (set in scene editor) ────────────────────────────────────
@onready var battle_manager: BattleManager = $BattleManager

@onready var player_card_visual: CardVisual = $UI/PlayerArea/CardVisual
@onready var enemy_card_visual: CardVisual = $UI/EnemyArea/CardVisual

@onready var player_deck_count: Label = $UI/PlayerArea/DeckCount
@onready var enemy_deck_count: Label = $UI/EnemyArea/DeckCount

@onready var result_label: Label = $UI/ResultLabel
@onready var ability_log: RichTextLabel = $UI/AbilityLog
@onready var play_button: Button = $UI/PlayButton
@onready var floor_label: Label = $UI/FloorLabel
@onready var hp_label: Label = $UI/HPLabel
@onready var round_label: Label = $UI/RoundLabel
@onready var war_banner: Label = $UI/WarBanner

@onready var player_shield_icon: TextureRect = $UI/PlayerArea/ShieldIcon
@onready var resurrect_banner: Panel = $UI/ResurrectBanner
@onready var resurrect_yes_btn: Button = $UI/ResurrectBanner/YesButton
@onready var resurrect_no_btn: Button = $UI/ResurrectBanner/NoButton

var _pending_resurrect: bool = false
var _is_animating: bool = false

# ── Setup ─────────────────────────────────────────────────────────────────────
func _ready() -> void:
	# Build enemy deck
	var is_boss = GameState.is_boss_floor()
	var enemy_deck: Deck
	if is_boss:
		enemy_deck = Deck.build_boss_deck(GameState.get_boss_level())
		floor_label.text = "⚠ BOSS — Floor %d" % GameState.floor_number
	else:
		enemy_deck = Deck.build_enemy_start(GameState.player_deck)
		floor_label.text = "Floor %d / %d" % [GameState.floor_number, GameState.max_floors]

	battle_manager.setup(GameState.player_deck.duplicate_deep_ish(), enemy_deck)

	# Connect signals
	battle_manager.round_resolved.connect(_on_round_resolved)
	battle_manager.war_triggered.connect(_on_war_triggered)
	battle_manager.battle_ended.connect(_on_battle_ended)
	battle_manager.ability_triggered.connect(_on_ability_triggered)

	play_button.pressed.connect(_on_play_pressed)
	resurrect_yes_btn.pressed.connect(_on_resurrect_yes)
	resurrect_no_btn.pressed.connect(_on_resurrect_no)

	resurrect_banner.hide()
	war_banner.hide()
	result_label.text = "Draw a card to begin!"

	_refresh_status()

# ── UI updates ────────────────────────────────────────────────────────────────
func _refresh_status() -> void:
	hp_label.text = "HP: %d / %d" % [GameState.player_hp, GameState.max_hp]
	player_deck_count.text = "Your deck: %d" % battle_manager.get_player_card_count()
	enemy_deck_count.text = "Enemy deck: %d" % battle_manager.get_enemy_card_count()
	round_label.text = "Round %d" % battle_manager.round_number
	player_shield_icon.visible = GameState.shield_active

# ── Play button ───────────────────────────────────────────────────────────────
func _on_play_pressed() -> void:
	if _is_animating or battle_manager.is_battle_over:
		return
	play_button.disabled = true
	war_banner.hide()
	result_label.text = ""
	_is_animating = true

	# Show face-down cards
	player_card_visual.display(null, true)
	enemy_card_visual.display(null, true)

	# Short delay then flip
	await get_tree().create_timer(0.4).timeout
	var result = battle_manager.play_round()
	if result.is_empty():
		return

	# Flip cards
	if result["player_card"]:
		player_card_visual.display(result["player_card"], false)
	if result["enemy_card"]:
		enemy_card_visual.display(result["enemy_card"], false)

	await get_tree().create_timer(0.3).timeout
	_animate_result(result)

func _animate_result(result: Dictionary) -> void:
	match result["outcome"]:
		"player":
			result_label.text = "✓ You win! +%d cards" % result["cards_won"]
			result_label.add_theme_color_override("font_color", Color.GREEN)
			player_card_visual.play_win_animation()
			enemy_card_visual.play_lose_animation()
		"enemy":
			result_label.text = "✗ Enemy wins!"
			result_label.add_theme_color_override("font_color", Color.RED)
			enemy_card_visual.play_win_animation()
			player_card_visual.play_lose_animation()
			# Check for Resurrect ability
			if result["player_card"] and result["player_card"].ability == Card.Ability.RESURRECT:
				await get_tree().create_timer(0.5).timeout
				_show_resurrect_prompt()
				return
		"war":
			result_label.text = "⚔ WAR!"
			result_label.add_theme_color_override("font_color", Color.YELLOW)
			war_banner.show()
		"draw_bomb":
			result_label.text = "💥 BOMB! Cards destroyed."
			result_label.add_theme_color_override("font_color", Color.ORANGE)

	await get_tree().create_timer(0.3).timeout
	_refresh_status()
	_is_animating = false
	if not battle_manager.is_battle_over:
		play_button.disabled = false

func _show_resurrect_prompt() -> void:
	resurrect_banner.show()
	play_button.disabled = true

func _on_resurrect_yes() -> void:
	resurrect_banner.hide()
	_is_animating = false
	# Replay the round with a +3 bonus baked in via a temp upgrade check
	# We simulate this by drawing another round immediately
	_add_ability_log("⚡ Resurrect triggered! Fighting back...")
	await get_tree().create_timer(0.3).timeout
	_on_play_pressed()

func _on_resurrect_no() -> void:
	resurrect_banner.hide()
	_is_animating = false
	_refresh_status()
	if not battle_manager.is_battle_over:
		play_button.disabled = false

# ── Signals from BattleManager ────────────────────────────────────────────────
func _on_round_resolved(_result: Dictionary) -> void:
	pass  # Already handled in _animate_result

func _on_war_triggered(cards_at_stake: int) -> void:
	war_banner.text = "⚔ WAR! %d cards at stake ⚔" % cards_at_stake

func _on_ability_triggered(who: String, _ability: Card.Ability, description: String) -> void:
	_add_ability_log("[%s] %s" % [who.capitalize(), description])
	if who == "player":
		player_card_visual.play_ability_animation()
	elif who == "enemy":
		enemy_card_visual.play_ability_animation()

func _add_ability_log(text: String) -> void:
	ability_log.append_text("\n" + text)

func _on_battle_ended(player_won: bool, cards_gained: int) -> void:
	play_button.disabled = true
	_refresh_status()
	await get_tree().create_timer(0.6).timeout

	if player_won:
		result_label.text = "🏆 Battle Won! +%d cards" % cards_gained
		result_label.add_theme_color_override("font_color", Color.GOLD)
	else:
		if GameState.is_dead():
			result_label.text = "💀 You have fallen..."
			result_label.add_theme_color_override("font_color", Color.RED)
			await get_tree().create_timer(1.5).timeout
			get_tree().change_scene_to_file("res://scenes/GameOver.tscn")
			return
		else:
			result_label.text = "😞 Battle Lost! -1 HP"
			result_label.add_theme_color_override("font_color", Color.RED)

	await get_tree().create_timer(1.2).timeout
	# Proceed to upgrade/map screen
	get_tree().change_scene_to_file("res://scenes/UpgradeScreen.tscn")
