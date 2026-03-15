# API Reference

Complete reference for all 15 MCP tools provided by Stem.

You don't need to call these tools directly — your AI tool translates natural language into tool calls automatically. This reference is for developers building integrations or debugging tool behavior.

---

## Catalog

### `search_catalog`

Search the Apple Music catalog for songs, albums, or artists.

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `query` | string | Yes | — | Search query (artist name, song title, album, or natural language) |
| `type` | string | No | `"song"` | Result type: `"song"`, `"album"`, or `"artist"` |
| `limit` | integer | No | `10` | Number of results to return (1–25) |

**Returns:** Text list of results, one per line.

```
[1742630029] Awake by Tycho
[1742630047] Dive by Tycho
[1742630061] Coastal Brake by Tycho
```

Each result includes the Apple Music catalog ID in brackets, which can be used with other tools like `get_song_details` or `play_song`.

**Subscription required:** No

---

### `get_song_details`

Get full metadata for a specific song by its catalog ID.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string | Yes | Apple Music catalog song ID |

**Returns:** Multi-line text with song metadata.

```
Title: Awake
Artist: Tycho
Album: Awake
Duration: 5:17
Genre: Electronic
Release Date: 2014-03-18
Disc: 1
Track: 1
```

**Subscription required:** No

---

### `get_album_details`

Get album info with a full track listing.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string | Yes | Apple Music catalog album ID |

**Returns:** Album metadata followed by numbered track listing.

```
Album: Awake
Artist: Tycho
Released: 2014-03-18
Genre: Electronic
Tracks: 8

1. Awake [1742630029] (5:17)
2. Montana [1742630030] (4:22)
3. Dye [1742630031] (3:54)
4. See [1742630032] (5:30)
5. Apogee [1742630033] (4:10)
6. L [1742630034] (5:16)
7. Spectre [1742630035] (4:30)
8. Plains [1742630036] (5:05)
```

Track IDs in brackets can be used with `play_song`, `set_queue`, or `add_to_playlist`.

**Subscription required:** No

---

## Playback

### `play_song`

Play a specific song by its catalog ID. Opens Music.app if it isn't already running.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string | Yes | Apple Music catalog song ID |

**Returns:** Confirmation text.

```
Now playing: Awake by Tycho
```

**Subscription required:** Yes — playback requires an active Apple Music subscription.

---

### `play_pause`

Toggle between playing and paused states.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| — | — | — | No parameters |

**Returns:** Current state.

```
Playing.
```

or

```
Paused.
```

**Subscription required:** Yes

---

### `skip_next`

Skip to the next track in the queue.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| — | — | — | No parameters |

**Returns:** Now playing info for the new track (same format as `get_now_playing`).

**Subscription required:** Yes

---

### `skip_previous`

Go back to the previous track in the queue.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| — | — | — | No parameters |

**Returns:** Now playing info for the new track (same format as `get_now_playing`).

**Subscription required:** Yes

---

### `get_now_playing`

Get info about the currently playing (or paused) track.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| — | — | — | No parameters |

**Returns:** Playback state and track info.

```
Playing: Awake by Tycho — Awake
```

or

```
Paused: Montana by Tycho — Awake
```

Returns an error message if nothing is in the queue.

**Subscription required:** No

---

## Queue

### `get_queue`

Get the current playback queue.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| — | — | — | No parameters |

**Returns:** Numbered list of queue entries. The currently playing track is marked with `▶`.

```
1. Awake by Tycho
▶ 2. Montana by Tycho
3. Dye by Tycho
4. See by Tycho
```

**Subscription required:** Yes

---

### `set_queue`

Replace the entire playback queue with a list of songs and start playing.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `ids` | array of strings | Yes | Apple Music catalog song IDs |

**Returns:** Confirmation with track count and now playing info.

```
Queue set with 4 songs. Now playing: Awake by Tycho
```

Songs that can't be found by ID are skipped. If no valid songs are provided, returns an error.

**Subscription required:** Yes

---

## Library

### `get_library_playlists`

List playlists from your Apple Music library.

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `limit` | integer | No | `25` | Number of playlists to return (1–100) |

**Returns:** Numbered list with playlist IDs.

```
1. [p.QhW4rR5K8l] Focus
2. [p.Mo2r5E8a0Z] Running
3. [p.AoVr3E9L5b] Evening
```

Playlist IDs (the `p.` values) are used with `add_to_playlist`.

**Subscription required:** No

---

### `get_recently_played`

Get your recent listening history.

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `limit` | integer | No | `10` | Number of tracks to return (1–25) |

**Returns:** Numbered list of recently played tracks.

```
1. Awake by Tycho — Awake
2. Midnight City by M83 — Hurry Up, We're Dreaming
3. Intro by The xx — xx
```

**Subscription required:** No

---

### `create_playlist`

Create a new playlist in your Apple Music library.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `name` | string | Yes | Playlist name |
| `description` | string | No | Playlist description |

**Returns:** Confirmation with the new playlist's ID.

```
Created playlist: Focus [ID: p.QhW4rR5K8l]
```

The returned ID can be used with `add_to_playlist`.

**Subscription required:** No

---

### `add_to_playlist`

Add songs to an existing playlist.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `playlist_id` | string | Yes | Library playlist ID (the `p.` value from `get_library_playlists`) |
| `song_ids` | array of strings | Yes | Apple Music catalog song IDs to add |

**Returns:** Confirmation with count.

```
Added 3 songs to playlist p.QhW4rR5K8l
```

**Validation:** Playlist ID must match the expected format (alphanumeric characters and dots). Invalid IDs are rejected before the API call.

**Subscription required:** No

---

## Utility

### `ping`

Health check. Confirms Stem is running and Apple Music access is authorized.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| — | — | — | No parameters |

**Returns:** Version and auth status.

```
Stem v0.1.2 is running. Apple Music is authorized.
```

**Subscription required:** No

---

## Error handling

All tools return structured error messages when something goes wrong. Common patterns:

| Error | Cause | Resolution |
|-------|-------|------------|
| `Apple Music access not authorized` | macOS permission not granted | Run `stem setup` or enable in System Settings |
| `Subscription required for playback` | No active Apple Music subscription | Subscribe to Apple Music or use catalog/library tools only |
| `No song found with ID: ...` | Invalid or expired catalog ID | Search again to get current IDs |
| `Invalid playlist ID format` | Malformed playlist ID | Use IDs from `get_library_playlists` |
| `Nothing is currently playing` | No active playback session | Play a song first with `play_song` or `set_queue` |

Errors are returned as text content in the MCP response — they don't crash the server. Stem stays running and ready for the next request.

---

## Transport

Stem uses **stdio** transport (the MCP default). Communication is JSON-RPC 2.0 over stdin/stdout. This is handled automatically by MCP clients — you don't need to manage the transport layer.

```
AI Tool  ──stdin/stdout──>  Stem  ──MusicKit──>  Apple Music
                                  ──REST API──>  Apple Music (library ops)
```

Catalog search, song details, album details, and playback control use MusicKit framework APIs. Library operations (playlists, recently played) use the Apple Music REST API with a user token obtained through MusicKit authorization.
