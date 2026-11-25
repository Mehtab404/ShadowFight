class_name DamageNumber
extends Node2D

@onready var label: Label = $Label

func _ready() -> void:
	var tween = create_tween().set_parallel(true)
	var target_pos = position + Vector2(randf_range(-15, 15), -45)
	tween.tween_property(self, "position", target_pos, 0.55).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate:a", 0.0, 0.55).set_delay(0.15)
	await tween.finished
	queue_free()

static func spawn(parent: Node, spawn_pos: Vector2, amount: float, is_head: bool, is_block: bool) -> void:
	var scene = preload("res://src/ui/DamageNumber.tscn")
	var instance: DamageNumber = scene.instantiate()
	instance.position = spawn_pos
	parent.add_child(instance)
	
	var lbl = instance.get_node("Label") as Label
	lbl.text = str(int(amount))
	if is_block:
		lbl.modulate = Color(0.4, 0.8, 1.0)
		lbl.text = "🛡️ " + lbl.text
	elif is_head:
		lbl.modulate = Color(1.0, 0.25, 0.25)
		lbl.text = "CRIT " + lbl.text
	else:
		lbl.modulate = Color(1.0, 0.9, 0.4)
