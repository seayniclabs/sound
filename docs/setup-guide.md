# Setup Guide

Everything you need to install Stem and connect it to your AI tool.

---

## Requirements

Before you start:

- **macOS 14 (Sonoma) or later** on Apple Silicon (M1/M2/M3/M4)
- **Apple Music subscription** for playback (catalog search, library browsing, and playlist creation work without one)
- **An MCP-compatible AI tool** — Claude Code, Cursor, Windsurf, or any client that supports the Model Context Protocol

## Step 1: Install Stem

### Option A: Homebrew (recommended)

```bash
brew install seayniclabs/tap/stem
```

This builds Stem from source on your machine and places the binary at `/opt/homebrew/bin/stem`.

### Option B: Download from GitHub

Download the latest binary from the [releases page](https://github.com/seayniclabs/stem/releases).

Move it somewhere on your `PATH`:

```bash
mv stem-macos-arm64 /usr/local/bin/stem
chmod +x /usr/local/bin/stem
```

### Option C: Build from source

```bash
git clone https://github.com/seayniclabs/stem.git
cd stem
swift build -c release
codesign --force --sign - --entitlements Sources/Stem/Stem.entitlements .build/release/Stem
```

The binary is at `.build/release/Stem`. Copy it to your `PATH`:

```bash
cp .build/release/Stem /usr/local/bin/stem
```

> **Note:** The codesign step is required. Stem uses the MusicKit entitlement to access Apple Music, and macOS enforces entitlements at runtime. Skipping codesign means MusicKit calls will fail silently.

### Verify installation

```bash
stem --version
```

Expected output:

```
Stem v0.1.2
```

## Step 2: Grant Apple Music access

Run the setup command:

```bash
stem setup
```

You'll see:

```
Stem — Apple Music for your AI tools
by Seaynic Labs

Requesting Apple Music access...
```

macOS will show a system dialog asking you to allow Stem to access Apple Music. Click **Allow**.

```
✓ Apple Music access granted
```

This permission is stored by macOS and only needs to be granted once. If you need to change it later, go to **System Settings > Privacy & Security > Media & Apple Music**.

### If you accidentally denied access

1. Open **System Settings > Privacy & Security > Media & Apple Music**
2. Find **Stem** in the list and toggle it on
3. Run `stem setup` again to verify

## Step 3: Connect to your AI tool

### Claude Code

The fastest way:

```bash
claude mcp add stem -- $(which stem) serve
```

Or add manually to `~/.claude.json`:

```json
{
  "mcpServers": {
    "stem": {
      "command": "/opt/homebrew/bin/stem",
      "args": ["serve"]
    }
  }
}
```

After adding, restart Claude Code to pick up the new server.

### Cursor

Add to your Cursor MCP configuration (Settings > MCP Servers):

```json
{
  "stem": {
    "command": "/opt/homebrew/bin/stem",
    "args": ["serve"]
  }
}
```

Restart Cursor after saving.

### Windsurf

Add to your Windsurf MCP configuration:

```json
{
  "stem": {
    "command": "/opt/homebrew/bin/stem",
    "args": ["serve"]
  }
}
```

Restart Windsurf after saving.

### Other MCP clients

Stem communicates over stdio using JSON-RPC (the MCP standard transport). Any client that supports MCP can connect by pointing to the Stem binary with the `serve` argument.

> **Path note:** If you installed via Homebrew, the binary is at `/opt/homebrew/bin/stem`. If you installed manually, use the path where you placed it. Run `which stem` to confirm.

## Step 4: Verify the connection

Ask your AI tool:

```
"Ping Stem"
```

Expected response:

```
Stem v0.1.2 is running. Apple Music is authorized.
```

Then try a real query:

```
"Search Apple Music for Tycho"
```

If you get search results back, everything is working.

## Step 5: Start using it

Here are some things you can ask:

| What to say | What happens |
|-------------|-------------|
| "Search for Radiohead" | Searches the Apple Music catalog |
| "Play Everlong by Foo Fighters" | Finds and plays the song |
| "What's playing right now?" | Shows current track info |
| "Skip to the next track" | Advances playback |
| "Pause the music" | Pauses playback |
| "Show my playlists" | Lists your Apple Music library playlists |
| "Create a playlist called Focus" | Creates a new empty playlist |
| "Add these songs to Focus" | Adds tracks to the playlist |

Your AI tool handles the natural language — Stem handles the Apple Music integration. You don't need to know tool names or parameter formats.

---

## Updating Stem

### Homebrew

```bash
brew upgrade stem
```

### Manual / GitHub

Download the latest release from the [releases page](https://github.com/seayniclabs/stem/releases) and replace your existing binary.

### From source

```bash
cd stem
git pull
swift build -c release
codesign --force --sign - --entitlements Sources/Stem/Stem.entitlements .build/release/Stem
cp .build/release/Stem /usr/local/bin/stem
```

## Uninstalling

### Homebrew

```bash
brew uninstall stem
brew untap seayniclabs/tap
```

### Manual

```bash
rm /usr/local/bin/stem
```

To revoke Apple Music access: **System Settings > Privacy & Security > Media & Apple Music** and remove Stem from the list.
