## GameOver.gd
extends Control

@onready var floors_label: Label = $VBox/FloorsLabel
@onready var retry_button: Button = $VBox/RetryButton
@onready var menu_button: Button = $VBox/MenuButton

func _ready() -> void:
	floors_label.text = "You reached Floor %d" % GameState.floor_number
	retry_button.pressed.connect(func():
		GameState.start_new_run()
		GameState.advance_floor()
		get_tree().change_scene_to_file("res://scenes/Battle.tscn")
	)
	menu_button.pressed.connect(func():
		get_tree().change_scene_to_file("res://scenes/Main.tscn")
	)
