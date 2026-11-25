class_name Hitbox
extends Area2D

signal hit_landed(hurtbox: Hurtbox)

@export var base_damage: float = 15.0
@export var target_zone: DamageCalculator.HitZone = DamageCalculator.HitZone.TORSO
@export var knockback: Vector2 = Vector2(180, -60)
@export var hitstop_frames: int = 5
@export var hit_stun_duration: float = 0.35
@export var block_stun_duration: float = 0.20
@export var is_knockdown: bool = false
@export var is_unblockable: bool = false

var attacker: CharacterBody2D = null
var already_hit_fighters: Array[CharacterBody2D] = []

func _ready() -> void:
	attacker = _find_fighter_owner()
	monitoring = false
	monitorable = false
	area_entered.connect(_on_area_entered)

func _find_fighter_owner() -> CharacterBody2D:
	var curr = get_parent()
	while curr != null:
		if curr is CharacterBody2D:
			return curr
		curr = curr.get_parent()
	return null

func activate() -> void:
	already_hit_fighters.clear()
	monitoring = true
	monitorable = true

func deactivate() -> void:
	monitoring = false
	monitorable = false
	already_hit_fighters.clear()

func _on_area_entered(area: Area2D) -> void:
	if not monitoring:
		return
	if area is Hurtbox:
		var hurtbox: Hurtbox = area
		var target_fighter = hurtbox.fighter
		if target_fighter != null and target_fighter != attacker:
			if not already_hit_fighters.has(target_fighter):
				already_hit_fighters.append(target_fighter)
				hurtbox.take_damage_from(self)
				hit_landed.emit(hurtbox)
