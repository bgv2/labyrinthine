extends Node2D

@onready var player: PlayerController = $CharacterBody2D
@onready var maze: TileMapLayer = $TileMapLayer
@onready var interaction_prompt: Label = $UI/InteractionPrompt
@onready var win_message: Label = $UI/WinMessage
@onready var exit_area: Area2D = $"Exit (Area2D)"

var active_relay: RelayController
var nearby_relay: RelayController
var nearby_relays: Array[RelayController] = []
var has_won: bool = false

func _ready() -> void:
	_setup_input_actions()
	_add_maze_wall_collisions()
	interaction_prompt.hide()
	win_message.hide()
	for child in get_children():
		if child is RelayController:
			child.player_entered.connect(_on_relay_player_entered)
			child.player_left.connect(_on_relay_player_left)
	exit_area.body_entered.connect(_on_exit_body_entered)

func _unhandled_input(event: InputEvent) -> void:
	if has_won or event.is_echo() or not event.is_action_pressed("interact"):
		return
	if nearby_relay == null:
		return

	if nearby_relay == active_relay:
		active_relay.deactivate()
		active_relay = null
		player.restore_light()
	else:
		for child in get_children():
			if child is RelayController and child != nearby_relay:
				child.deactivate()
		nearby_relay.activate()
		active_relay = nearby_relay
		player.dim_light()
	_update_interaction_prompt()

func _on_relay_player_entered(relay: RelayController) -> void:
	if has_won:
		return
	if not nearby_relays.has(relay):
		nearby_relays.append(relay)
	nearby_relay = relay
	_update_interaction_prompt()

func _on_relay_player_left(relay: RelayController) -> void:
	nearby_relays.erase(relay)
	nearby_relay = nearby_relays.back() if not nearby_relays.is_empty() else null
	_update_interaction_prompt()

func _update_interaction_prompt() -> void:
	if has_won or nearby_relay == null:
		interaction_prompt.hide()
		return
	if nearby_relay == active_relay:
		interaction_prompt.text = "E / 🅑 – Disable relay"
	else:
		interaction_prompt.text = "E / 🅑 – Activate this relay"
	interaction_prompt.show()

func _on_exit_body_entered(body: Node2D) -> void:
	if has_won or body != player:
		return
	has_won = true
	player.win()
	interaction_prompt.hide()
	nearby_relays.clear()
	nearby_relay = null
	win_message.show()

func _setup_input_actions() -> void:
	_add_action("move_left", [KEY_A, KEY_LEFT], JOY_AXIS_LEFT_X, -1.0)
	_add_action("move_right", [KEY_D, KEY_RIGHT], JOY_AXIS_LEFT_X, 1.0)
	_add_action("move_up", [KEY_W, KEY_UP], JOY_AXIS_LEFT_Y, -1.0)
	_add_action("move_down", [KEY_S, KEY_DOWN], JOY_AXIS_LEFT_Y, 1.0)
	if not InputMap.has_action("interact"):
		InputMap.add_action("interact")
	var interact_key := InputEventKey.new()
	interact_key.keycode = KEY_E
	InputMap.action_add_event("interact", interact_key)
	var interact_button := InputEventJoypadButton.new()
	interact_button.button_index = JOY_BUTTON_A
	InputMap.action_add_event("interact", interact_button)

func _add_action(action_name: StringName, keys: Array[int], axis: JoyAxis, axis_value: float) -> void:
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)
	for key in keys:
		var key_event := InputEventKey.new()
		key_event.keycode = key
		InputMap.action_add_event(action_name, key_event)
	var joy_event := InputEventJoypadMotion.new()
	joy_event.axis = axis
	joy_event.axis_value = axis_value
	InputMap.action_add_event(action_name, joy_event)


func _add_maze_wall_collisions() -> void:
	var cell_size := maze.tile_set.tile_size
	var wall_shape := RectangleShape2D.new()
	wall_shape.size = Vector2(cell_size.x, cell_size.y)

	for cell in maze.get_used_cells():
		var wall_body := StaticBody2D.new()
		wall_body.position = maze.map_to_local(cell)
		wall_body.collision_layer = 1
		wall_body.collision_mask = 1
		maze.add_child(wall_body)

		var collision_shape := CollisionShape2D.new()
		collision_shape.shape = wall_shape
		wall_body.add_child(collision_shape)
