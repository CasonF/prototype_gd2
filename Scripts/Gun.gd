class_name Gun
extends Sprite2D

@export var bullet : PackedScene
@onready var cooldown : Timer = $CooldownTimer

# Named Components
@onready var muzzle : Sprite2D = $MuzzleComponent #Show only for debug
var muzzle_flipped : bool = false

@onready var perimeter : PerimeterNode = $PerimeterNode
# @onready var hitbox : HitboxComponent = $HitboxComponent

@export var force : float = 200.0

@export_category("Shooting Properties")
@export var projectiles_to_shoot : int = 1
@export var projectile_spread : float = 0.1

@export_category("Inverse Properties")
@export var additional_projectile_use_inverse_props : bool = false
@export var every_other_projectile_use_inverse_props : bool = false
@export var use_inverse_color : bool = true
@export var use_random_color_inversion : bool = false
var inverse_bullet_props : bool = false

func _process(_delta) -> void:
	follow_mouse_position()
	get_inputs()

func follow_mouse_position() -> void:
	look_at(get_global_mouse_position())
	check_direction()
	if perimeter:
		move_within_perimeter()

func check_direction() -> void:
	# Rotation degrees will keep going... Don't know of a way to check modulo on float
	if abs(rotation_degrees) > 360:
		if rotation_degrees > 0:
			rotation_degrees -= 360
		else:
			rotation_degrees += 360
		
	if abs(rotation_degrees) > 90.0 and abs(rotation_degrees) < 270.0:
		flip_v = true
		flip_muzzle(flip_v)
	else:
		flip_v = false
		flip_muzzle(flip_v)
		
	if rotation_degrees > 180 and rotation_degrees < 360.0:
		show_behind_parent = true
	elif rotation_degrees < 0 and rotation_degrees > -180.0:
		show_behind_parent = true
	else:
		show_behind_parent = false

func move_within_perimeter() -> void:
	var mouse: Vector2 = get_global_mouse_position()
	var global_max: float = perimeter.max_vector_distance
	var local_max: float = perimeter.max_distance_from_parent
	
	var difference: Vector2 = mouse - global_position
	var diff_x: float = clampf(difference.x, -global_max, global_max)
	var diff_y: float = clampf(difference.y, -global_max, global_max)
	position = Vector2((diff_x / global_max) * local_max, (diff_y / global_max) * local_max)

func flip_muzzle(flip: bool) -> void:
	if flip:
		if !muzzle_flipped:
			muzzle.position.y = -muzzle.position.y
			muzzle_flipped = true
	else:
		if muzzle_flipped:
			muzzle.position.y = -muzzle.position.y
			muzzle_flipped = false

func get_inputs() -> void:
	if Input.is_action_pressed("shoot") and cooldown.is_stopped():
		shoot()

func shoot() -> void:
	var direction = get_vector_to_mouse()
	for i in projectiles_to_shoot:
		create_bullet(direction)
	cooldown.start(cooldown.wait_time)

func get_vector_to_mouse() -> Vector2:
	var dir = get_global_mouse_position() - global_position
	return dir.normalized()

func create_bullet(direction: Vector2) -> void:
	var b : Bullet = bullet.instantiate()
	b.layer = get_parent_collision()
	b.global_position = muzzle.global_position
	b.direction = direction
	b.direction.y += direction.y * projectile_spread * randf_range(-1.0, 1.0)
	b.direction.x += direction.x * projectile_spread * randf_range(-1.0, 1.0)
	b.speed = force
	b.use_inverse_color = check_use_random_color(true) # Only randomizes color via random number
	if every_other_projectile_use_inverse_props:
		if inverse_bullet_props:
			b.use_inverse_color = check_use_random_color()
			b.use_inverse_wave = true
		inverse_bullet_props = !inverse_bullet_props
	if additional_projectile_use_inverse_props:
		create_bullet_inverse_props(b)
	get_tree().root.add_child(b)

func create_bullet_inverse_props(b1: Bullet) -> void:
	var b : Bullet = bullet.instantiate()
	b.layer = get_parent_collision()
	b.global_position = muzzle.global_position
	b.direction = b1.direction
	b.speed = force
	b.use_inverse_color = check_use_random_color()
	b.use_inverse_wave = true
	get_tree().root.add_child(b)

func check_use_random_color(ignore_regular_inversion: bool = false) -> bool:
	var invert : bool = false
	if use_inverse_color or use_random_color_inversion:
		if use_random_color_inversion:
			var rand: int = randi_range(0,1)
			invert = bool(rand)
		elif !ignore_regular_inversion:
			invert = use_inverse_color
	return invert

func get_parent_collision() -> int:
	var parent_layer = 1
	var parent = get_parent()
	if parent is CharacterBody2D:
		parent_layer = parent.collision_layer
	return parent_layer
