class_name WaveComponent
extends Node

@export var amplitude : float = 20.0
@export var frequency : float = 1.0
@export var wave_speed : float = 10.0
@export var is_inverse : bool = false

var direction : Vector2 = Vector2.ZERO
var wave_vector : Vector2 = Vector2.ZERO
var time_airborne : float = 0

func _process(delta) -> void:
	time_airborne += delta
	if is_inverse:
		wave_vector = (direction.normalized().orthogonal() * -cos(time_airborne * wave_speed * frequency) * amplitude)
	else:
		wave_vector = (direction.normalized().orthogonal() * cos(time_airborne * wave_speed * frequency) * amplitude)
