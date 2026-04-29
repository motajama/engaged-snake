# Dataset Guide

This project is designed so you can build a new game mostly by replacing the dataset and its assets instead of changing engine code.

The active sample pack lives in `datasets/base/`.

## Layout

Minimum expected structure:

```txt
datasets/base/
  dataset.json
  lang/
    en.json
    cs.json
  images/
    levels/
    difficulty_faces.png        optional
    guide_head.png              optional
    title.png                   optional
  music/
  sfx/
```

The engine currently reads localization from:

- `datasets/base/lang/en.json`
- `datasets/base/lang/cs.json`

## Core Rules

- Keep JSON content data-only.
- Put UI strings in localization JSON, not directly in `dataset.json`, whenever possible.
- Use paths relative to `datasets/base/` inside `dataset.json`.
- Missing images and SFX are allowed; the engine should fall back safely.
- Keep sprite sheets pixel-art friendly and export them without filtering.

## `dataset.json`

The current engine expects a structure like this:

```json
{
  "title": "ENGAGED SNAKE",
  "subtitle": "DATA-DRIVEN LOVE2D SLICE",
  "languages": ["en", "cs"],
  "title_screen": "images/title.png",
  "intro": {
    "image": "images/intro.png",
    "animation": "intro_placeholder",
    "duration": 3,
    "title_key": "intro_title",
    "body_key": "intro_body",
    "skip_key": "intro_skip"
  },
  "game_over": {
    "image": "images/game_over.png",
    "animation": "game_over_placeholder",
    "duration": 3,
    "title_key": "game_over_title",
    "body_key": "game_over_body",
    "hint_key": "game_over_hint"
  },
  "victory": {
    "image": "images/victory.png",
    "animation": "victory_placeholder",
    "duration": 3,
    "title_key": "victory_title",
    "body_key": "victory_body",
    "hint_key": "continue_hint"
  },
  "music": {
    "menu": "menu_theme",
    "level_1": "level_theme_1"
  },
  "sfx": {
    "good_collect": "pickup_good",
    "bad_hit": "pickup_bad",
    "stats_tick": "stats_tick",
    "stats_done": "stats_done",
    "menu_move": "menu_move",
    "menu_confirm": "menu_confirm"
  },
  "difficulty_faces": {
    "sprite": "images/difficulty_faces.png",
    "frame_w": 64,
    "frame_h": 64
  },
  "difficulty": {
    "baby": {
      "label_key": "difficulty.baby",
      "lives": 5,
      "initial_speed": 4,
      "speed_increment": 0.10,
      "good_food_multiplier": 0.8,
      "bad_food_multiplier": 0.5,
      "face_index": 0
    },
    "easy": {
      "label_key": "difficulty.easy",
      "lives": 4,
      "initial_speed": 5,
      "speed_increment": 0.16,
      "good_food_multiplier": 1.0,
      "bad_food_multiplier": 0.75,
      "face_index": 1
    },
    "normal": {
      "label_key": "difficulty.normal",
      "lives": 3,
      "initial_speed": 6,
      "speed_increment": 0.25,
      "good_food_multiplier": 1.0,
      "bad_food_multiplier": 1.0,
      "face_index": 2
    },
    "death": {
      "label_key": "difficulty.death",
      "lives": 1,
      "initial_speed": 8,
      "speed_increment": 0.45,
      "good_food_multiplier": 1.2,
      "bad_food_multiplier": 1.5,
      "face_index": 3
    }
  },
  "foods": {
    "good": {
      "id": "good",
      "name_key": "food_good_name",
      "description_key": "food_good_description",
      "icon": "images/good_food.png"
    },
    "bad": {
      "id": "bad",
      "name_key": "food_bad_name",
      "description_key": "food_bad_description",
      "icon": "images/bad_food.png"
    }
  },
  "characters": {
    "guide": {
      "name_key": "character_guide_name",
      "sprite": "images/guide_head.png",
      "frame_width": 64,
      "frame_height": 64,
      "frames": 4
    }
  },
  "levels": [
    {
      "id": "level_1",
      "name_key": "level_1_name",
      "description_key": "level_1_description",
      "story_key": "level_1_story",
      "background": "images/levels/level_1.png",
      "music": "level_theme_1",
      "grid_width": 14,
      "grid_height": 12,
      "good_count": 7,
      "bad_count": 4,
      "goal_good": 7,
      "hud_quotes": [
        "level_1_quote_1",
        "level_1_quote_2",
        "level_1_quote_3"
      ]
    }
  ]
}
```

## Top-Level Fields

- `title`: game title used by placeholder title rendering.
- `subtitle`: subtitle used by placeholder title rendering.
- `languages`: list of supported language file codes.
- `title_screen`: optional PNG path for the title image.
- `intro`, `game_over`, `victory`: non-gameplay screen configuration including optional full-screen image paths and text localization keys.
- `music`: logical music ids. The current audio layer is still placeholder-oriented, but keep ids here for forward compatibility.
- `sfx`: logical sound-effect ids. The current engine uses generated fallbacks if real files are missing.

## Difficulty Data

The engine now expects four gameplay difficulties:

- `baby`
- `easy`
- `normal`
- `death`

Each difficulty entry should define:

- `label_key`
- `lives`
- `initial_speed`
- `speed_increment`
- `good_food_multiplier`
- `bad_food_multiplier`
- `face_index`

These values affect actual gameplay:

- starting lives
- initial snake speed
- speed gain from good food
- good food count
- bad food count

## Difficulty Faces

`difficulty_faces` defines an optional sprite sheet used on the difficulty-selection screen.

Fields:

- `sprite`: PNG path relative to `datasets/base/`
- `frame_w`
- `frame_h`

Current assumptions:

- 4 horizontal frames
- nearest-neighbor scaling
- if the file is missing, the engine draws generated placeholder faces

## Character / Talking Head

The gameplay HUD and story screen share the same talking-head sprite sheet.

`characters.guide` fields:

- `name_key`
- `sprite`
- `frame_width`
- `frame_height`
- `frames`

Current assumptions:

- horizontal strip animation
- default/sample pack uses 4 frames
- if the file is missing, a placeholder sprite sheet is generated

## Level Fields

Each level currently supports:

- `id`
- `name_key`
- `description_key`
- `story_key`
- `background`
- `music`
- `grid_width`
- `grid_height`
- `good_count`
- `bad_count`
- `goal_good`
- `hud_quotes`

### Notes

- `good_count` and `bad_count` are the base counts before difficulty multipliers are applied.
- `goal_good` should usually match the intended base good-food target, but the current gameplay uses the difficulty-adjusted good-food count as the actual level-clear target.
- `hud_quotes` should contain localization keys, not literal text, when possible.

## Localization

All user-facing strings should live in `datasets/base/lang/*.json`.

Current important groups include:

- menu labels
- settings labels
- difficulty labels
- story text
- level names and descriptions
- HUD quote strings
- stats-screen labels

Example:

```json
{
  "difficulty.baby": "Can I play, Daddy?",
  "menu.choose_difficulty": "Choose your difficulty",
  "level_1_story": "Welcome to the training circuit.",
  "level_1_quote_1": "Keep the feed clean."
}
```

## Adding a New Dataset

Suggested workflow:

1. Copy `datasets/base/` to a new dataset folder while designing content.
2. Edit `dataset.json` first:
   - title
   - levels
   - difficulty values
   - character sprite references
   - SFX ids
3. Add or update localization keys in `lang/en.json` and `lang/cs.json`.
4. Drop in PNG assets:
   - title screen
   - talking-head sprite sheet
   - difficulty faces
   - level backgrounds
5. Run the game with:

```sh
love .
```

6. If an asset is missing, the engine should still run with placeholders; use that to iterate incrementally.

## Safe Fallbacks

Current fallback behavior:

- missing title image: generated title art
- missing intro/game-over/victory images: generated placeholder backgrounds
- missing talking-head sprite: generated placeholder head
- missing difficulty faces: generated placeholder faces
- missing SFX: generated tones

This means you can prototype the JSON first and fill in art/audio later.

## Authoring Tips

- Keep sprite sheets simple and aligned to exact frame sizes.
- Prefer short HUD quotes so they fit in the top-right bubble.
- Keep story text longer and HUD quotes shorter.
- Use localization keys consistently:
  `level_1_story`, `level_1_quote_1`, `difficulty.baby`, etc.
- When changing difficulty ids, update both:
  `dataset.json`
  language JSON files

## Current Limitations

- The engine currently loads the built-in `datasets/base/` pack directly; it does not yet expose runtime switching between multiple dataset folders.
- Audio ids are dataset-driven, but actual external audio-file loading is still placeholder-oriented.
- Intro/game-over/victory “animation” fields are metadata placeholders for future expansion.

## Validation Checklist

Before shipping a dataset, check:

- `dataset.json` parses correctly
- every localization key referenced by the dataset exists in `en.json`
- optional keys also exist in `cs.json` if Czech is supported
- `love .` starts without missing-module errors
- level names/story text display correctly
- difficulty selection shows valid labels and faces
- HUD quotes display and rotate correctly
- stats screen counts values correctly
