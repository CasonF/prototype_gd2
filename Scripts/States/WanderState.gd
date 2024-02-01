class_name WanderState
extends State

@export var character: Enemy
@export var move_speed: float = 10.0

@export var min_wander_time: float = 1.5
@export var max_wander_time: float = 5.0

@export var min_think_time: float = 1.0
@export var max_think_time: float = 1.5

var move_direction: Vector2
var wander_time: float
var think_time: float

func randomize_wander() -> void:
	move_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	wander_time = randf_range(min_wander_time, max_wander_time)

func _ready() -> void:
	pass

func get_character_body() -> void:
	if get_parent().parent_body is CharacterBody2D:
		character = get_parent().parent_body

func Enter() -> void:
	randomize_wander()

func Update(delta: float) -> void:
	if !character:
		get_character_body()
		return
	
	check_fov()
	
	if wander_time > 0:
		wander_time -= delta
	elif think_time > 0:
		think_time -= delta
	else:
		think_time = randf_range(min_think_time, max_think_time)
		randomize_wander()
	
	if character:
		if wander_time > 0:
			character.velocity = move_direction * move_speed
		elif think_time > 0:
			character.velocity = Vector2.ZERO

func check_fov() -> void:
	if get_parent().FOV.has_line_of_sight and !get_parent().FOV.checked_pos:
		transition.emit(self, "FollowState")
