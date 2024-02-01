class_name Player
extends CharacterBody2D

@onready var active_gun : Gun = $Gun

# Named Components
@onready var hitbox_component : HitboxComponent = $HitboxComponent
@onready var health_component : HealthComponent = $HealthComponent

@export var speed: float = 350.0

@onready var camera: TweenCamera = $TweenCamera

func _ready() -> void:
	connect_signals()

func connect_signals() -> void:
	if health_component:
		health_component.at_zero_hp.connect(player_ko)

func _process(_delta) -> void:
	get_inputs()
	move_and_slide()

func get_inputs() -> void:
	var direction = Input.get_vector("left", "right", "up", "down")
	velocity = direction * speed

func player_ko() -> void:
	# We pass in player camera pos instead of player pos because it's less jarring...
	SignalBus.game_over.emit(camera.global_position)
	queue_free()
