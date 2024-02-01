class_name HealthComponent
extends Node

signal at_zero_hp

@export var max_hp : int = 20
var hp : int

func _ready() -> void:
	hp = max_hp

func damage(amount: int) -> void:
	if amount > hp:
		hp = 0
		at_zero_hp.emit()
	else:
		hp -= amount
	print("Took damage. Current HP: ", hp)

func heal(amount: int) -> void:
	if (amount + hp) > max_hp:
		hp = max_hp
	else:
		hp += amount
