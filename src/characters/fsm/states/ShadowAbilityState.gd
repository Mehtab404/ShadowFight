class_name ShadowAbilityState
extends State

## ShadowAbilityState: Iconic Shadow Fight 2 Super Move.
## Includes dark screen eclipse, invulnerable dash-through strike,
## multi-hit phantom slashes, and cinematic sheathe impact.

enum Phase { ECLIPSE, DASH_STRIKE, PHANTOM_SLASHES, FINISHER }

var current_phase: Phase = Phase.ECLIPSE
var phase_timer: float = 0.0
var opponent_ref: Fighter = null

func enter(_params: Dictionary = {}) -> void:
	fighter.set_invulnerable(true)
	current_phase = Phase.ECLIPSE
	phase_timer = 0.35
	fighter.velocity = Vector2.ZERO
	opponent_ref = fighter.opponent
	
	HitstopManager.trigger_hitstop(12, 8.0)
	AudioManager.play_kiai_shout(false)
	
	# Glow violet shadow aura
	if fighter.visual_root != null:
		fighter.modulate = Color(1.8, 0.4, 2.2, 1.0)
		var tween = fighter.create_tween()
		tween.tween_property(fighter.visual_root, "scale:y", 1.2, 0.15)
		tween.tween_property(fighter.visual_root, "scale:y", 1.0, 0.15)

func physics_update(delta: float) -> void:
	phase_timer -= delta
	
	match current_phase:
		Phase.ECLIPSE:
			if phase_timer <= 0.0:
				# Enter Dash Strike
				current_phase = Phase.DASH_STRIKE
				phase_timer = 0.22
				fighter.velocity.x = 920.0 * fighter.facing_direction
				AudioManager.play_blade_slash(1.5)
				HitSparks.spawn_at(fighter.get_parent(), fighter.global_position + Vector2(0, -60), true)
		Phase.DASH_STRIKE:
			fighter.move_and_slide()
			if phase_timer <= 0.0:
				# Crossed through opponent, turn and trigger multi-slashes
				current_phase = Phase.PHANTOM_SLASHES
				phase_timer = 0.45
				fighter.velocity = Vector2.ZERO
				fighter.facing_direction = -fighter.facing_direction
				fighter.visual_root.scale.x = float(fighter.facing_direction)
				
				# Deal heavy unblockable damage to opponent
				if opponent_ref != null and opponent_ref.health > 0:
					HitSparks.spawn_at(fighter.get_parent(), opponent_ref.global_position + Vector2(0, -60), true)
					AudioManager.play_blade_slash(1.2)
					opponent_ref.take_hit(fighter.weapon_hitbox, DamageCalculator.HitZone.TORSO)
		Phase.PHANTOM_SLASHES:
			if phase_timer <= 0.0:
				current_phase = Phase.FINISHER
				phase_timer = 0.30
				# Blade click impact
				AudioManager.play_block_clang(1.8)
				HitstopManager.trigger_hitstop(10, 14.0)
				if opponent_ref != null and opponent_ref.health > 0:
					opponent_ref.take_hit(fighter.weapon_hitbox, DamageCalculator.HitZone.HEAD)
		Phase.FINISHER:
			if phase_timer <= 0.0:
				state_machine.change_state("idle")

func exit() -> void:
	fighter.set_invulnerable(false)
	fighter.modulate = Color(1.0, 1.0, 1.0, 1.0)
