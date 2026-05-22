## UpgradeCard.gd
## A selectable upgrade card in the upgrade selection screen.

extends PanelContainer

signal selected

@onready var name_label: Label = $VBox/NameLabel
@onready var desc_label: Label = $VBox/DescLabel
@onready var level_label: Label = $VBox/LevelLabel
@onready var select_button: Button = $VBox/SelectButton

var _upgrade_data: Dictionary = {}

func setup(data: Dictionary) -> void:
	_upgrade_data = data
	name_label.text = data.get("name", "Unknown")
	desc_label.text = data.get("description", "")

	var current = GameState.get_upgrade_level(data.get("id", ""))
	var max_lvl = data.get("max_level", 1)
	if current > 0:
		level_label.text = "Level %d → %d" % [current, current + 1]
		select_button.text = "Upgrade"
	else:
		level_label.text = "New!"
		select_button.text = "Choose"

	select_button.pressed.connect(func(): selected.emit())

func _ready() -> void:
	mouse_entered.connect(_on_hover)
	mouse_exited.connect(_on_unhover)

func _on_hover() -> void:
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.05, 1.05), 0.1)

func _on_unhover() -> void:
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)
