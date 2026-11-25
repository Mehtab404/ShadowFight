class_name AttackState
extends State

## AttackState controls the 3-phase fighting game attack lifecycle:
## 1. Startup: Anticipation frames before hitbox activates
## 2. Active: Hitbox is enabled and checks for collisions
## 3. Recovery: Follow-through frames where the fighter is punishable

enum AttackPhase { STARTUP, ACTIVE, RECOVERY }

var current_phase: AttackPhase = AttackPhase.STARTUP
var startup_timer: float = 0.0
var active_timer: float = 0.0
var recovery_timer: float = 0.0

var current_move_data: Dictionary = {}
var active_hitbox: Hitbox = null

func enter(params: Dictionary = {}) -> void:
	current_move_data = params
	current_phase = AttackPhase.STARTUP
	
	var startup_f = current_move_data.get("startup_f", 6)
	var active_f = current_move_data.get("active_f", 3)
	var recovery_f = current_move_data.get("recovery_f", 8)
	
	startup_timer = float(startup_f) / 60.0
	active_timer = float(active_f) / 60.0
	recovery_timer = float(recovery_f) / 60.0
	
	var forward_step = current_move_data.get("forward_step", 60.0)
	fighter.velocity.x = forward_step * fighter.facing_direction
	
	var anim_name = current_move_data.get("anim", "punch")
	if fighter.has_method("play_animation"):
		fighter.play_animation(anim_name)
		
	AudioManager.play_whoosh()

func physics_update(delta: float) -> void:
	fighter.apply_gravity(delta)
	fighter.velocity.x = move_toward(fighter.velocity.x, 0.0, 300.0 * delta)
	fighter.move_and_slide()
	
	match current_phase:
		AttackPhase.STARTUP:
			startup_timer -= delta
			if startup_timer <= 0.0:
				_enter_active_phase()
		AttackPhase.ACTIVE:
			active_timer -= delta
			if active_timer <= 0.0:
				_enter_recovery_phase()
		AttackPhase.RECOVERY:
			recovery_timer -= delta
			if recovery_timer <= 0.0:
				_finish_attack()

func _enter_active_phase() -> void:
	current_phase = AttackPhase.ACTIVE
	var hitbox_node_name = current_move_data.get("hitbox_name", "PunchHitbox")
	active_hitbox = fighter.get_node_or_null(hitbox_node_name)
	if active_hitbox != null:
		active_hitbox.base_damage = current_move_data.get("damage", 15.0)
		active_hitbox.target_zone = current_move_data.get("target_zone", DamageCalculator.HitZone.TORSO)
		active_hitbox.is_knockdown = current_move_data.get("is_knockdown", false)
		active_hitbox.knockback = current_move_data.get("knockback", Vector2(180, -60))
		active_hitbox.activate()

func _enter_recovery_phase() -> void:
	current_phase = AttackPhase.RECOVERY
	if active_hitbox != null:
		active_hitbox.deactivate()
		active_hitbox = null

func _finish_attack() -> void:
	if active_hitbox != null:
		active_hitbox.deactivate()
		active_hitbox = null
		
	if fighter.is_crouch_requested():
		state_machine.change_state("crouch")
	elif fighter.get_movement_input() != 0.0:
		state_machine.change_state("move")
	else:
		state_machine.change_state("idle")

func exit() -> void:
	if active_hitbox != null:
		active_hitbox.deactivate()
		active_hitbox = null
