import Testing
import MCP
@testable import StemCore

// MARK: - Server Creation

@Suite("Server Creation")
struct ServerCreationTests {

    @Test("Server initializes with correct name and version")
    func serverNameAndVersion() async {
        let server = Server(
            name: Stem.serverName,
            version: Stem.serverVersion,
            capabilities: Server.Capabilities(tools: .init())
        )

        #expect(server.name == "stem")
        #expect(server.version == "0.1.1")
    }

    @Test("Server declares tools capability")
    func serverCapabilities() async {
        let capabilities = Server.Capabilities(tools: .init())
        #expect(capabilities.tools != nil)
        #expect(capabilities.resources == nil)
        #expect(capabilities.prompts == nil)
    }
}

// MARK: - Tool Registration

@Suite("Tool Registration")
struct ToolRegistrationTests {

    @Test("All 15 tools are defined")
    func toolCount() {
        #expect(Stem.tools.count == 15)
    }

    @Test("Tool names match expected set")
    func toolNames() {
        let expected: Set<String> = [
            "search_catalog",
            "get_song_details",
            "get_album_details",
            "get_now_playing",
            "play_pause",
            "skip_next",
            "skip_previous",
            "play_song",
            "get_queue",
            "set_queue",
            "get_library_playlists",
            "get_recently_played",
            "create_playlist",
            "add_to_playlist",
            "ping"
        ]

        let actual = Set(Stem.toolNames)
        #expect(actual == expected)
    }

    @Test("Every tool has a description")
    func allToolsHaveDescriptions() {
        for tool in Stem.tools {
            #expect(tool.description != nil, "Tool '\(tool.name)' is missing a description")
            #expect(tool.description?.isEmpty == false, "Tool '\(tool.name)' has an empty description")
        }
    }

    @Test("Every tool has an object input schema")
    func allToolsHaveObjectSchemas() {
        for tool in Stem.tools {
            if case .object(let schema) = tool.inputSchema {
                // Should have "type": "object"
                if case .string(let typeValue) = schema["type"] {
                    #expect(typeValue == "object", "Tool '\(tool.name)' schema type should be 'object'")
                } else {
                    Issue.record("Tool '\(tool.name)' schema missing 'type' key")
                }

                // Should have "properties"
                #expect(schema["properties"] != nil, "Tool '\(tool.name)' schema missing 'properties' key")
            } else {
                Issue.record("Tool '\(tool.name)' inputSchema is not an object")
            }
        }
    }

    @Test("No duplicate tool names")
    func noDuplicateNames() {
        let names = Stem.toolNames
        let unique = Set(names)
        #expect(names.count == unique.count, "Duplicate tool names found")
    }
}

// MARK: - Required Parameters

@Suite("Required Parameters")
struct RequiredParameterTests {

    /// Helper to extract the "required" array from a tool's inputSchema
    private func requiredParams(for toolName: String) -> [String] {
        guard let tool = Stem.tools.first(where: { $0.name == toolName }),
              case .object(let schema) = tool.inputSchema,
              case .array(let required) = schema["required"] else {
            return []
        }
        return required.compactMap { if case .string(let s) = $0 { return s } else { return nil } }
    }

    @Test("search_catalog requires 'query'")
    func searchCatalogRequired() {
        #expect(requiredParams(for: "search_catalog") == ["query"])
    }

    @Test("get_song_details requires 'id'")
    func getSongDetailsRequired() {
        #expect(requiredParams(for: "get_song_details") == ["id"])
    }

    @Test("get_album_details requires 'id'")
    func getAlbumDetailsRequired() {
        #expect(requiredParams(for: "get_album_details") == ["id"])
    }

    @Test("play_song requires 'id'")
    func playSongRequired() {
        #expect(requiredParams(for: "play_song") == ["id"])
    }

    @Test("set_queue requires 'ids'")
    func setQueueRequired() {
        #expect(requiredParams(for: "set_queue") == ["ids"])
    }

    @Test("create_playlist requires 'name'")
    func createPlaylistRequired() {
        #expect(requiredParams(for: "create_playlist") == ["name"])
    }

    @Test("add_to_playlist requires 'playlist_id' and 'song_ids'")
    func addToPlaylistRequired() {
        let required = requiredParams(for: "add_to_playlist")
        #expect(required.contains("playlist_id"))
        #expect(required.contains("song_ids"))
        #expect(required.count == 2)
    }

    @Test("Parameterless tools have no required fields")
    func parameterlessToolsNoRequired() {
        let parameterless = ["get_now_playing", "play_pause", "skip_next", "skip_previous", "get_queue", "ping"]
        for name in parameterless {
            let required = requiredParams(for: name)
            #expect(required.isEmpty, "Tool '\(name)' should have no required parameters, but has: \(required)")
        }
    }

    @Test("Optional-only tools have no required fields")
    func optionalOnlyToolsNoRequired() {
        let optionalOnly = ["get_library_playlists", "get_recently_played"]
        for name in optionalOnly {
            let required = requiredParams(for: name)
            #expect(required.isEmpty, "Tool '\(name)' should have no required parameters")
        }
    }
}

// MARK: - Version Consistency

@Suite("Version Consistency")
struct VersionTests {

    @Test("Ping response includes current version")
    func pingResponseIncludesVersion() {
        let response = Stem.pingResponse
        #expect(response.contains(Stem.serverVersion))
        #expect(response.contains("Stem v\(Stem.serverVersion)"))
    }

    @Test("Server name is 'stem'")
    func serverNameCorrect() {
        #expect(Stem.serverName == "stem")
    }

    @Test("Version follows semver format")
    func versionFormat() {
        let parts = Stem.serverVersion.split(separator: ".")
        #expect(parts.count == 3, "Version should have major.minor.patch format")
        for part in parts {
            #expect(Int(part) != nil, "Version component '\(part)' should be numeric")
        }
    }
}

// MARK: - Tool Schema Details

@Suite("Tool Schema Details")
struct SchemaDetailTests {

    /// Helper to get properties dict from a tool
    private func properties(for toolName: String) -> [String: Value]? {
        guard let tool = Stem.tools.first(where: { $0.name == toolName }),
              case .object(let schema) = tool.inputSchema,
              case .object(let props) = schema["properties"] else {
            return nil
        }
        return props
    }

    @Test("search_catalog has query, type, and limit properties")
    func searchCatalogProperties() {
        let props = properties(for: "search_catalog")
        #expect(props != nil)
        #expect(props?["query"] != nil)
        #expect(props?["type"] != nil)
        #expect(props?["limit"] != nil)
    }

    @Test("set_queue ids property is typed as array")
    func setQueueIdsIsArray() {
        guard let props = properties(for: "set_queue"),
              case .object(let idsSchema) = props["ids"],
              case .string(let typeValue) = idsSchema["type"] else {
            Issue.record("Could not extract ids schema from set_queue")
            return
        }
        #expect(typeValue == "array")
    }

    @Test("add_to_playlist song_ids property is typed as array")
    func addToPlaylistSongIdsIsArray() {
        guard let props = properties(for: "add_to_playlist"),
              case .object(let songIdsSchema) = props["song_ids"],
              case .string(let typeValue) = songIdsSchema["type"] else {
            Issue.record("Could not extract song_ids schema from add_to_playlist")
            return
        }
        #expect(typeValue == "array")
    }
}
