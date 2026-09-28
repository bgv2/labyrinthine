extends CharacterBody2D
class_name PlayerController

@export var move_speed: float = 200.0
@export_range(0.0, 1.0, 0.01) var dimmed_light_ratio: float = 0.20

@onready var player_light: PointLight2D = $PointLight2D

var original_light_energy: float
var has_light: bool = true
var has_won: bool = false

func _ready() -> void:
	original_light_energy = player_light.energy

func _physics_process(_delta: float) -> void:
	if has_won:
		velocity = Vector2.ZERO
		return

	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * move_speed
	move_and_slide()

func dim_light() -> void:
	has_light = false
	player_light.energy = original_light_energy * dimmed_light_ratio

func restore_light() -> void:
	has_light = true
	player_light.energy = original_light_energy

func win() -> void:
	has_won = true
	velocity = Vector2.ZERO
