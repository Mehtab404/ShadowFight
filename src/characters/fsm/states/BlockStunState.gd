class_name BlockStunState
extends State

var stun_duration: float = 0.20
var pushback_speed: float = 80.0

func enter(params: Dictionary = {}) -> void:
	stun_duration = params.get("duration", 0.20)
	var attacker_facing = params.get("attacker_facing", 1)
	fighter.velocity.x = attacker_facing * pushback_speed
	
	if fighter.has_method("play_animation"):
		fighter.play_animation("block")
		
	AudioManager.play_block_clang()

func physics_update(delta: float) -> void:
	fighter.apply_gravity(delta)
	fighter.velocity.x = move_toward(fighter.velocity.x, 0.0, 350.0 * delta)
	fighter.move_and_slide()
	
	stun_duration -= delta
	if stun_duration <= 0.0:
		if fighter.is_holding_block():
			pass
		elif fighter.get_movement_input() != 0.0:
			state_machine.change_state("move")
		else:
			state_machine.change_state("idle")
