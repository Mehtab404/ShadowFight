class_name DamageCalculator
extends RefCounted

## Calculates combat damage following the Shadow Ronin scaling blueprint:
## D_final = D_base * M_zone * max(0.3, 1.0 - 0.1 * (C - 1))

enum HitZone {
	HEAD,
	TORSO,
	LEGS
}

const ZONE_MULTIPLIERS = {
	HitZone.HEAD: 1.5,
	HitZone.TORSO: 1.0,
	HitZone.LEGS: 0.8
}

const MIN_COMBO_SCALING: float = 0.3
const COMBO_DECAY_RATE: float = 0.1

static func get_zone_multiplier(zone: HitZone) -> float:
	return ZONE_MULTIPLIERS.get(zone, 1.0)

static func calculate_combo_scaling(combo_count: int) -> float:
	if combo_count <= 1:
		return 1.0
	var scaling = 1.0 - COMBO_DECAY_RATE * float(combo_count - 1)
	return maxf(MIN_COMBO_SCALING, scaling)

static func calculate_final_damage(base_damage: float, zone: HitZone, combo_count: int) -> float:
	var zone_mult = get_zone_multiplier(zone)
	var combo_scale = calculate_combo_scaling(combo_count)
	var final_damage = base_damage * zone_mult * combo_scale
	return maxf(1.0, snappedf(final_damage, 0.1))
