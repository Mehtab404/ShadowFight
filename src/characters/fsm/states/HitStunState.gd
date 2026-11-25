class_name HitStunState
extends State

var stun_duration: float = 0.35
var knockback_velocity: Vector2 = Vector2.ZERO

func enter(params: Dictionary = {}) -> void:
	stun_duration = params.get("duration", 0.35)
	knockback_velocity = params.get("knockback", Vector2(-150, -30))
	fighter.velocity = knockback_velocity
	
	if fighter.has_method("play_animation"):
		var zone = params.get("zone", DamageCalculator.HitZone.TORSO)
		if zone == DamageCalculator.HitZone.HEAD:
			fighter.play_animation("hit_head")
		elif zone == DamageCalculator.HitZone.LEGS:
			fighter.play_animation("hit_low")
		else:
			fighter.play_animation("hit_torso")
			
	if fighter.has_method("flash_hit_effect"):
		fighter.flash_hit_effect()

func physics_update(delta: float) -> void:
	fighter.apply_gravity(delta)
	fighter.velocity.x = move_toward(fighter.velocity.x, 0.0, 450.0 * delta)
	fighter.move_and_slide()
	
	stun_duration -= delta
	if stun_duration <= 0.0 and fighter.is_on_floor():
		fighter.reset_combo()
		state_machine.change_state("idle")
