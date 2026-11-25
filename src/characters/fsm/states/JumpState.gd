class_name JumpState
extends State

@export var jump_impulse: float = -520.0
@export var horizontal_air_control: float = 180.0

var jump_direction: float = 0.0

func enter(_params: Dictionary = {}) -> void:
	jump_direction = fighter.get_movement_input()
	fighter.velocity.y = jump_impulse
	fighter.velocity.x = jump_direction * horizontal_air_control
	if fighter.has_method("play_animation"):
		fighter.play_animation("jump")

func physics_update(delta: float) -> void:
	fighter.apply_gravity(delta)
	fighter.move_and_slide()
	
	if fighter.is_on_floor():
		if fighter.get_movement_input() != 0.0:
			state_machine.change_state("move")
		else:
			state_machine.change_state("idle")

func handle_input(_event: InputEvent) -> void:
	if fighter.check_attack_inputs(true):
		return
