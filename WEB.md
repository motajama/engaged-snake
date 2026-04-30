# Web Export Guide

This guide shows how to package `engaged-snake` for the browser and how to place it inside an existing webpage.

Credit line for published builds: `design&concept->motajama coding->Codex @ GPL3 2026`

The game code is already written to stay friendly to `love.js`-style browser export:

- no LuaJIT FFI
- no platform-specific APIs
- save data goes through `love.filesystem`
- rendering uses a fixed logical resolution and nearest-neighbor scaling

## What You Build First

The browser toolchain usually starts from a `.love` file.

Create it with:

```sh
make love
```

That produces:

```txt
build/engaged-snake.love
```

This file is the package you feed into your Love2D web-export pipeline.

## Before Exporting

Check the game locally first:

```sh
make check
love .
```

Verify at least:

- menus open correctly
- difficulty selection works
- gameplay starts
- high-score screen shows the credit line at bottom right
- touch UI can be forced `ON` in Settings
- intro, stats, game-over, and victory screens render

## Option 1: Standalone Browser Page

Use this when you want the game to live on its own page, like `example.com/engaged-snake/`.

### Step 1: Build the `.love`

```sh
make love
```

### Step 2: Export with Your Love.js-Compatible Tool

Use your preferred Love2D-to-web pipeline and point it at:

```txt
build/engaged-snake.love
```

The exact command depends on the export tool you use, but the output is typically:

- an `index.html`
- JavaScript loader/runtime files
- one or more `.data`, `.wasm`, or packaged asset files

Keep all exported files together in one web folder.

### Step 3: Serve the Exported Files

Host the generated web folder on any static web host:

- GitHub Pages
- Netlify
- Vercel
- nginx / Apache
- an existing site’s static assets folder

Do not open the export directly from `file://`. Use a web server.

### Step 4: Check Browser Behavior

After upload, test:

- desktop keyboard input
- mouse clicks in menus
- touch controls on phone/tablet
- scaling clarity
- save/load behavior in browser storage
- high-score credit line remains visible and unobstructed
- audio start after user interaction

## Option 2: Embed Into an Existing Website

Use this when the game should be part of an existing landing page, article, or portal.

There are two practical patterns.

## Pattern A: `<iframe>` Embed

This is the safest integration.

### Step 1: Export the Game as Above

Produce the browser-ready folder first.

### Step 2: Upload It to a Subfolder

Example:

```txt
/public/games/engaged-snake/
  index.html
  ...
```

### Step 3: Embed It

```html
<iframe
  src="/games/engaged-snake/"
  title="Engaged Snake"
  width="960"
  height="720"
  loading="lazy"
  style="border:0; max-width:100%; aspect-ratio:4 / 3;"
></iframe>
```

### Why Use This

- easiest to maintain
- isolates CSS and JS from the host page
- avoids collisions with existing website code
- simplest upgrade path when you replace the game build later

## Pattern B: Inline Section on an Existing Page

Use this only if you need the game inside the page layout instead of isolated in an iframe.

### Step 1: Export the Game

Build the browser-ready folder first.

### Step 2: Copy the Generated Runtime Files Into a Site Subfolder

Example:

```txt
/public/engaged-snake/
```

### Step 3: Add a Container to Your Page

```html
<section class="game-shell">
  <h2>Engaged Snake</h2>
  <div id="engaged-snake-root"></div>
</section>
```

### Step 4: Include the Exported Loader Files

The exact tags depend on the export tool. In principle, you will include:

- the generated JS loader
- the generated data/wasm files it expects
- the generated HTML or bootstrap logic adapted to your page

If your exporter produces a full `index.html`, use that file as the reference and move its game boot markup/scripts into your page carefully.

### Step 5: Isolate Styling

Make sure your site CSS does not distort the game canvas.

Recommended CSS:

```css
.game-shell {
  max-width: 960px;
  margin: 0 auto;
}

#engaged-snake-root canvas {
  display: block;
  width: 100%;
  height: auto;
  image-rendering: pixelated;
  image-rendering: crisp-edges;
}
```

### When To Avoid This

Avoid inline integration if:

- your site has heavy global CSS resets
- your site JS rewrites canvases or focus behavior
- you just need a reliable playable embed

In those cases, use an iframe instead.

## Sizing Recommendations

The game uses:

- logical space: `320x240`
- default desktop window ratio: `4:3`

For web embedding, keep a `4:3` box. Good display sizes:

- `640x480`
- `800x600`
- `960x720`

For responsive pages, use:

- `width: 100%`
- `height: auto` or `aspect-ratio: 4 / 3`

## Touch and Mobile Notes

The game can auto-show touch controls on mobile/tablet platforms, and users can override this in Settings.

For browser testing:

- test on a real phone if possible
- confirm taps do not scroll the page while playing
- avoid placing the game inside very small containers
- leave enough margin around the canvas for thumb comfort

If your site scrolls on touch over the game, wrap the embed in a container that disables touch panning for that area:

```css
.game-shell {
  touch-action: none;
}
```

Apply that only if needed, because it changes page interaction in that region.

## Save Data in the Browser

The game uses `love.filesystem` for settings and highscores.

In browser exports, that usually maps to browser-managed storage such as IndexedDB or an Emscripten-backed virtual filesystem. Exact persistence behavior depends on the export runtime.

Test this explicitly:

1. change Settings
2. finish a run or write a high score
3. reload the page
4. confirm the data persisted

## Audio Notes

Browsers often block audio until the user interacts with the page.

Test this flow:

1. load the page
2. click or tap once
3. confirm menu/gameplay sounds work afterward

If music or SFX appear silent before interaction, that is a browser policy issue, not necessarily a game bug.

## Asset and Path Rules

When preparing a web build:

- keep dataset-relative paths intact inside the packaged game
- do not flatten or rename files after export unless your exporter explicitly supports it
- keep PNGs unfiltered for crisp scaling
- prefer ASCII filenames for assets and folders

## Typical Deployment Workflow

1. Update dataset content and test with `love .`
2. Run `make check`
3. Run `make love`
4. Export `build/engaged-snake.love` with your browser pipeline
5. Upload the generated web build
6. Test desktop, mobile, audio, and save persistence
7. If embedding into an existing site, prefer iframe first

## Recommended Integration Choice

Use an iframe if:

- you want the lowest-risk website integration
- the host site already has a lot of CSS/JS
- you expect to replace the game build often

Use inline integration if:

- you control the whole page
- you need the game to sit tightly inside surrounding content
- you are comfortable adapting the exporter’s generated bootstrap code
