extends Node2D

const GAME_SCENE: String = "res://maze1.tscn"

func _ready() -> void:
	if not InputMap.has_action("start_game"):
		InputMap.add_action("start_game")

	var start_key := InputEventKey.new()
	start_key.keycode = KEY_E
	InputMap.action_add_event("start_game", start_key)

	var start_button := InputEventJoypadButton.new()
	start_button.button_index = JOY_BUTTON_B
	InputMap.action_add_event("start_game", start_button)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_echo() or not event.is_action_pressed("start_game"):
		return
	get_tree().change_scene_to_file(GAME_SCENE)
