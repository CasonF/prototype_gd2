class_name HitboxComponent
extends CollisionShape2D

@export var health_component : HealthComponent

func damage(amount: int) -> void:
	print("Hitbox - take damage: ", amount)
	if health_component:
		health_component.damage(amount)
	play_damage_animation()

func play_damage_animation() -> void:
	var animator : AnimationPlayer
	if get_parent().has_node("AnimationPlayer"):
		animator = get_parent().get_node("AnimationPlayer")
	if animator:
		animator.play("damaged")
