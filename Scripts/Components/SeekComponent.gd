class_name SeekComponent
extends Node

@export_range(-2.0, 2.0) var seek_strength: float = 0
@export var max_seek_distance: float = 150.0
# Though we should only give this power to players, added layer in case we expand later
# @export var target_layer: int = 2
##This variable determines whether bullets seek more strongly closer or further away from the target.
@export_enum("Grow", "Shrink") var seek_approach_growth_type : int = 0
@export_range(-1.0, 1.0) var seek_approach_growth: float = 0
@export var limited_seek_time: bool = false
@export var initial_seek_delay: bool = false
@export var always_seek_closest: bool = true

@onready var seek_timer: Timer = $SeekTimer

var direction : Vector2
var seek_vector : Vector2
var time_airborne : float = 0
var seek_weight: float = 0
@export_range(0, 1) var min_seek_weight : float = 0.0
@export_range(0, 1) var max_seek_weight : float = 1.0

var last_target : Enemy

func _ready() -> void:
	if limited_seek_time or initial_seek_delay:
		seek_timer.start()

func _process(delta) -> void:
	if !direction:
		print_debug("Direction not set yet...")
		return
	elif !seek_vector:
		seek_vector = direction
	
	handle_movement(delta)

func handle_movement(_delta: float) -> void:
	var target_position = find_nearest_enemy_in_direction()
	seek_weight = get_seek_weight(target_position)
	if initial_seek_delay:
		if seek_timer.is_stopped():
			initial_seek_delay = false
			seek_timer.start() if limited_seek_time else seek_timer.stop()
	else:
		if limited_seek_time:
			if !seek_timer.is_stopped():
				seek_vector = target_position.normalized()
		else:
			seek_vector = target_position.normalized()

func get_seek_weight(target_position: Vector2) -> float:
	var weight: float = 0.1
	match seek_approach_growth_type:
		0: weight = clampf(target_position.distance_to(get_parent().global_position), 1, 500) / max_seek_distance
		1: weight = 1 - (clampf(target_position.distance_to(get_parent().global_position), 1, 500) / max_seek_distance)
	return (weight + ((weight/3) * seek_approach_growth)) * seek_strength

func find_nearest_enemy_in_direction() -> Vector2:
	var target_position := seek_vector
	var scene := get_tree().root.find_child("GameScene", true, false)
	if scene:
		target_position = evaluate_nearest(scene.get_children())
	return target_position

func evaluate_nearest(children: Array[Node]) -> Vector2:
	var seek_direction: Vector2 = seek_vector
	var angle_to_position: float = 60
	var last_distance: float = max_seek_distance
	for child in children:
		if child is Enemy: # We probably will not give seeking to enemies... that feels rude
			var distance: float = child.global_position.distance_to(get_parent().global_position)
			var angle_to_target: float = get_angle_sub_360(seek_direction, get_parent().global_position.direction_to(child.global_position))
			if (angle_to_target <= angle_to_position) and (distance <= max_seek_distance):
				last_target = child
				if always_seek_closest and distance < last_distance:
					angle_to_position = angle_to_target
					seek_direction = get_parent().global_position.direction_to(child.global_position)
					last_distance = distance
				else:
					angle_to_position = angle_to_target
					seek_direction = get_parent().global_position.direction_to(child.global_position)
	return seek_direction

func get_angle_sub_360(pos1: Vector2, pos2: Vector2) -> float:
	var angle: float = 0
	var initial_angle : float = pos1.angle_to(pos2)
	#print("Initial Angle: ", rad_to_deg(initial_angle))
	if abs(rad_to_deg(initial_angle)) >= 360.0:
		var d : int = int(abs(initial_angle)) / 360
		if initial_angle < 0:
			angle = rad_to_deg(abs(initial_angle) + (360.0 * float(d)))
		else:
			angle = rad_to_deg(abs(initial_angle) - (360.0 * float(d)))
	else:
		angle = rad_to_deg(abs(initial_angle))
	#print("Angle: ", angle)
	return angle
