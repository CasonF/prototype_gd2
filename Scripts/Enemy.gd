class_name Enemy
extends CharacterBody2D

@onready var health_component : HealthComponent = $HealthComponent
@onready var fov_component: FOVComponent = $FOVComponent

@onready var navigation: NavigationAgent2D = $NavigationAgent2D
@onready var state_machine: StateMachine = $StateMachine

@export var bullet: PackedScene
@onready var muzzle := $MuzzleComponent

@export_category("Shooting Properties")
@export var force : float = 200.0
@export var projectiles_to_shoot : int = 1
@export var projectile_spread : float = 0.1

@export_category("Inverse Properties")
@export var additional_projectile_use_inverse_props : bool = false
@export var every_other_projectile_use_inverse_props : bool = false
@export var use_inverse_color : bool = true
@export var use_random_color_inversion : bool = false
var inverse_bullet_props : bool = false

var setup_enemy_dependencies: bool = false
var dependency_count: int = 3

func _ready() -> void:
	connect_signals()
	setup_enemy_dependencies = true

func _process(_delta: float) -> void:
	move_and_slide()
	if setup_enemy_dependencies:
		setup_dependencies()

func connect_signals() -> void:
	if health_component:
		health_component.at_zero_hp.connect(kill)
	if state_machine:
		state_machine.shoot_at.connect(shoot)

func setup_dependencies() -> void:
	var dependencies = 0
	if state_machine:
		if fov_component:
			state_machine.FOV = fov_component
			dependencies += 1
		if navigation:
			state_machine.navigator = navigation
			dependencies += 1
		state_machine.parent_body = self
		dependencies += 1
	
	if dependencies == dependency_count:
		setup_enemy_dependencies = false

func kill() -> void:
	#Add animations and stuff for on-death here...
	queue_free()

func shoot(direction: Vector2) -> void:
	for i in projectiles_to_shoot:
		create_bullet(direction)

func create_bullet(direction: Vector2) -> void:
	var b : Bullet = bullet.instantiate()
	b.layer = collision_layer
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
	b.layer = collision_layer
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
