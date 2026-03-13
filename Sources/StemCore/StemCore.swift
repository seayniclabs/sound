import MCP

/// Stem server metadata
public enum Stem {
    public static let serverName = "stem"
    public static let serverVersion = "0.1.1"

    /// All tool definitions for the Stem MCP server.
    /// Separated from the executable so they can be tested independently.
    public static let tools: [Tool] = [
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
            name: "get_song_details",
            description: "Get full details for a song by its Apple Music catalog ID",
            inputSchema: .object([
                "type": .string("object"),
                "properties": .object([
                    "id": .object([
                        "type": .string("string"),
                        "description": .string("Apple Music catalog song ID")
                    ])
                ]),
                "required": .array([.string("id")])
            ])
        ),
        Tool(
            name: "get_album_details",
            description: "Get full details for an album by its Apple Music catalog ID",
            inputSchema: .object([
                "type": .string("object"),
                "properties": .object([
                    "id": .object([
                        "type": .string("string"),
                        "description": .string("Apple Music catalog album ID")
                    ])
                ]),
                "required": .array([.string("id")])
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
            name: "play_song",
            description: "Play a specific song by its Apple Music catalog ID",
            inputSchema: .object([
                "type": .string("object"),
                "properties": .object([
                    "id": .object([
                        "type": .string("string"),
                        "description": .string("Apple Music catalog song ID")
                    ])
                ]),
                "required": .array([.string("id")])
            ])
        ),
        Tool(
            name: "get_queue",
            description: "Get the current playback queue",
            inputSchema: .object([
                "type": .string("object"),
                "properties": .object([:])
            ])
        ),
        Tool(
            name: "set_queue",
            description: "Set the playback queue to specific songs and start playing",
            inputSchema: .object([
                "type": .string("object"),
                "properties": .object([
                    "ids": .object([
                        "type": .string("array"),
                        "description": .string("Array of Apple Music catalog song IDs"),
                        "items": .object([
                            "type": .string("string")
                        ])
                    ])
                ]),
                "required": .array([.string("ids")])
            ])
        ),
        Tool(
            name: "get_library_playlists",
            description: "List the user's Apple Music library playlists",
            inputSchema: .object([
                "type": .string("object"),
                "properties": .object([
                    "limit": .object([
                        "type": .string("number"),
                        "description": .string("Max playlists to return (default 25)")
                    ])
                ])
            ])
        ),
        Tool(
            name: "get_recently_played",
            description: "Get recently played tracks",
            inputSchema: .object([
                "type": .string("object"),
                "properties": .object([
                    "limit": .object([
                        "type": .string("number"),
                        "description": .string("Max tracks to return (default 10)")
                    ])
                ])
            ])
        ),
        Tool(
            name: "create_playlist",
            description: "Create a new playlist in the user's Apple Music library",
            inputSchema: .object([
                "type": .string("object"),
                "properties": .object([
                    "name": .object([
                        "type": .string("string"),
                        "description": .string("Name for the new playlist")
                    ]),
                    "description": .object([
                        "type": .string("string"),
                        "description": .string("Optional description for the playlist")
                    ])
                ]),
                "required": .array([.string("name")])
            ])
        ),
        Tool(
            name: "add_to_playlist",
            description: "Add songs to an existing playlist by playlist ID",
            inputSchema: .object([
                "type": .string("object"),
                "properties": .object([
                    "playlist_id": .object([
                        "type": .string("string"),
                        "description": .string("The playlist's library ID")
                    ]),
                    "song_ids": .object([
                        "type": .string("array"),
                        "description": .string("Array of Apple Music catalog song IDs to add"),
                        "items": .object([
                            "type": .string("string")
                        ])
                    ])
                ]),
                "required": .array([.string("playlist_id"), .string("song_ids")])
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
    ]

    /// Expected tool names in registration order
    public static let toolNames: [String] = tools.map(\.name)

    /// The ping response text, including the current version
    public static var pingResponse: String {
        "Stem v\(serverVersion) is running. Apple Music is authorized."
    }
}
