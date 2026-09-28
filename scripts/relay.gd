extends Area2D
class_name RelayController

signal player_entered(relay: RelayController)
signal player_left(relay: RelayController)

@onready var relay_light: PointLight2D = $PointLight2D

var is_active: bool = false
var player_in_range: bool = false

func _ready() -> void:
	relay_light.enabled = false
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func activate() -> void:
	is_active = true
	relay_light.enabled = true

func deactivate() -> void:
	is_active = false
	relay_light.enabled = false

func _on_body_entered(body: Node2D) -> void:
	if not body is CharacterBody2D:
		return
	player_in_range = true
	player_entered.emit(self)

func _on_body_exited(body: Node2D) -> void:
	if not body is CharacterBody2D:
		return
	player_in_range = false
	player_left.emit(self)
