class_name JumpState
extends State

## JumpState: Realistic jump arc with apex hang and landing impact absorption.

@export var jump_impulse: float = -500.0
@export var horizontal_air_control: float = 160.0
@export var apex_gravity_scale: float = 0.65

var jump_direction: float = 0.0
var has_left_ground: bool = false

func enter(_params: Dictionary = {}) -> void:
	has_left_ground = false
	jump_direction = fighter.get_movement_input()
	fighter.velocity.y = jump_impulse
	fighter.velocity.x = jump_direction * horizontal_air_control
	
	# Slight jump liftoff stretch
	if fighter.visual_root != null:
		var tween = fighter.create_tween()
		tween.tween_property(fighter.visual_root, "scale:y", 1.15, 0.1)
		tween.tween_property(fighter.visual_root, "scale:y", 1.0, 0.2)
		
	if fighter.has_method("play_animation"):
		fighter.play_animation("jump")

func physics_update(delta: float) -> void:
	# Apex gravity modulation for martial arts float
	var grav_mult = 1.0
	if absf(fighter.velocity.y) < 60.0:
		grav_mult = apex_gravity_scale
		
	if not fighter.is_on_floor():
		has_left_ground = true
		fighter.velocity.y += fighter.gravity * grav_mult * delta
	else:
		if fighter.velocity.y > 0:
			fighter.velocity.y = 0.0
			
	fighter.move_and_slide()
	
	if has_left_ground and fighter.is_on_floor():
		# Landing impact cushion squash
		if fighter.visual_root != null:
			var tween = fighter.create_tween()
			tween.tween_property(fighter.visual_root, "scale:y", 0.82, 0.07)
			tween.tween_property(fighter.visual_root, "scale:y", 1.0, 0.12)
			
		if fighter.get_movement_input() != 0.0:
			state_machine.change_state("move")
		else:
			state_machine.change_state("idle")

func handle_input(_event: InputEvent) -> void:
	if fighter.check_attack_inputs(true):
		return
