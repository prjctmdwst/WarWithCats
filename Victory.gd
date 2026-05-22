## Victory.gd
extends Control

@onready var title_label: Label = $VBox/Title
@onready var stats_label: Label = $VBox/Stats
@onready var play_again_button: Button = $VBox/PlayAgain
@onready var menu_button: Button = $VBox/Menu

func _ready() -> void:
	title_label.text = "⚔ YOU CONQUERED THE WAR ⚔"
	stats_label.text = "Floors cleared: %d\nFinal deck: %d cards\nHP remaining: %d / %d" % [
		GameState.floor_number,
		GameState.player_deck.count(),
		GameState.player_hp,
		GameState.max_hp,
	]
	play_again_button.pressed.connect(func():
		GameState.start_new_run()
		GameState.advance_floor()
		get_tree().change_scene_to_file("res://scenes/Battle.tscn")
	)
	menu_button.pressed.connect(func():
		get_tree().change_scene_to_file("res://scenes/Main.tscn")
	)
