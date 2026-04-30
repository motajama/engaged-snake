# Online Scores

The game can save scores locally and optionally upload them to a small PHP/MySQL backend.

## Backend Setup

1. Upload `backend/` to the PHP server.
2. Create the MySQL table with `backend/schema.sql`.
3. Copy `backend/config.sample.php` to `backend/config.php`.
4. Edit `backend/config.php` with the database DSN/user/password.
5. Generate an upload password hash locally:

```sh
php backend/generate_password_hash.php 'your-unique-upload-password'
```

6. Put the generated hash in `upload_password_hash`.

The real `backend/config.php` is ignored by git.

## Table

The score table is named `engagedsnake-scores`. It stores:

- player name
- score
- level where the run ended
- victory marker, shown as `*` on the web scoreboard
- request metadata and creation time

If more tables are added later, keep the same `engagedsnake-` prefix.

## Game Client Setup

### Step 1: Install Runtime Networking Modules

Online upload uses Lua modules loaded by the LÖVE runtime:

- `socket.http` from LuaSocket for plain HTTP
- `ssl.https` from LuaSec for HTTPS
- `ltn12` from LuaSocket for request bodies

Use HTTPS for production servers. That means both LuaSocket and LuaSec must be available to LÖVE.

#### Option A: System Packages

On Debian/Ubuntu:

```sh
sudo apt update
sudo apt install lua-socket lua-sec
```

On Fedora:

```sh
sudo dnf install lua-socket lua-sec
```

On Arch Linux:

```sh
sudo pacman -S lua-socket lua-sec
```

Then run:

```sh
love .
```

If LÖVE cannot find the modules from system packages, use the LuaRocks local install below.

#### Option B: Local LuaRocks Install

LÖVE 11.x embeds LuaJIT, which is compatible with Lua 5.1 modules. Install the rocks into a project-local tree:

```sh
mkdir -p vendor/lua
luarocks --lua-version=5.1 --tree vendor/lua install luasocket
luarocks --lua-version=5.1 --tree vendor/lua install luasec
```

Run LÖVE with paths pointed at that tree:

```sh
LUA_PATH="./vendor/lua/share/lua/5.1/?.lua;./vendor/lua/share/lua/5.1/?/init.lua;;" \
LUA_CPATH="./vendor/lua/lib/lua/5.1/?.so;;" \
love .
```

For convenience, put those exports in your shell profile or in a local run script that is not committed.

On macOS with Homebrew/LuaRocks, the same local-tree approach is usually the most predictable:

```sh
brew install luarocks openssl
mkdir -p vendor/lua
luarocks --lua-version=5.1 --tree vendor/lua install luasocket
luarocks --lua-version=5.1 --tree vendor/lua install luasec
```

On Windows, install LuaRocks for Lua 5.1/LuaJIT and use the equivalent local tree. The native module suffix is usually `.dll`, so the `LUA_CPATH` entry should point at `vendor/lua/lib/lua/5.1/?.dll`.

### Step 2: Configure Upload Endpoint

Copy `score_client_config.sample.lua` to `score_client_config.lua` and set:

```lua
return {
    endpoint = "https://your-server.example/path/to/submit.php",
    password = "your-unique-upload-password",
    timeout = 4,
}
```

The real `score_client_config.lua` is ignored by git. The game still saves scores locally when the file is missing, when LuaSocket/LuaSec is unavailable, or when the upload fails. HTTPS endpoints require LuaSec (`ssl.https`); plain HTTP endpoints require LuaSocket (`socket.http`).

### Step 3: Verify Upload Behavior

1. Start the game with the configured runtime.
2. Finish a run or lose all lives.
3. Enter a player name and save the score.
4. Open `backend/index.php` on the server and confirm the score appears.

If the score appears only in the in-game local high score table, check that `score_client_config.lua` exists, the endpoint URL is correct, and LÖVE can load `socket.http`, `ssl.https`, and `ltn12`.

## Public Scoreboard

Open `backend/index.php` in a browser. The page only shows scores. Design tokens, colors, and Google Fonts are in `backend/style.css`.

## Security Note

The server stores only a password hash, but the game client must know the upload password to submit scores. This blocks accidental or casual writes, not determined tampering by someone who extracts the client files.
