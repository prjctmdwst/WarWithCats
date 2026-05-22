## CardVisual.gd
## Cat-themed card display with cozy warm styling.

class_name CardVisual
extends PanelContainer

@onready var value_label: Label = $VBox/ValueLabel
@onready var suit_label: Label = $VBox/SuitLabel
@onready var ability_label: Label = $VBox/AbilityLabel
@onready var ability_desc: Label = $VBox/AbilityDesc
@onready var flavour_label: Label = $VBox/FlavourLabel

var card_data: Card = null
var is_face_down: bool = false
var _tween: Tween

func display(card: Card, face_down: bool = false) -> void:
	card_data = card
	is_face_down = face_down
	_refresh()

func flip_face_up() -> void:
	if not is_face_down: return
	is_face_down = false
	_tween = create_tween()
	_tween.tween_property(self, "scale:x", 0.0, 0.1)
	_tween.tween_callback(_refresh)
	_tween.tween_property(self, "scale:x", 1.0, 0.1)

func play_win_animation() -> void:
	_tween = create_tween()
	_tween.tween_property(self, "position:y", position.y - 22, 0.12)
	_tween.tween_property(self, "position:y", position.y, 0.18)

func play_lose_animation() -> void:
	_tween = create_tween()
	_tween.tween_property(self, "modulate:a", 0.25, 0.25)
	_tween.tween_property(self, "modulate:a", 1.0, 0.2)

func play_ability_animation() -> void:
	_tween = create_tween()
	_tween.tween_property(self, "scale", Vector2(1.18, 1.18), 0.1)
	_tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)

func _refresh() -> void:
	if is_face_down:
		value_label.text = "?"
		suit_label.text = "🐱"
		ability_label.text = ""
		ability_desc.text = ""
		if flavour_label: flavour_label.text = ""
		add_theme_stylebox_override("panel", _make_back_style())
		return

	if card_data == null:
		return

	value_label.text = card_data.get_display_value()
	suit_label.text = card_data.get_suit_symbol()
	ability_label.text = card_data.get_ability_name()
	ability_desc.text = card_data.get_ability_description()
	if flavour_label:
		flavour_label.text = card_data.get_flavour()

	# Red suits
	var col = Color(0.75, 0.1, 0.1) if card_data.is_red() else Color(0.1, 0.1, 0.2)
	value_label.add_theme_color_override("font_color", col)

	if card_data.is_boss_card:
		add_theme_stylebox_override("panel", _make_boss_style())
	elif card_data.ability != Card.Ability.NONE:
		add_theme_stylebox_override("panel", _make_ability_style())
	else:
		add_theme_stylebox_override("panel", _make_normal_style())

func _make_normal_style() -> StyleBoxFlat:
	var s = StyleBoxFlat.new()
	s.bg_color = Color(0.98, 0.95, 0.88)
	s.set_border_width_all(2)
	s.border_color = Color(0.55, 0.42, 0.3)
	s.set_corner_radius_all(10)
	s.content_margin_left = 8; s.content_margin_right = 8
	s.content_margin_top = 8; s.content_margin_bottom = 8
	return s

func _make_ability_style() -> StyleBoxFlat:
	var s = _make_normal_style()
	s.bg_color = Color(0.94, 0.98, 0.88)
	s.border_color = Color(0.35, 0.62, 0.2)
	s.set_border_width_all(3)
	return s

func _make_boss_style() -> StyleBoxFlat:
	var s = _make_normal_style()
	s.bg_color = Color(0.18, 0.06, 0.06)
	s.border_color = Color(0.85, 0.55, 0.1)
	s.set_border_width_all(3)
	return s

func _make_back_style() -> StyleBoxFlat:
	var s = StyleBoxFlat.new()
	s.bg_color = Color(0.25, 0.18, 0.38)
	s.set_border_width_all(3)
	s.border_color = Color(0.65, 0.5, 0.85)
	s.set_corner_radius_all(10)
	return s
