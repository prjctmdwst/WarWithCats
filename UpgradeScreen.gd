## UpgradeScreen.gd
## Post-battle upgrade selection screen.

extends Control

@onready var title_label: Label = $VBox/Title
@onready var subtitle_label: Label = $VBox/Subtitle
@onready var upgrade_container: HBoxContainer = $VBox/UpgradeContainer
@onready var skip_button: Button = $VBox/SkipButton
@onready var floor_label: Label = $VBox/FloorInfo
@onready var hp_label: Label = $VBox/HPInfo
@onready var deck_label: Label = $VBox/DeckInfo

const UPGRADE_CARD_SCENE = preload("res://scenes/UpgradeCard.tscn")

var _choices: Array[Dictionary] = []

func _ready() -> void:
	GameState.advance_floor()

	floor_label.text = "Floor %d complete!" % (GameState.floor_number - 1)
	hp_label.text = "HP: %d / %d" % [GameState.player_hp, GameState.max_hp]
	deck_label.text = "Deck size: %d cards" % GameState.player_deck.count()

	if GameState.is_final_floor():
		title_label.text = "⚔ FINAL BOSS AWAITS ⚔"
		subtitle_label.text = "Choose your last upgrade wisely."
	else:
		title_label.text = "Choose an Upgrade"
		subtitle_label.text = "Pick one to enhance your deck for the run."

	_choices = GameState.get_upgrade_choices(3)

	if _choices.is_empty():
		subtitle_label.text = "No upgrades available. Proceed!"
		skip_button.text = "Continue →"
	else:
		for choice in _choices:
			var card_node = UPGRADE_CARD_SCENE.instantiate()
			upgrade_container.add_child(card_node)
			card_node.setup(choice)
			card_node.selected.connect(_on_upgrade_selected.bind(choice))

	skip_button.pressed.connect(_on_skip_pressed)
	skip_button.text = "Skip Upgrade →"

func _on_upgrade_selected(upgrade: Dictionary) -> void:
	GameState.acquire_upgrade(upgrade)
	_proceed()

func _on_skip_pressed() -> void:
	_proceed()

func _proceed() -> void:
	if GameState.is_final_floor():
		# Go to final boss
		get_tree().change_scene_to_file("res://scenes/Battle.tscn")
	elif GameState.floor_number > GameState.max_floors:
		get_tree().change_scene_to_file("res://scenes/Victory.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/Battle.tscn")
