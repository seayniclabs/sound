import Foundation
import MCP
import MusicKit

// MARK: - Entry Point

let args = CommandLine.arguments

if args.contains("setup") {
    await runSetup()
} else {
    do {
        try await startServer()
    } catch {
        FileHandle.standardError.write(Data("Stem error: \(error)\n".utf8))
        exit(1)
    }
}

// MARK: - Setup Command

func runSetup() async {
    let binary = args[0]

    print("""

    Stem — Apple Music for your AI tools
    by Seaynic Labs

    """)

    let status = await MusicAuthorization.request()

    switch status {
    case .authorized:
        print("✓ Apple Music access granted\n")
    case .denied:
        print("✗ Apple Music access denied.")
        print("  Grant access in System Settings → Privacy & Security → Media & Apple Music\n")
        exit(1)
    case .restricted:
        print("✗ Apple Music access is restricted on this device.\n")
        exit(1)
    case .notDetermined:
        print("✗ Authorization was not determined. Try again.\n")
        exit(1)
    @unknown default:
        print("✗ Unknown authorization status.\n")
        exit(1)
    }

    print("""
    Add Stem to Claude Code:

      claude mcp add stem -- \(binary) serve

    Or add manually to ~/.claude.json:

      {
        "mcpServers": {
          "stem": {
            "command": "\(binary)",
            "args": ["serve"]
          }
        }
      }

    Setup complete. Try: "Search Apple Music for Tycho"
    """)
}

// MARK: - MCP Server

func startServer() async throws {
    // Check MusicKit authorization
    let authStatus = MusicAuthorization.currentStatus
    if authStatus != .authorized {
        let newStatus = await MusicAuthorization.request()
        guard newStatus == .authorized else {
            FileHandle.standardError.write(
                Data("Stem: Apple Music not authorized. Run 'stem setup' first.\n".utf8)
            )
            exit(1)
        }
    }

    let server = Server(
        name: "stem",
        version: "0.1.0",
        capabilities: Server.Capabilities(
            tools: .init()
        )
    )

    // Register tool list handler
    await server.withMethodHandler(ListTools.self) { _ in
        .init(tools: [
            Tool(
                name: "search_catalog",
                description: "Search the Apple Music catalog for songs, albums, or artists",
                inputSchema: .object([
                    "type": .string("object"),
                    "properties": .object([
                        "query": .object([
                            "type": .string("string"),
                            "description": .string("Search query")
                        ]),
                        "type": .object([
                            "type": .string("string"),
                            "description": .string("Type to search: song, album, or artist. Defaults to song.")
                        ]),
                        "limit": .object([
                            "type": .string("number"),
                            "description": .string("Max results to return (1-25, default 10)")
                        ])
                    ]),
                    "required": .array([.string("query")])
                ])
            ),
            Tool(
                name: "get_now_playing",
                description: "Get the currently playing track in Apple Music",
                inputSchema: .object([
                    "type": .string("object"),
                    "properties": .object([:])
                ])
            ),
            Tool(
                name: "play_pause",
                description: "Toggle play/pause on Apple Music",
                inputSchema: .object([
                    "type": .string("object"),
                    "properties": .object([:])
                ])
            ),
            Tool(
                name: "skip_next",
                description: "Skip to the next track",
                inputSchema: .object([
                    "type": .string("object"),
                    "properties": .object([:])
                ])
            ),
            Tool(
                name: "skip_previous",
                description: "Go back to the previous track",
                inputSchema: .object([
                    "type": .string("object"),
                    "properties": .object([:])
                ])
            ),
            Tool(
                name: "ping",
                description: "Check if Stem is running and Apple Music is authorized",
                inputSchema: .object([
                    "type": .string("object"),
                    "properties": .object([:])
                ])
            )
        ])
    }

    // Register tool call handler
    await server.withMethodHandler(CallTool.self) { params in
        switch params.name {
        case "ping":
            return .init(content: [.text("Stem v0.1.0 is running. Apple Music is authorized.")])

        case "search_catalog":
            return try await handleSearchCatalog(params: params)

        case "get_now_playing":
            return await handleGetNowPlaying()

        case "play_pause":
            return await handlePlayPause()

        case "skip_next":
            return await handleSkipNext()

        case "skip_previous":
            return await handleSkipPrevious()

        default:
            return .init(content: [.text("Unknown tool: \(params.name)")], isError: true)
        }
    }

    // Start stdio transport
    let transport = StdioTransport()
    try await server.start(transport: transport)

    // Keep the server alive
    try await Task.sleep(for: .seconds(Double.greatestFiniteMagnitude))
}

// MARK: - Tool Handlers

func handleSearchCatalog(params: CallTool.Parameters) async throws -> CallTool.Result {
    guard let query = params.arguments?["query"]?.stringValue else {
        return .init(content: [.text("Missing required parameter: query")], isError: true)
    }

    let limit = params.arguments?["limit"]?.intValue ?? 10
    let typeStr = params.arguments?["type"]?.stringValue ?? "song"
    let clampedLimit = min(max(limit, 1), 25)

    var results: [String] = []

    switch typeStr {
    case "album":
        var request = MusicCatalogSearchRequest(term: query, types: [Album.self])
        request.limit = clampedLimit
        let response = try await request.response()
        for album in response.albums {
            results.append("[\(album.id)] \(album.title) by \(album.artistName) (\(album.releaseDate?.formatted(.dateTime.year()) ?? "unknown"))")
        }

    case "artist":
        var request = MusicCatalogSearchRequest(term: query, types: [Artist.self])
        request.limit = clampedLimit
        let response = try await request.response()
        for artist in response.artists {
            results.append("[\(artist.id)] \(artist.name)")
        }

    default:
        var request = MusicCatalogSearchRequest(term: query, types: [Song.self])
        request.limit = clampedLimit
        let response = try await request.response()
        for song in response.songs {
            results.append("[\(song.id)] \(song.title) by \(song.artistName) — \(song.albumTitle ?? "unknown album")")
        }
    }

    if results.isEmpty {
        return .init(content: [.text("No results found for '\(query)'")])
    }

    return .init(content: [.text(results.joined(separator: "\n"))])
}

func handleGetNowPlaying() async -> CallTool.Result {
    let player = ApplicationMusicPlayer.shared

    guard let entry = player.queue.currentEntry else {
        return .init(content: [.text("Nothing is currently playing.")])
    }

    let state = player.state.playbackStatus == .playing ? "Playing" : "Paused"

    if case .song(let song) = entry.item {
        return .init(content: [.text("\(state): \(song.title) by \(song.artistName) — \(song.albumTitle ?? "")")])
    }

    return .init(content: [.text("\(state): \(entry.title)")])
}

func handlePlayPause() async -> CallTool.Result {
    let player = ApplicationMusicPlayer.shared

    do {
        if player.state.playbackStatus == .playing {
            player.pause()
            return .init(content: [.text("Paused.")])
        } else {
            try await player.play()
            return .init(content: [.text("Playing.")])
        }
    } catch {
        return .init(content: [.text(playbackErrorMessage(error))], isError: true)
    }
}

func handleSkipNext() async -> CallTool.Result {
    let player = ApplicationMusicPlayer.shared
    do {
        try await player.skipToNextEntry()
        // Small delay for the queue to update
        try? await Task.sleep(for: .milliseconds(200))
        return await handleGetNowPlaying()
    } catch {
        return .init(content: [.text(playbackErrorMessage(error))], isError: true)
    }
}

func handleSkipPrevious() async -> CallTool.Result {
    let player = ApplicationMusicPlayer.shared
    do {
        try await player.skipToPreviousEntry()
        try? await Task.sleep(for: .milliseconds(200))
        return await handleGetNowPlaying()
    } catch {
        return .init(content: [.text(playbackErrorMessage(error))], isError: true)
    }
}

// MARK: - Error Handling

func playbackErrorMessage(_ error: Error) -> String {
    let message = error.localizedDescription.lowercased()

    if message.contains("subscription") || message.contains("not subscribed") || message.contains("offer") {
        return "Playback requires an active Apple Music subscription. Catalog search and library access still work without one."
    }

    if message.contains("queue") || message.contains("empty") {
        return "Nothing in the playback queue. Try playing a specific song first."
    }

    return "Playback error: \(error.localizedDescription)"
}
