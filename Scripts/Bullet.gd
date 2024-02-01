class_name Bullet
extends Area2D

@onready var lifespan : Timer = $LifespanComponent
@onready var sprite : Sprite2D = $Sprite2D
@onready var glow : PointLight2D = $PointLight2D
# Named Components
@onready var hitbox_component : CollisionShape2D = $HitboxComponent
var wave_component : WaveComponent
var use_inverse_wave : bool = false
var seek_component : SeekComponent

@export var bullet_size : float = 1
@export var damage : int = 3

@export_category("Color")
@export var color : Color = Color("c98e00")
@export var inverse_color : Color = Color("00a9df")
var use_inverse_color : bool = true

var direction : Vector2
var last_direction : Vector2
var speed : float = 200.0
var layer : int = 1
var time_airborne : float = 0

func check_inverse_props() -> void:
	if wave_component and use_inverse_wave:
		if wave_component.is_inverse:
			wave_component.is_inverse = false
		else:
			wave_component.is_inverse = true
	
	if use_inverse_color:
				color = inverse_color

func _ready() -> void:
	setup_component()
	sprite.apply_scale(Vector2(bullet_size, bullet_size))
	hitbox_component.apply_scale(Vector2(bullet_size, bullet_size))
	global_rotation = direction.angle()
	collision_mask = assign_layer() # Set bullet's collision_mask to not hit its parent
	check_inverse_props()
	# Do these after inversing props...
	sprite.self_modulate = color
	glow.self_modulate = color

func _process(delta) -> void:
	time_airborne += delta
	check_lifespan()
	check_collisions()
	#check_rotation()
	move(delta)

func setup_component() -> void:
	if has_node("WaveComponent"):
		wave_component = $WaveComponent
		wave_component.direction = direction
	if has_node("SeekComponent"):
		seek_component = $SeekComponent
		seek_component.direction = direction

func check_lifespan() -> void:
	if lifespan.is_stopped():
		queue_free()

func check_collisions() -> void:
	if has_overlapping_bodies():
		for bod in get_overlapping_bodies():
			if bod.has_node("HitboxComponent"):
				bod.get_node("HitboxComponent").damage(damage)
				break
		queue_free()

# TODO: Need to spend more time to resolve rotation
func check_rotation(_x: float, _y: float) -> void:
	look_at(Vector2(global_position.x + _x, global_position.y + _y))

func move(delta) -> void:
	var wave_vector : Vector2 = get_wave_vector()
	var seek_vector : Vector2 = get_seek_vector()
	if direction and speed > 0:
		if seek_vector:
			do_seek_movement(wave_vector, seek_vector, delta)
		else:
			do_standard_movement(wave_vector, delta)

func get_wave_vector() -> Vector2:
	var vector: Vector2 = Vector2.ZERO
	if wave_component and direction:
		vector = wave_component.wave_vector
	return vector

func get_seek_vector() -> Vector2:
	var vector: Vector2 = Vector2.ZERO
	if seek_component and direction:
		vector = seek_component.seek_vector
	return vector

func assign_layer() -> int:
	var target_layer: int = 1
	match layer:
		1: target_layer = 2
		2: target_layer = 1
	return target_layer

func do_seek_movement(wave_vector: Vector2, seek_vector: Vector2, delta: float) -> void:
	var new_dir_x : float = lerpf(direction.x, seek_vector.x, clampf(seek_component.seek_weight, seek_component.min_seek_weight, seek_component.max_seek_weight))
	var new_dir_y : float = lerpf(direction.y, seek_vector.y, clampf(seek_component.seek_weight, seek_component.min_seek_weight, seek_component.max_seek_weight))
	var delta_x : float = (new_dir_x * speed) * delta + wave_vector.x
	var delta_y : float = (new_dir_y * speed) * delta + wave_vector.y
	check_rotation(delta_x, delta_y)
	global_position.x += delta_x
	global_position.y += delta_y

func do_standard_movement(wave_vector: Vector2, delta: float) -> void:
	var delta_x : float = (direction.x * speed) * delta + wave_vector.x
	var delta_y : float = (direction.y * speed) * delta + wave_vector.y
	check_rotation(delta_x, delta_y)
	global_position.x += delta_x
	global_position.y += delta_y
