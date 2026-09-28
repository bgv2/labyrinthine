extends CharacterBody2D
class_name PlayerController

@export var move_speed: float = 200.0
@export_range(0.0, 1.0, 0.01) var dimmed_light_ratio: float = 0.20
@export_range(0.0, 0.2, 0.01) var light_pulse_amount: float = 0.06
@export_range(0.05, 2.0, 0.05) var light_pulse_frequency: float = 0.35
@export_range(0.1, 3.0, 0.1) var light_transition_duration: float = 0.8

@onready var player_light: PointLight2D = $PointLight2D

var original_light_energy: float
var original_light_texture_scale: float
var light_pulse_time: float = 0.0
var light_energy_tween: Tween
var has_light: bool = true
var has_won: bool = false

func _ready() -> void:
	original_light_energy = player_light.energy
	original_light_texture_scale = player_light.texture_scale

func _process(delta: float) -> void:
	light_pulse_time += delta * TAU * light_pulse_frequency
	var pulse := sin(light_pulse_time) * light_pulse_amount
	player_light.texture_scale = original_light_texture_scale * (1.0 + pulse)

func _physics_process(_delta: float) -> void:
	if has_won:
		velocity = Vector2.ZERO
		return

	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * move_speed
	move_and_slide()

func dim_light() -> void:
	if not has_light:
		return
	has_light = false
	_animate_light_energy(original_light_energy * dimmed_light_ratio)

func restore_light() -> void:
	if has_light:
		return
	has_light = true
	_animate_light_energy(original_light_energy)

func _animate_light_energy(target_energy: float) -> void:
	if light_energy_tween != null and light_energy_tween.is_running():
		light_energy_tween.kill()
	light_energy_tween = create_tween()
	light_energy_tween.set_trans(Tween.TRANS_SINE)
	light_energy_tween.set_ease(Tween.EASE_IN_OUT)
	light_energy_tween.tween_property(player_light, "energy", target_energy, light_transition_duration)

func win() -> void:
	has_won = true
	velocity = Vector2.ZERO
