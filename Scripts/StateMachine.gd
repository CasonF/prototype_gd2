class_name StateMachine
extends Node

@export var initial_state: State

var current_state: State
var states: Dictionary = {}

var FOV: FOVComponent
var parent_body: Enemy
var navigator: NavigationAgent2D

signal shoot_at(target_direction: Vector2)

func _ready() -> void:
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.transition.connect(on_child_transition)
			if child.state_can_shoot:
				child.shoot_at_target.connect(shoot)
	
	if initial_state:
		initial_state.Enter()
		current_state = initial_state

func _process(delta) -> void:
	if current_state:
		current_state.Update(delta)

func _physics_process(delta) -> void:
	if current_state:
		current_state.Physics_Update(delta)

func on_child_transition(state: State, new_state_name: String) -> void:
	print("Transitioning to new state: ", new_state_name)
	if state != current_state:
		return
	
	var new_state: State = states.get(new_state_name.to_lower())
	if !new_state:
		return
	
	if current_state:
		current_state.Exit()
	
	new_state.Enter()
	current_state = new_state

func shoot(target_direction: Vector2) -> void:
	shoot_at.emit(target_direction)
