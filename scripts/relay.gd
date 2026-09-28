extends Area2D
class_name RelayController

signal player_entered(relay: RelayController)
signal player_left(relay: RelayController)

@export_range(0.0, 0.2, 0.01) var light_pulse_amount: float = 0.08
@export_range(0.05, 2.0, 0.05) var light_pulse_frequency: float = 0.3
@export_range(0.1, 3.0, 0.1) var light_transition_duration: float = 0.8

@onready var relay_light: PointLight2D = $PointLight2D

var is_active: bool = false
var player_in_range: bool = false
var original_light_texture_scale: float
var light_pulse_time: float = 0.0
var original_light_energy: float
var light_energy_tween: Tween

func _ready() -> void:
	original_light_energy = relay_light.energy
	relay_light.energy = 0.0
	relay_light.enabled = false
	original_light_texture_scale = relay_light.texture_scale
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _process(delta: float) -> void:
	if not is_active:
		return
	light_pulse_time += delta * TAU * light_pulse_frequency
	var pulse := sin(light_pulse_time) * light_pulse_amount
	relay_light.texture_scale = original_light_texture_scale * (1.0 + pulse)

func activate() -> void:
	if is_active:
		return
	is_active = true
	light_pulse_time = 0.0
	relay_light.texture_scale = original_light_texture_scale
	relay_light.enabled = true
	_animate_light_energy(original_light_energy)

func deactivate() -> void:
	if not is_active:
		return
	is_active = false
	relay_light.texture_scale = original_light_texture_scale
	_animate_light_energy(0.0)
	light_energy_tween.tween_callback(_finish_deactivation)

func _animate_light_energy(target_energy: float) -> void:
	if light_energy_tween != null and light_energy_tween.is_running():
		light_energy_tween.kill()
	light_energy_tween = create_tween()
	light_energy_tween.set_trans(Tween.TRANS_SINE)
	light_energy_tween.set_ease(Tween.EASE_IN_OUT)
	light_energy_tween.tween_property(relay_light, "energy", target_energy, light_transition_duration)

func _finish_deactivation() -> void:
	if not is_active:
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
