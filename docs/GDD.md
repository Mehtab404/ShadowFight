# 📜 Shadow Ronin — Game Design Document (GDD)

## 1. Executive Summary
* **Project Name:** Shadow Ronin (Working Title)
* **Genre:** 2D Physics-Driven Martial Arts Fighting Game
* **Target Platforms:** PC (Steam / Windows / Linux), Mobile (Android / iOS)
* **Inspiration:** *Shadow Fight 2*, *Bushido Blade*, *Tekken* (deliberate neutral pacing)
* **Engine:** Godot Engine 4.3+ (GDScript 2.0)

---

## 2. Core Pillars & Philosophy
1. **Silhouette Artistry:** Distinctive high-contrast black character silhouettes set against atmospheric multi-plane parallax environments. Every action must be immediately readable from silhouette contour alone.
2. **Weighted, Deliberate Combat:** High startup and recovery frames with substantial hitstop ensure strikes feel bone-crushing. Whiffing moves is heavily punishable.
3. **Organic Skeletal Motion:** Physics-assisted skeletal animation blending ragdoll dynamics upon K.O. or knockdown.
4. **Dynamic Neutral & Spacing:** Weapon reach, footsies, whiff punishing, and zone-based damage determine victor over button mashing.

---

## 3. Core Combat Systems

### 3.1 The Fighting Game Trinity (Collisions)
* **Pushbox:** `CharacterBody2D` boundary keeping fighters from occupying the same 2D coordinate space.
* **Hurtbox (`Area2D`):** Skeletally linked zones classified into:
  * `Head` (1.5x damage multiplier, heavy stagger, knockdown on heavy strikes)
  * `Torso` (1.0x damage multiplier, baseline stun)
  * `Legs` (0.8x damage multiplier, low sweep trip risk)
* **Hitbox (`Area2D`):** Generated during active strike frames containing:
  * Base damage
  * Zone targeting flags
  * Hitstop duration (3–8 frames)
  * Knockback impulse vector $(X, Y)$
  * Block stun duration

### 3.2 Finite State Machine (FSM)
Fighters transition strictly between states:
* `IDLE`: Neutral stance, auto-facing enemy.
* `MOVE_FORWARD` / `MOVE_BACKWARD`: Positional adjustment. Moving back triggers auto-blocking if in neutral.
* `JUMP`: Airborne state with launch and landing recovery.
* `CROUCH`: Low profile dodging high attacks, enabling low sweeps.
* `ATTACK`: Divided strictly into `Startup` -> `Active` -> `Recovery`.
* `BLOCK_STUN`: Guarding fighter absorbs reduced chip damage and pushed backward.
* `HIT_STUN`: Interrupted by enemy attack; unskippable frame window based on strike weight.
* `KNOCKDOWN` & `GET_UP`: Ground state with invincible get-up roll/recovery frames.

### 3.3 Damage & Combo Scaling Formula
To prevent infinite juggles and ensure comeback potential:
$$D_{\text{final}} = D_{\text{base}} \times M_{\text{zone}} \times \max\left(0.3, \; 1 - 0.1 \times (C - 1)\right)$$

Where:
* $D_{\text{base}}$: Base move damage.
* $M_{\text{zone}}$: Head ($1.5$), Torso ($1.0$), Legs ($0.8$).
* $C$: Current combo hit count ($1, 2, 3 \dots$).

---

## 4. Weapons & Movesets
1. **Bare Hands:** Fast startups, low reach, quick frame advantage on block, grappling capability.
2. **Katana:** Balanced reach and velocity, vertical overhead slashes, lethal mid-range zoning.
3. **Naginata:** Long reach, slow startup, devastating sweep and thrust capabilities.
4. **Kusarigama:** Erratic rhythm, flexible high/low attacks, complex recovery timing.

---

## 5. Stages & Environments
* **Stage 1: Twilight Dojo:** Traditional tatami dojo, paper shoji screens, candlelight lanterns, cherry blossom dust.
* **Stage 2: Bamboo Forest at Dusk:** Multi-layered swaying bamboo stalks, mist particles, dynamic wind effects.
* **Stage 3: Burning Citadel:** Cascading embers, glowing orange/crimson backlight silhouette contrast.

---

## 6. Sound & Visual Feedback
* **Hitstop:** 3–6 frames freeze on both attacker and defender during clean contact.
* **Camera Shake & Dynamic Framing:** Dynamic zoom in close quarters; positional camera midpoint tracking.
* **Slow-Motion KO:** Time scale reduced to $0.25$ for $1.5$ seconds upon decisive final strike.
* **Audio Layering:** Realistic Foley (fabric swish, scabbard draws, blade clashes, deep bass impacts).
