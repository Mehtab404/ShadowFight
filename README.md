# ⚔️ Project: Shadow Ronin (Working Title)

> A 2D physics-driven, silhouette-styled martial arts fighting game inspired by *Shadow Fight 2*.

![Genre](https://img.shields.io/badge/Genre-2D%20Fighting-red)
![Engine](https://img.shields.io/badge/Engine-Godot%204%20%2F%20Unity-blue)
![Status](https://img.shields.io/badge/Status-Pre--Production-yellow)
![License](https://img.shields.io/badge/License-MIT-green)

---

## 📖 1. Game Overview & Core Pillars

Unlike fast-paced arcade fighters, a *Shadow Fight*-style game emphasizes **weighty, deliberate, and realistic martial arts combat**. Every strike carries momentum, spacing matters, and silhouettes keep the player's focus purely on posture and telegraphing.

### Core Design Pillars
1. **Readable Silhouette Visuals:** High-contrast black fighter silhouettes rendered against vibrant, atmospheric, multi-layered parallax backgrounds (dojo, bamboo forest, burning village).
2. **Physics-Driven Skeletal Animation:** Smooth 2D skeletal rigging with Inverse Kinematics (IK) and ragdoll physics on knockdowns and KOs.
3. **Deliberate Combat Rhythm:** Strict frame data (Startup, Active, Recovery) so attacks feel impactful and punishable.
4. **Weapon-Based Movesets:** Changing a weapon (Katana, Kusarigama, Nunchaku, Bare Hands) alters reach, swing speed, and combo trees.

---

## 🛠️ 2. Recommended Tech Stack

| Component | Recommended Tool | Why? |
| :--- | :--- | :--- |
| **Game Engine** | **Godot 4.3+** (GDScript/C#) or **Unity 2D** (C#) | Godot 4 is lightweight, open-source, Git-friendly, and has built-in `Skeleton2D` and `Polygon2D` rigging. |
| **2D Rigging & Animation** | **Spine 2D**, **DragonBones**, or **Godot Skeleton2D** | Essential for fluid martial arts limbs without drawing thousands of frame-by-frame sprites. |
| **Shaders / VFX** | **GLSL / Godot Shader Language** | Used for pure black silhouette overrides, glowing weapon trails, and dynamic rim lighting. |
| **Audio** | **FMOD** or Built-in AudioStreamPlayer | Layered Foley sounds (whooshes, cloth rustles, blade clangs, bone impacts). |
| **Version Control** | **Git + GitHub + Git LFS** | Industry standard; Git LFS handles large art and audio binaries cleanly. |

---

## 🏗️ 3. Technical Architecture & Combat System

### Finite State Machine (FSM)
Every fighter is controlled by a strict **Finite State Machine** to prevent animation glitches and illegal move cancellations.

```text
[IDLE] <---> [WALK_FORWARD / WALK_BACK]
  |
  +---> [CROUCH] ---> [LOW_ATTACK / SWEEP]
  +---> [JUMP]   ---> [AIR_ATTACK]
  +---> [ATTACK_STARTUP] ---> [ATTACK_ACTIVE] ---> [ATTACK_RECOVERY] ---> [IDLE]
  +---> [BLOCK_STUN] (Triggered when holding Back + Hit)
  +---> [HIT_STUN]   (Triggered when Hurtbox overlaps enemy Hitbox)
  +---> [KNOCKDOWN]  ---> [GET_UP (Invulnerable Frames)] ---> [IDLE]
```

### Collision Boxes (The Fighting Game Trinity)
* **Pushbox:** Prevents the two fighters from walking through each other.
* **Hurtbox:** Attached to the fighter's skeletal limbs (Head, Torso, Legs). Receiving a hit on the Head triggers a **Head Hit** (bonus damage + stagger).
* **Hitbox:** Activated *only* during the **Active Frames** of an attack animation, attached to fists, feet, or weapon blades.

### Damage & Combo Scaling Formula
To prevent infinite stun-lock combos, apply a scaling multiplier for consecutive hits:

$$D_{\text{final}} = D_{\text{base}} \times M_{\text{zone}} \times \max\left(0.3, \; 1 - 0.1 \times (C - 1)\right)$$

Where:
* $D_{\text{base}}$ is the weapon/move base damage.
* $M_{\text{zone}}$ is the hit-zone multiplier ($1.5$ for Head, $1.0$ for Torso, $0.8$ for Legs).
* $C$ is the current combo hit count.

### Sample Frame Data Table (60 FPS Standard)
| Move Name | Input | Startup (f) | Active (f) | Recovery (f) | On Hit | On Block |
| :--- | :--- | :---: | :---: | :---: | :---: | :---: |
| **Quick Jab** | `Punch` | 6 | 3 | 8 | +4 | +1 |
| **Roundhouse Kick** | `Forward + Kick` | 12 | 5 | 14 | Knockdown | -6 |
| **Katana Overhead** | `Up + Weapon` | 16 | 6 | 18 | Heavy Stagger | -8 |
| **Low Sweep** | `Down + Kick` | 10 | 4 | 15 | Trip | -10 |

### Game Feel ("Juice")
* **Hitstop (Impact Freeze):** Pause both fighters' animations for $3\text{--}6$ frames on heavy impacts to convey weight.
* **Camera Zoom & Shake:** Dynamically zoom in during close-quarters clashes and trigger micro-shakes on critical hits.
* **Slow-Motion KO:** Drop engine `time_scale` to $0.25$ for $1.5$ seconds when the final blow lands.

---

## 📂 4. Repository Directory Structure

Organize your project cleanly before your first commit:

```text
shadow-ronin/
├── .github/
│   └── workflows/          # CI/CD (automated export builds / linting)
├── assets/
│   ├── audio/              # SFX (impacts, blades) & BGM (taiko drums, shamisen)
│   ├── backgrounds/        # Multi-layer parallax art
│   ├── rigs/               # 2D Skeletal rigs & silhouette parts
│   └── shaders/            # Silhouette, weapon trail, and hit-flash shaders
├── docs/
│   ├── GDD.md              # Expanded design docs & lore
│   └── frame_data.csv      # Master balancing sheet for all moves
├── src/
│   ├── ai/                 # Enemy AI (Behavior Trees / Utility AI)
│   ├── characters/         # Fighter scenes, FSM scripts, stats
│   ├── combat/             # Hitbox/Hurtbox manager, damage calculator
│   ├── core/               # GameManager, RoundTimer, AudioManager
│   └── ui/                 # Health bars, combo counter, round indicators
├── .gitattributes          # Git LFS tracking rules
├── .gitignore              # Engine-specific ignored cache/temp files
└── README.md               # This file
```

---

## 🗺️ 5. Development Roadmap

- [ ] **Phase 1: Greybox Combat Prototype**
  - [ ] 2D arena with boundaries and dynamic tracking camera.
  - [ ] Basic fighter FSM (Idle, Walk, Jump, Punch, Kick, Block).
  - [ ] Hitbox/Hurtbox collision system + basic health bars.
- [ ] **Phase 2: Silhouette & Skeletal Animation**
  - [ ] Implement 2D skeletal rig with silhouette shader.
  - [ ] Add procedural weapon trails and hit-spark VFX.
  - [ ] Build 1 parallax dojo stage with atmospheric particles (leaves/embers).
- [ ] **Phase 3: Combat Depth & AI Opponent**
  - [ ] Add Hitstop, Screen Shake, and Slow-Mo KO.
  - [ ] Implement Enemy AI with reactive blocking, spacing, and attack patterns.
  - [ ] Add 3 distinct weapons (Bare Hands, Katana, Naginata).
- [ ] **Phase 4: Polish & Release**
  - [ ] Sound design (whooshes, parries, martial arts vocals, traditional music).
  - [ ] Main Menu, Pause Menu, and Round System (Best of 3).
  - [ ] Export builds for PC (Windows/Linux) and Mobile (Android/iOS).

---

## 🚀 6. Git & GitHub Setup (Initialize, Commit & Push)

Follow these exact terminal commands to set up your repository, configure **Git LFS** for game assets, and push your first commit to GitHub.

### Step 1: Create a Repository on GitHub
1. Go to [GitHub](https://github.com/new) and create a new repository named `shadow-ronin`.
2. **Do not** initialize it with a README (we are pushing this one).

### Step 2: Initialize Locally & Configure Git LFS
Open your terminal inside your project folder and run:

```bash
# 1. Initialize the local Git repository
git init

# 2. Initialize Git LFS (Large File Storage) for game assets
git lfs install
git lfs track "*.png" "*.psd" "*.wav" "*.ogg" "*.mp3" "*.fbx" "*.spine"

# 3. Create a basic .gitignore (adjust if using Unity/Unreal)
cat << 'EOF' > .gitignore
# Godot 4 ignores
.godot/
*.translation

# OS & IDE ignores
.DS_Store
Thumbs.db
.vscode/
.idea/
EOF
```

### Step 3: Stage, Commit, and Push to GitHub
Replace `<YOUR_USERNAME>` with your actual GitHub username:

```bash
# 4. Stage all files (including this README.md and .gitattributes)
git add .

# 5. Create your initial commit using Conventional Commits format
git commit -m "chore: initial project setup, GDD blueprint, and Git LFS config"

# 6. Rename the default branch to main
git branch -M main

# 7. Link to your remote GitHub repository
git remote add origin https://github.com/<YOUR_USERNAME>/shadow-ronin.git

# 8. Push your code to GitHub
git push -u origin main
```

### Daily Development Git Workflow
Whenever you add a new feature (like a new weapon or combat move), always work on a feature branch:

```bash
git checkout -b feat/katana-combat
# ... write code and test in engine ...
git add .
git commit -m "feat(combat): add katana overhead slash with hitbox and hitstop"
git push -u origin feat/katana-combat
```

---

## 🤝 Contributing & Commit Standards

This project follows [Conventional Commits](https://www.conventionalcommits.org/):
* `feat:` New gameplay feature, weapon, or AI behavior.
* `fix:` Bug fix (e.g., hitbox desync, animation lock).
* `art:` New sprites, rigs, shaders, or backgrounds.
* `audio:` Sound effects or music tracks.
* `chore:` Project config, build scripts, or documentation updates.