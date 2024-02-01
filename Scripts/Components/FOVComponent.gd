class_name FOVComponent
extends Area2D

@onready var los_timer : Timer = $LOSTimer

var has_line_of_sight: bool = false
var checked_pos: bool = false
var target: CharacterBody2D
var target_last_known_position: Vector2
@onready var line_of_sight: RayCast2D = $RayCast2D

func _ready() -> void:
	los_timer.start(los_timer.wait_time)

func _process(_delta) -> void:
	check_for_player()
	if target and los_timer.is_stopped():
		get_line_of_sight()

func check_for_player() -> void:
	if has_overlapping_bodies():
		for body in get_overlapping_bodies():
			if body is Player:
				target = body
				break
			else:
				target = null
	else:
		target = null

func get_line_of_sight() -> void:
	line_of_sight.look_at(target.position)
	if line_of_sight.get_collider() == target:
		target_last_known_position = target.global_position
		has_line_of_sight = true
		checked_pos = false
	else:
		has_line_of_sight = false
	los_timer.start(los_timer.wait_time)
