# Troubleshooting

Common issues and how to fix them.

---

## Installation

### `brew install` fails with "formula not found"

You need to tap the Seaynic Labs repository first:

```bash
brew tap seayniclabs/tap
brew install stem
```

Or install in one command:

```bash
brew install seayniclabs/tap/stem
```

### Build from source fails with "no such module 'MCP'"

Make sure you're running Swift 6.1 or later:

```bash
swift --version
```

Stem requires Xcode 16.3+ which ships Swift 6.1. Update Xcode from the App Store or [developer.apple.com](https://developer.apple.com/xcode/).

### "stem: command not found" after installation

Check that the binary is on your `PATH`:

```bash
which stem
```

If you installed via Homebrew, it should be at `/opt/homebrew/bin/stem`. If that directory isn't on your `PATH`, add it:

```bash
echo 'export PATH="/opt/homebrew/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

---

## Permissions

### Apple Music access denied / not authorized

**Symptoms:** `stem setup` reports access denied, or tools return "Apple Music access not authorized."

**Fix:**

1. Open **System Settings > Privacy & Security > Media & Apple Music**
2. Find **Stem** in the list
3. Toggle it **on**
4. Run `stem setup` again to verify

If Stem doesn't appear in the list, try running `stem setup` once — macOS adds the app to the list when it first requests access.

### "Stem" doesn't appear in Privacy & Security

This can happen if the binary wasn't properly codesigned with the MusicKit entitlement.

If you built from source, make sure you ran the codesign step:

```bash
codesign --force --sign - --entitlements Sources/Stem/Stem.entitlements .build/release/Stem
```

Homebrew builds handle this automatically.

### Permission prompt never appears

On some macOS versions, the permission dialog can appear behind other windows. Check for it in Mission Control or minimize your current windows.

If it still doesn't appear, reset the permission state:

```bash
tccutil reset AppleEvents com.seayniclabs.stem
```

Then run `stem setup` again.

---

## Playback

### "Subscription required for playback"

Playback tools (`play_song`, `play_pause`, `skip_next`, `skip_previous`, `set_queue`) require an active Apple Music subscription. Catalog search, library browsing, and playlist management work without one.

Verify your subscription: open **Music.app > Account > View My Account** and check your subscription status.

### Music starts playing but no sound

Stem controls playback through Music.app. Check:

1. **Volume** — Is Music.app's volume slider up? (It has its own volume independent of system volume.)
2. **Output device** — Is the correct audio output selected in **System Settings > Sound**?
3. **Music.app** — Is it open? Stem will launch it if needed, but if it was force-quit it may need a moment.

### Play command works but the wrong song plays

`play_song` takes an Apple Music catalog ID, not a song name. If your AI tool is passing the wrong ID, try being more specific in your request:

```
"Search Apple Music for Everlong by Foo Fighters"
```

Then:

```
"Play that first result"
```

This gives the AI tool a specific ID to work with.

---

## MCP Connection

### AI tool doesn't see Stem as an MCP server

After adding Stem to your MCP configuration, you must **restart your AI tool**. Claude Code, Cursor, and Windsurf all require a restart to detect new MCP servers.

### "Failed to start MCP server" or similar connection error

Check that the binary path in your MCP config is correct:

```bash
which stem
```

Common mistakes:

| Config shows | Should be |
|-------------|-----------|
| `stem` (no path) | `/opt/homebrew/bin/stem` |
| `/usr/local/bin/stem` | `/opt/homebrew/bin/stem` (if Homebrew install) |
| Missing `"args": ["serve"]` | The `serve` argument is required |

### Stem works in terminal but not in the AI tool

Some AI tools run MCP servers in a sandboxed environment with a different `PATH`. Always use the **full absolute path** to the binary in your MCP config, not just `stem`.

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

### MCP server starts but tools timeout

Stem needs Apple Music authorization to respond to most tool calls. If you skipped `stem setup`, the server will start but tool calls will fail.

Run `stem setup` in a terminal, grant access, then restart your AI tool.

---

## Library Operations

### `get_library_playlists` returns empty results

Library access requires that you've synced your library to this Mac. In Music.app, go to **Settings > General** and make sure **Sync Library** is enabled.

### `create_playlist` succeeds but playlist doesn't appear in Music.app

New playlists may take a moment to sync. Check Music.app's sidebar — if the playlist isn't visible, try:

1. Close and reopen Music.app
2. Check that iCloud Music Library sync is enabled

### `add_to_playlist` fails with "Invalid playlist ID format"

Playlist IDs look like `p.QhW4rR5K8l` — they start with `p.` followed by alphanumeric characters. If you're getting this error, you may be passing a catalog ID (numeric) instead of a library playlist ID.

Use `get_library_playlists` to get the correct playlist IDs.

---

## General

### How do I check which version I'm running?

```bash
stem --version
```

Or ask your AI tool to ping Stem — the response includes the version number.

### How do I report a bug?

Open an issue at [github.com/seayniclabs/stem/issues](https://github.com/seayniclabs/stem/issues) with:

1. Your macOS version
2. Stem version (`stem --version`)
3. Which AI tool you're using
4. What you tried and what happened

### Stem crashes or hangs

If Stem becomes unresponsive, kill it and restart your AI tool:

```bash
pkill -f "stem serve"
```

Then restart your AI tool. The MCP client will relaunch Stem automatically.

If this happens repeatedly, check Console.app for crash logs mentioning `com.seayniclabs.stem` and include them in a bug report.
