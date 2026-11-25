class_name State
extends Node

var fighter: CharacterBody2D
var state_machine: StateMachine

func enter(_params: Dictionary = {}) -> void:
	pass

func exit() -> void:
	pass

func physics_update(_delta: float) -> void:
	pass

func update(_delta: float) -> void:
	pass

func handle_input(_event: InputEvent) -> void:
	pass
