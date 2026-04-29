# engaged-snake

`engaged-snake` is a small data-driven Love2D/LÖVE 11.x snake game built to stay compatible with desktop and browser export workflows such as `love.js`.

## Features

- Internal resolution `256x144` scaled with nearest-neighbor filtering
- Dataset-driven title, story, levels, food metadata, and localization
- `cs` and `en` localization loaded from JSON
- Keyboard, mouse, touch, and virtual D-pad input
- Save/load for settings and highscores through `love.filesystem`
- Color and monochrome CRT video modes
- Placeholder-generated visuals so the project runs without external assets

## Run

```sh
love .
```

Or use:

```sh
make run
```

## Controls

- Move: arrow keys or `WASD`
- Confirm: `Enter` or `Space`
- Back: `Escape`
- Mouse/touch: menus, story skip, and gameplay virtual D-pad

## Project Layout

- `src/core/`: engine services
- `src/states/`: game states
- `src/systems/`: gameplay and rendering systems
- `datasets/base/`: replaceable content package

## Notes

The current version is a vertical slice with one playable level and placeholder-generated art/audio hooks. New games can reuse the engine by replacing dataset JSON, localization, and asset files.
