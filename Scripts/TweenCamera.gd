class_name TweenCamera
extends Camera2D

@export var target: CharacterBody2D

func _process(_delta) -> void:
	if target:
		global_position.x = lerpf(target.global_position.x, get_global_mouse_position().x, 0.20)
		global_position.y = lerpf(target.global_position.y, get_global_mouse_position().y, 0.20)
