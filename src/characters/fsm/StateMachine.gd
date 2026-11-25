class_name StateMachine
extends Node

signal state_changed(old_state_name: String, new_state_name: String)

@export var initial_state: State

var current_state: State
var states: Dictionary = {}
var fighter: CharacterBody2D

func init(owner_fighter: CharacterBody2D) -> void:
	fighter = owner_fighter
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.fighter = owner_fighter
			child.state_machine = self
			
	if initial_state != null:
		change_state(initial_state.name.to_lower())
	elif get_child_count() > 0 and get_child(0) is State:
		change_state(get_child(0).name.to_lower())

func change_state(new_state_name: String, params: Dictionary = {}) -> void:
	var key = new_state_name.to_lower()
	if not states.has(key):
		push_warning("StateMachine: Unknown state requested: " + new_state_name)
		return
		
	var old_name = ""
	if current_state != null:
		old_name = current_state.name
		current_state.exit()
		
	current_state = states[key]
	current_state.enter(params)
	state_changed.emit(old_name, current_state.name)

func physics_update(delta: float) -> void:
	if current_state != null:
		current_state.physics_update(delta)

func update(delta: float) -> void:
	if current_state != null:
		current_state.update(delta)

func handle_input(event: InputEvent) -> void:
	if current_state != null:
		current_state.handle_input(event)
