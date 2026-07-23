# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Godot 4 recreation of Super Mario Bros. (NES), GDScript only. The goal is fidelity to the original game's feel — physics constants are derived from the NES sub-pixel units (see the conversion formulae at the top of `characters/player.gd`). Prefer deriving new constants the same way over hand-tuning.

Base resolution is 256×240 with nearest-neighbour filtering; keep art and offsets pixel-aligned.

## Commands

Engine: **Godot 4.7.1**. No test suite or linter is configured. The binary is not on `PATH`; it lives at `~/Downloads/Godot_v4.7.1-stable_linux.x86_64`.

```bash
GODOT=~/Downloads/Godot_v4.7.1-stable_linux.x86_64

$GODOT --path .                                        # run the game
$GODOT --editor --path .                               # open the editor
$GODOT --headless --quit-after 300 --path .            # smoke-run, surfaces runtime errors
$GODOT --headless --editor --quit-after 300 --path .   # reimport + surface parse errors
$GODOT --headless --export-release "Web" --path .      # needs export templates installed
```

Headless is the practical verification loop: a clean run of both headless commands above means every script parses and the main scene boots. Export templates are **not** installed locally, so `--export-release` only works in CI.

CI (`.github/workflows/ci.yml`) runs on push to `main`: web export in the `barichello/godot-ci:4.7.1` container, deployed to the `gh-pages` branch. `GODOT_VERSION` must match the export-templates directory name (`4.7.1.stable`).

Script `.uid` files (Godot 4.4+) are part of the source and must be committed alongside their `.gd` file. Opening the project in the editor rewrites `*.import` files; keep that churn out of feature commits.

Indentation is tabs (see `.vscode/settings.json`). Most scripts follow gdformat conventions (two blank lines between top-level functions); `characters/player.gd` uses one — match the file you are editing.

## Architecture

### Scene tree contract

`main.tscn` → `HUD` + `Stage` (currently `stages/1_1.tscn`). Autoloads resolve **hardcoded absolute paths** into this tree:

- `global/stage_manager.gd` → `/root/Main/Stage` and `/root/Main/Stage/TileMap`
- `global/physics.gd` → `/root/Main/Stage`

Renaming those nodes, or running a stage scene standalone, breaks the autoloads. Any new stage must keep the `Stage` + `TileMap` node names and be instanced under `Main`.

### Autoloads

- **StageManager** — owns `StageTheme` (OVERWORLD/UNDERGROUND) and the `theme` setter, which swaps the tileset source texture *in place on the shared `assets/tilesets/tileset.tres`*, sets the clear color, and emits `theme_changed`.
- **Physics** — global `GRAVITY` / `MAX_FALL_SPEED` / `JUMP_SPEED` used by everything except the player (which has its own speed-tiered constants). `disable()`/`enable()` recursively toggle `set_physics_process` and pause `AnimatedSprite2D`s under `Stage` — this is the game-freeze mechanism (used during Mario's grow/shrink transition, re-enabled from `AnimationPlayer.animation_finished`). It also pins `Engine.physics_ticks_per_second` to the display refresh rate every frame.
- **GameLog** (`global/game_log.gd`) — `append()` prints and emits `message_logged`. Named `GameLog`, not `Logger`, because Godot 4.7 ships a built-in `Logger` class that shadows an autoload of that name and breaks every script referencing it.

### Theming

Themeable entities (`question_block.gd`, `brick_block.gd`, `goomba.gd`) each hold a `const _THEMES` dict keyed by `StageManager.StageTheme` mapping to preloaded `SpriteFrames` resources, call `_set_theme(StageManager.theme)` in `_ready`, and connect to `theme_changed`. Adding a theme means: a new `ThemeData` `.tres` in `themes/`, a new enum value + entry in `StageManager._THEMES`, a `*_frames_<theme>.tres` per themed entity, and an entry in each entity's `_THEMES`.

### Interaction protocols (duck-typed, not interfaces)

- **`hit(body)`** — the universal "something was struck from below" call. `Player.handle_last_collision()` detects an upward collision normal and calls `collider.hit(self)`. `QuestionBlock.on_hit()` in turn calls `hit()` on everything overlapping its `HitArea`, so a hit block bumps items/enemies standing on it (`RedMushroom.hit()` bounces). `BrickBlock` extends `QuestionBlock` and overrides `on_hit()` to shatter only when it holds no item and the player is big.
- **Groups** — `enemies` (must expose `is_alive` and `stomp()`) and `powerups`. The player's `Hitbox` Area2D decides stomp vs. damage by comparing y-position and velocity.
- **Spawned items** get a `spawner` property set to the block; `RedMushroom` awaits `spawner.hit_finished` to play the emerge-from-block tween before enabling its collision.

### Camera / zones

`misc/zone.gd` is an `Area2D` per stage section; on body entry it finds a `Camera2D` child of the body and calls `set_bounds()` with the zone's `CollisionShape2D`, which sets the camera limits and recomputes zoom. The player clamps its own x to those limits in `process_bounds_collision()`.

### Physics layers

1 = World, 2 = Entities, 3 = Items. 2D physics runs on a separate thread (`project.godot`).

### Known 4.7 debt

`stages/1_1.tscn` still uses the **deprecated `TileMap` node** (verified working in 4.7 — 822 cells, collisions intact), and `StageManager` types its reference as `TileMap`. `TileMapLayer` is the replacement; `TileMap` is expected to be removed in Godot 5. Converting means changing the node type, its `tile_data` format, and `StageManager.theme`'s `tile_set.get_source(0)` access.
