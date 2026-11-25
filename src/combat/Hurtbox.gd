class_name Hurtbox
extends Area2D

signal hit_registered(hitbox: Hitbox, zone: DamageCalculator.HitZone)

@export var zone: DamageCalculator.HitZone = DamageCalculator.HitZone.TORSO
@export var is_invulnerable: bool = false

var fighter: CharacterBody2D = null

func _ready() -> void:
	# Hurtbox monitors for overlapping hitboxes
	fighter = _find_fighter_owner()
	monitoring = true
	monitorable = true

func _find_fighter_owner() -> CharacterBody2D:
	var curr = get_parent()
	while curr != null:
		if curr is CharacterBody2D and curr.has_method("take_hit"):
			return curr
		curr = curr.get_parent()
	return null

func take_damage_from(hitbox: Hitbox) -> void:
	if is_invulnerable:
		return
	hit_registered.emit(hitbox, zone)
	if fighter != null:
		fighter.take_hit(hitbox, zone)
