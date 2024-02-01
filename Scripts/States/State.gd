class_name State
extends Node

signal transition(state: State, new_state_name: String)
@export var next_state: String = "WanderState"
@export var state_can_shoot: bool = false

func Enter():
	pass

func Exit():
	pass

func Update(_delta: float):
	pass

func Physics_Update(_delta: float):
	pass
