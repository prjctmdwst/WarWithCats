## MainMenu.gd
## Cat-themed title screen with Balatro-style seed entry.

extends Control

@onready var start_button: Button = $VBox/StartButton
@onready var quit_button: Button = $VBox/QuitButton
@onready var seed_input: LineEdit = $VBox/SeedRow/SeedInput
@onready var random_seed_btn: Button = $VBox/SeedRow/RandomBtn
@onready var seed_display: Label = $VBox/SeedDisplay
@onready var title_label: Label = $VBox/Title
@onready var sub_label: Label = $VBox/Subtitle

func _ready() -> void:
	# Generate a fresh seed on load
	SeedManager.set_random_seed()
	_update_seed_display()

	start_button.pressed.connect(_on_start)
	quit_button.pressed.connect(func(): get_tree().quit())
	random_seed_btn.pressed.connect(_on_random_seed)
	seed_input.text_submitted.connect(_on_seed_submitted)
	seed_input.text_changed.connect(_on_seed_changed)

	# Gentle title pulse
	var tween = create_tween().set_loops()
	tween.tween_property(title_label, "modulate:a", 0.75, 1.4)
	tween.tween_property(title_label, "modulate:a", 1.0, 1.4)

func _on_random_seed() -> void:
	SeedManager.set_random_seed()
	seed_input.text = ""
	_update_seed_display()

func _on_seed_changed(text: String) -> void:
	if text.strip_edges() != "":
		SeedManager.set_seed_from_string(text)
		seed_display.text = "Seed: %s  (ID: %d)" % [SeedManager.seed_string, SeedManager.current_seed]
		seed_display.add_theme_color_override("font_color", Color(0.5, 0.9, 0.5))

func _on_seed_submitted(text: String) -> void:
	if text.strip_edges() != "":
		SeedManager.set_seed_from_string(text)
	_update_seed_display()

func _update_seed_display() -> void:
	seed_input.placeholder_text = SeedManager.seed_string
	seed_display.text = "🌱 Seed: %s" % SeedManager.seed_string
	seed_display.add_theme_color_override("font_color", Color(0.75, 0.88, 0.6))

func _on_start() -> void:
	# If user typed a custom seed, apply it
	if seed_input.text.strip_edges() != "":
		SeedManager.set_seed_from_string(seed_input.text)
	GameState.start_new_run()
	GameState.advance_floor()
	get_tree().change_scene_to_file("res://scenes/Battle.tscn")
