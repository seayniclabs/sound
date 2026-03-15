# Changelog

All notable changes to Stem are documented here.

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/). Versioning follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased]

### Changed
- Preparing for v1.0.0 release

---

## [0.1.2] — 2026-03-13

### Changed
- Wrapped all tool handlers in `do/catch` blocks for consistent error reporting
- Input validation on `add_to_playlist` — playlist ID format check (alphanumeric + dots)
- URL injection guard on REST API paths

### Fixed
- Entitlement verification during build — codesign step added to CI and release workflows
- Optimized logo asset size

---

## [0.1.1] — 2026-03-12

### Fixed
- MCP handshake failure caused by `AsyncStream` initialization timing
- GitHub repository URLs updated from personal account to `seayniclabs` organization

### Added
- 22 unit tests across 5 suites (server creation, tool registration, required parameters, version consistency, schema validation)
- GitHub Actions CI — build and test on push/PR to `main` (macOS 15, Swift 6.1)
- GitHub Actions release workflow — automated binary publishing on semver tags
- Codesign with entitlements in CI pipeline

---

## [0.1.0] — 2026-03-12

### Added
- Initial release of Stem — Apple Music MCP server for macOS
- **Catalog search:** `search_catalog` with query, type filter, and result limit
- **Song details:** `get_song_details` — full metadata (title, artist, album, duration, genre, release date)
- **Album details:** `get_album_details` — album info with complete track listing
- **Playback control:** `play_song`, `play_pause`, `skip_next`, `skip_previous`
- **Now playing:** `get_now_playing` — current track info and playback state
- **Queue management:** `get_queue`, `set_queue` — read or replace the playback queue
- **Library browsing:** `get_library_playlists`, `get_recently_played`
- **Playlist creation:** `create_playlist`, `add_to_playlist`
- **Health check:** `ping` — version and auth status
- Native Swift binary using MusicKit — no API keys, no browser auth flows
- `stem setup` command for first-time macOS permission grant
- Homebrew installation via `seayniclabs/tap/stem`
- Quickstart documentation page (`docs/index.html`)
- MIT license

---

[Unreleased]: https://github.com/seayniclabs/stem/compare/v0.1.2...HEAD
[0.1.2]: https://github.com/seayniclabs/stem/compare/v0.1.1...v0.1.2
[0.1.1]: https://github.com/seayniclabs/stem/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/seayniclabs/stem/releases/tag/v0.1.0
