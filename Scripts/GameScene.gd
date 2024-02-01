class_name GameScene
extends Node

@onready var fallthrough: Camera2D = $FallthroughCamera

func _ready() -> void:
	SignalBus.game_over.connect(reposition_fallthrough_camera)

func reposition_fallthrough_camera(player_death_pos: Vector2) -> void:
	fallthrough.global_position = player_death_pos
