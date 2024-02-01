class_name FollowState
extends State

@export var character: Enemy
@export var move_speed: float = 35.0

@export var check_direction_timer: float = 0.2
var orig_check_direction_timer: float
var target_last_position: Vector2
@export var navigation_offset: float = 5.0

@export var preferred_distance: float = 40.0
@export var is_aggressive: bool = true
@export var lead_shot: bool = false
@export var attack_cooldown: float = 0.5
var orig_attack_cooldown: float

var move_direction: Vector2
var navigator: NavigationAgent2D

signal shoot_at_target(direction: Vector2)

func _ready() -> void:
	orig_check_direction_timer = check_direction_timer
	orig_attack_cooldown = attack_cooldown

func get_target_direction() -> void:
	if navigator:
		navigator.target_position = get_parent().FOV.target_last_known_position
	check_direction_timer = orig_check_direction_timer

func get_character_body() -> void:
	if get_parent().parent_body is CharacterBody2D:
		character = get_parent().parent_body

func get_navigation() -> void:
	if get_parent().navigator is NavigationAgent2D:
		navigator = get_parent().navigator
		get_target_direction()

func Enter() -> void:
	get_target_direction()

func Update(delta: float) -> void:
	if validate_setup():
		if check_direction_timer > 0:
			check_direction_timer -= delta
		else:
			target_last_position = navigator.target_position
			get_target_direction()
		
		if character:
			if navigator.distance_to_target() > preferred_distance:
				var next_pos = navigator.get_next_path_position()
				move_direction = character.global_position.direction_to(next_pos)
				character.global_position += move_direction.normalized() * move_speed * delta
				if get_parent().FOV.target and get_parent().FOV.has_line_of_sight and is_aggressive:
					shoot(delta)
			elif !get_parent().FOV.has_line_of_sight:
				get_parent().FOV.checked_pos = true
				transition.emit(self, "WanderState")
		else:
			transition.emit(self, "WanderState")

func shoot(delta: float) -> void:
	var shoot_target: Vector2 = character.global_position.direction_to(get_parent().FOV.target.global_position)
	if attack_cooldown > 0:
		if get_parent().FOV.has_line_of_sight:
			attack_cooldown -= delta
		else:
			attack_cooldown -= (delta / 10)
	else:
		if lead_shot and get_parent().FOV.has_line_of_sight:
			var move_diff: Vector2 = shoot_target - character.global_position.direction_to(target_last_position)
			shoot_target += move_diff
		shoot_at_target.emit(shoot_target.normalized())
		attack_cooldown = orig_attack_cooldown

func get_parent_collision() -> int:
	return character.collision_layer

func validate_setup() -> bool:
	if !character:
		get_character_body()
		return false
	if !navigator:
		get_navigation()
		return false
	return true
