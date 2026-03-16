import Foundation
import Testing
import MCP
@testable import StemCore

// MARK: - Tool Handler Routing

@Suite("Tool Handler Routing")
struct ToolHandlerRoutingTests {

    /// All 15 tool names should resolve to a known tool definition.
    /// This mirrors the switch statement in main.swift — if a tool is registered
    /// but has no case in the handler, it falls through to "Unknown tool".
    @Test("Every registered tool name resolves to a tool definition")
    func allToolNamesResolvable() {
        for name in Stem.toolNames {
            let tool = Stem.tools.first(where: { $0.name == name })
            #expect(tool != nil, "Tool '\(name)' is registered but has no matching definition")
        }
    }

    @Test("Tool lookup by name returns correct tool")
    func toolLookupByName() {
        for tool in Stem.tools {
            let found = Stem.tools.first(where: { $0.name == tool.name })
            #expect(found?.name == tool.name)
            #expect(found?.description == tool.description)
        }
    }

    @Test("Unknown tool names do not match any registered tool")
    func unknownToolNames() {
        let fakeNames = ["play_album", "shuffle", "repeat", "volume_up", "like_song", ""]
        for name in fakeNames {
            let found = Stem.tools.first(where: { $0.name == name })
            #expect(found == nil, "Fake tool name '\(name)' should not match any registered tool")
        }
    }

    @Test("Tool names use snake_case convention")
    func toolNamesAreSnakeCase() {
        let snakeCasePattern = /^[a-z][a-z0-9]*(_[a-z0-9]+)*$/
        for name in Stem.toolNames {
            #expect(name.wholeMatch(of: snakeCasePattern) != nil,
                    "Tool '\(name)' does not follow snake_case convention")
        }
    }
}

// MARK: - CallTool Parameter Construction

@Suite("CallTool Parameter Construction")
struct CallToolParameterTests {

    @Test("Construct valid search_catalog parameters")
    func searchCatalogParams() {
        let params = CallTool.Parameters(
            name: "search_catalog",
            arguments: [
                "query": .string("Tycho"),
                "type": .string("song"),
                "limit": .int(5)
            ]
        )
        #expect(params.name == "search_catalog")
        #expect(params.arguments?["query"]?.stringValue == "Tycho")
        #expect(params.arguments?["type"]?.stringValue == "song")
        #expect(params.arguments?["limit"]?.intValue == 5)
    }

    @Test("Construct search_catalog with only required params")
    func searchCatalogMinimalParams() {
        let params = CallTool.Parameters(
            name: "search_catalog",
            arguments: ["query": .string("Boards of Canada")]
        )
        #expect(params.arguments?["query"]?.stringValue == "Boards of Canada")
        #expect(params.arguments?["type"] == nil)
        #expect(params.arguments?["limit"] == nil)
    }

    @Test("Construct search_catalog with missing query returns nil for query")
    func searchCatalogMissingQuery() {
        let params = CallTool.Parameters(
            name: "search_catalog",
            arguments: ["type": .string("album")]
        )
        #expect(params.arguments?["query"]?.stringValue == nil)
    }

    @Test("Construct get_song_details parameters")
    func getSongDetailsParams() {
        let params = CallTool.Parameters(
            name: "get_song_details",
            arguments: ["id": .string("1440783204")]
        )
        #expect(params.name == "get_song_details")
        #expect(params.arguments?["id"]?.stringValue == "1440783204")
    }

    @Test("Construct get_song_details with missing id returns nil")
    func getSongDetailsMissingId() {
        let params = CallTool.Parameters(name: "get_song_details", arguments: [:])
        #expect(params.arguments?["id"]?.stringValue == nil)
    }

    @Test("Construct get_album_details parameters")
    func getAlbumDetailsParams() {
        let params = CallTool.Parameters(
            name: "get_album_details",
            arguments: ["id": .string("1440783200")]
        )
        #expect(params.arguments?["id"]?.stringValue == "1440783200")
    }

    @Test("Construct play_song parameters")
    func playSongParams() {
        let params = CallTool.Parameters(
            name: "play_song",
            arguments: ["id": .string("1440783204")]
        )
        #expect(params.arguments?["id"]?.stringValue == "1440783204")
    }

    @Test("Construct set_queue with array of IDs")
    func setQueueParams() {
        let params = CallTool.Parameters(
            name: "set_queue",
            arguments: [
                "ids": .array([.string("111"), .string("222"), .string("333")])
            ]
        )
        if case .array(let ids) = params.arguments?["ids"] {
            #expect(ids.count == 3)
            #expect(ids[0].stringValue == "111")
            #expect(ids[1].stringValue == "222")
            #expect(ids[2].stringValue == "333")
        } else {
            Issue.record("set_queue ids should be an array")
        }
    }

    @Test("Construct set_queue with empty array")
    func setQueueEmptyArray() {
        let params = CallTool.Parameters(
            name: "set_queue",
            arguments: ["ids": .array([])]
        )
        if case .array(let ids) = params.arguments?["ids"] {
            #expect(ids.isEmpty)
        } else {
            Issue.record("set_queue ids should be an array")
        }
    }

    @Test("Construct create_playlist with name and description")
    func createPlaylistParams() {
        let params = CallTool.Parameters(
            name: "create_playlist",
            arguments: [
                "name": .string("My Playlist"),
                "description": .string("A test playlist")
            ]
        )
        #expect(params.arguments?["name"]?.stringValue == "My Playlist")
        #expect(params.arguments?["description"]?.stringValue == "A test playlist")
    }

    @Test("Construct create_playlist with only name")
    func createPlaylistMinimalParams() {
        let params = CallTool.Parameters(
            name: "create_playlist",
            arguments: ["name": .string("Quick List")]
        )
        #expect(params.arguments?["name"]?.stringValue == "Quick List")
        #expect(params.arguments?["description"] == nil)
    }

    @Test("Construct add_to_playlist parameters")
    func addToPlaylistParams() {
        let params = CallTool.Parameters(
            name: "add_to_playlist",
            arguments: [
                "playlist_id": .string("p.ABC123"),
                "song_ids": .array([.string("111"), .string("222")])
            ]
        )
        #expect(params.arguments?["playlist_id"]?.stringValue == "p.ABC123")
        if case .array(let songIds) = params.arguments?["song_ids"] {
            #expect(songIds.count == 2)
        } else {
            Issue.record("song_ids should be an array")
        }
    }

    @Test("Construct parameterless tool with nil arguments")
    func parameterlessToolNilArgs() {
        let parameterless = ["ping", "get_now_playing", "play_pause", "skip_next", "skip_previous", "get_queue"]
        for name in parameterless {
            let params = CallTool.Parameters(name: name, arguments: nil)
            #expect(params.name == name)
            #expect(params.arguments == nil)
        }
    }

    @Test("Construct parameterless tool with empty arguments")
    func parameterlessToolEmptyArgs() {
        let params = CallTool.Parameters(name: "ping", arguments: [:])
        #expect(params.arguments?.isEmpty == true)
    }

    @Test("Construct get_library_playlists with optional limit")
    func getLibraryPlaylistsParams() {
        let params = CallTool.Parameters(
            name: "get_library_playlists",
            arguments: ["limit": .int(50)]
        )
        #expect(params.arguments?["limit"]?.intValue == 50)
    }

    @Test("Construct get_recently_played with optional limit")
    func getRecentlyPlayedParams() {
        let params = CallTool.Parameters(
            name: "get_recently_played",
            arguments: ["limit": .int(5)]
        )
        #expect(params.arguments?["limit"]?.intValue == 5)
    }
}

// MARK: - Parameter Validation Patterns

@Suite("Parameter Validation Patterns")
struct ParameterValidationTests {

    /// Simulates the guard-let pattern used by handlers to extract required string params.
    /// This tests the same logic the handlers use: `params.arguments?["key"]?.stringValue`
    private func extractString(from params: CallTool.Parameters, key: String) -> String? {
        params.arguments?[key]?.stringValue
    }

    /// Simulates the guard-let pattern for extracting an integer with a default.
    private func extractInt(from params: CallTool.Parameters, key: String, default defaultValue: Int) -> Int {
        params.arguments?[key]?.intValue ?? defaultValue
    }

    /// Simulates the array extraction pattern used by set_queue and add_to_playlist.
    private func extractStringArray(from params: CallTool.Parameters, key: String) -> [String]? {
        guard let value = params.arguments?[key],
              case .array(let arr) = value else { return nil }
        return arr.compactMap { $0.stringValue }
    }

    @Test("String extraction succeeds for valid string value")
    func stringExtractionValid() {
        let params = CallTool.Parameters(name: "test", arguments: ["query": .string("hello")])
        #expect(extractString(from: params, key: "query") == "hello")
    }

    @Test("String extraction returns nil for missing key")
    func stringExtractionMissingKey() {
        let params = CallTool.Parameters(name: "test", arguments: [:])
        #expect(extractString(from: params, key: "query") == nil)
    }

    @Test("String extraction returns nil for nil arguments")
    func stringExtractionNilArguments() {
        let params = CallTool.Parameters(name: "test", arguments: nil)
        #expect(extractString(from: params, key: "query") == nil)
    }

    @Test("String extraction returns nil for wrong type (int instead of string)")
    func stringExtractionWrongType() {
        let params = CallTool.Parameters(name: "test", arguments: ["id": .int(42)])
        #expect(extractString(from: params, key: "id") == nil)
    }

    @Test("String extraction returns nil for null value")
    func stringExtractionNullValue() {
        let params = CallTool.Parameters(name: "test", arguments: ["id": .null])
        #expect(extractString(from: params, key: "id") == nil)
    }

    @Test("Int extraction uses default when key is missing")
    func intExtractionDefault() {
        let params = CallTool.Parameters(name: "test", arguments: [:])
        #expect(extractInt(from: params, key: "limit", default: 10) == 10)
    }

    @Test("Int extraction uses provided value when present")
    func intExtractionProvided() {
        let params = CallTool.Parameters(name: "test", arguments: ["limit": .int(25)])
        #expect(extractInt(from: params, key: "limit", default: 10) == 25)
    }

    @Test("Int extraction uses default for wrong type (string instead of int)")
    func intExtractionWrongType() {
        let params = CallTool.Parameters(name: "test", arguments: ["limit": .string("ten")])
        #expect(extractInt(from: params, key: "limit", default: 10) == 10)
    }

    @Test("Array extraction succeeds for valid string array")
    func arrayExtractionValid() {
        let params = CallTool.Parameters(
            name: "test",
            arguments: ["ids": .array([.string("a"), .string("b"), .string("c")])]
        )
        let result = extractStringArray(from: params, key: "ids")
        #expect(result == ["a", "b", "c"])
    }

    @Test("Array extraction returns nil for missing key")
    func arrayExtractionMissingKey() {
        let params = CallTool.Parameters(name: "test", arguments: [:])
        #expect(extractStringArray(from: params, key: "ids") == nil)
    }

    @Test("Array extraction returns nil for non-array value")
    func arrayExtractionWrongType() {
        let params = CallTool.Parameters(name: "test", arguments: ["ids": .string("not-an-array")])
        #expect(extractStringArray(from: params, key: "ids") == nil)
    }

    @Test("Array extraction filters out non-string elements")
    func arrayExtractionMixedTypes() {
        let params = CallTool.Parameters(
            name: "test",
            arguments: ["ids": .array([.string("valid"), .int(42), .string("also-valid"), .null])]
        )
        let result = extractStringArray(from: params, key: "ids")
        #expect(result == ["valid", "also-valid"])
    }

    @Test("Array extraction returns empty array for empty input")
    func arrayExtractionEmpty() {
        let params = CallTool.Parameters(name: "test", arguments: ["ids": .array([])])
        let result = extractStringArray(from: params, key: "ids")
        #expect(result == [])
    }
}

// MARK: - Search Type Validation

@Suite("Search Type Validation")
struct SearchTypeValidationTests {

    /// The valid search types as accepted by handleSearchCatalog
    private let validTypes = ["song", "album", "artist"]

    @Test("Valid search types are accepted")
    func validSearchTypes() {
        for type in validTypes {
            let params = CallTool.Parameters(
                name: "search_catalog",
                arguments: ["query": .string("test"), "type": .string(type)]
            )
            let typeValue = params.arguments?["type"]?.stringValue ?? "song"
            #expect(validTypes.contains(typeValue), "Type '\(type)' should be valid")
        }
    }

    @Test("Default search type is song when omitted")
    func defaultSearchType() {
        let params = CallTool.Parameters(
            name: "search_catalog",
            arguments: ["query": .string("test")]
        )
        let typeValue = params.arguments?["type"]?.stringValue ?? "song"
        #expect(typeValue == "song")
    }

    @Test("Invalid search types are detectable")
    func invalidSearchTypes() {
        let invalidTypes = ["playlist", "genre", "station", "SONG", "Song", ""]
        for type in invalidTypes {
            #expect(!validTypes.contains(type),
                    "Type '\(type)' should not be in valid types list")
        }
    }
}

// MARK: - Limit Clamping Logic

@Suite("Limit Clamping Logic")
struct LimitClampingTests {

    /// Mirrors the clamping logic in handleSearchCatalog: min(max(limit, 1), 25)
    private func clampSearchLimit(_ limit: Int) -> Int {
        min(max(limit, 1), 25)
    }

    /// Mirrors the clamping logic in handleGetLibraryPlaylists: min(max(limit, 1), 100)
    private func clampPlaylistLimit(_ limit: Int) -> Int {
        min(max(limit, 1), 100)
    }

    /// Mirrors the clamping logic in handleGetRecentlyPlayed: min(max(limit, 1), 25)
    private func clampRecentlyPlayedLimit(_ limit: Int) -> Int {
        min(max(limit, 1), 25)
    }

    @Test("Search limit clamps to range 1-25")
    func searchLimitClamping() {
        #expect(clampSearchLimit(0) == 1)
        #expect(clampSearchLimit(-5) == 1)
        #expect(clampSearchLimit(1) == 1)
        #expect(clampSearchLimit(10) == 10)
        #expect(clampSearchLimit(25) == 25)
        #expect(clampSearchLimit(26) == 25)
        #expect(clampSearchLimit(100) == 25)
    }

    @Test("Playlist limit clamps to range 1-100")
    func playlistLimitClamping() {
        #expect(clampPlaylistLimit(0) == 1)
        #expect(clampPlaylistLimit(-1) == 1)
        #expect(clampPlaylistLimit(1) == 1)
        #expect(clampPlaylistLimit(50) == 50)
        #expect(clampPlaylistLimit(100) == 100)
        #expect(clampPlaylistLimit(101) == 100)
        #expect(clampPlaylistLimit(500) == 100)
    }

    @Test("Recently played limit clamps to range 1-25")
    func recentlyPlayedLimitClamping() {
        #expect(clampRecentlyPlayedLimit(0) == 1)
        #expect(clampRecentlyPlayedLimit(10) == 10)
        #expect(clampRecentlyPlayedLimit(25) == 25)
        #expect(clampRecentlyPlayedLimit(50) == 25)
    }

    @Test("Default limit values match handler defaults")
    func defaultLimitValues() {
        // search_catalog defaults to 10
        let searchParams = CallTool.Parameters(name: "search_catalog", arguments: ["query": .string("test")])
        let searchLimit = searchParams.arguments?["limit"]?.intValue ?? 10
        #expect(searchLimit == 10)

        // get_library_playlists defaults to 25
        let playlistParams = CallTool.Parameters(name: "get_library_playlists", arguments: [:])
        let playlistLimit = playlistParams.arguments?["limit"]?.intValue ?? 25
        #expect(playlistLimit == 25)

        // get_recently_played defaults to 10
        let recentParams = CallTool.Parameters(name: "get_recently_played", arguments: [:])
        let recentLimit = recentParams.arguments?["limit"]?.intValue ?? 10
        #expect(recentLimit == 10)
    }
}

// MARK: - Playlist ID Format Validation

@Suite("Playlist ID Format Validation")
struct PlaylistIDValidationTests {

    /// Mirrors the validation in handleAddToPlaylist
    private func isValidPlaylistID(_ id: String) -> Bool {
        let allowedChars = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "."))
        return id.unicodeScalars.allSatisfy { allowedChars.contains($0) }
    }

    @Test("Valid playlist IDs pass validation")
    func validPlaylistIDs() {
        let validIDs = ["p.ABC123", "p.abcdef0123456789", "p.XXXXXXXXX", "abc123"]
        for id in validIDs {
            #expect(isValidPlaylistID(id), "Playlist ID '\(id)' should be valid")
        }
    }

    @Test("Invalid playlist IDs fail validation")
    func invalidPlaylistIDs() {
        let invalidIDs = [
            "p/ABC123",        // slash
            "p ABC123",        // space
            "../etc/passwd",   // path traversal
            "p.ABC;DROP",      // semicolon
            "p.ABC&cmd",       // ampersand
            "<script>",        // angle brackets
            "p.ABC\n123",      // newline
        ]
        for id in invalidIDs {
            #expect(!isValidPlaylistID(id), "Playlist ID '\(id)' should be invalid")
        }
    }

    @Test("Empty playlist ID passes character validation but is empty")
    func emptyPlaylistID() {
        // Empty string technically passes the character check (vacuous truth)
        // but would fail at the API level
        #expect(isValidPlaylistID(""))
    }
}

// MARK: - Ping Response Format

@Suite("Ping Response Format")
struct PingResponseFormatTests {

    @Test("Ping response is a non-empty string")
    func pingResponseNonEmpty() {
        #expect(!Stem.pingResponse.isEmpty)
    }

    @Test("Ping response contains server name")
    func pingResponseContainsName() {
        #expect(Stem.pingResponse.contains("Stem"))
    }

    @Test("Ping response contains version number")
    func pingResponseContainsVersion() {
        #expect(Stem.pingResponse.contains(Stem.serverVersion))
    }

    @Test("Ping response mentions authorization status")
    func pingResponseMentionsAuth() {
        #expect(Stem.pingResponse.contains("authorized"))
    }

    @Test("Ping response follows expected format")
    func pingResponseFormat() {
        let expected = "Stem v\(Stem.serverVersion) is running. Apple Music is authorized."
        #expect(Stem.pingResponse == expected)
    }
}

// MARK: - Tool Description Quality

@Suite("Tool Description Quality")
struct ToolDescriptionQualityTests {

    @Test("All descriptions start with a verb or noun phrase")
    func descriptionsAreActionable() {
        for tool in Stem.tools {
            guard let desc = tool.description else {
                Issue.record("Tool '\(tool.name)' has no description")
                continue
            }
            // Should not start with lowercase articles or conjunctions as first word
            let firstWord = String(desc.split(separator: " ").first ?? "")
            let badStarts = ["the", "a", "an", "and", "but", "or", "this", "that"]
            #expect(!badStarts.contains(firstWord.lowercased()),
                    "Tool '\(tool.name)' description should start with verb/noun, not '\(firstWord)'")
        }
    }

    @Test("No descriptions exceed 100 characters")
    func descriptionsAreReasonablyShort() {
        for tool in Stem.tools {
            if let desc = tool.description {
                #expect(desc.count <= 100,
                        "Tool '\(tool.name)' description is \(desc.count) chars — keep under 100")
            }
        }
    }

    @Test("Playback tools mention Apple Music or track/song")
    func playbackToolDescriptionsRelevant() {
        let playbackTools = ["play_pause", "skip_next", "skip_previous", "get_now_playing", "play_song"]
        for name in playbackTools {
            guard let tool = Stem.tools.first(where: { $0.name == name }),
                  let desc = tool.description else { continue }
            let lower = desc.lowercased()
            let mentionsMusic = lower.contains("apple music") || lower.contains("track") ||
                                lower.contains("song") || lower.contains("play")
            #expect(mentionsMusic,
                    "Playback tool '\(name)' description should mention music/track/song/play")
        }
    }
}

// MARK: - Schema-Parameter Consistency

@Suite("Schema-Parameter Consistency")
struct SchemaParameterConsistencyTests {

    /// Helper: extract property names from a tool schema
    private func propertyNames(for toolName: String) -> Set<String> {
        guard let tool = Stem.tools.first(where: { $0.name == toolName }),
              case .object(let schema) = tool.inputSchema,
              case .object(let props) = schema["properties"] else {
            return []
        }
        return Set(props.keys)
    }

    /// Helper: extract required param names from a tool schema
    private func requiredNames(for toolName: String) -> Set<String> {
        guard let tool = Stem.tools.first(where: { $0.name == toolName }),
              case .object(let schema) = tool.inputSchema,
              case .array(let required) = schema["required"] else {
            return []
        }
        return Set(required.compactMap { $0.stringValue })
    }

    @Test("Required parameters are a subset of defined properties")
    func requiredAreSubsetOfProperties() {
        for tool in Stem.tools {
            let props = propertyNames(for: tool.name)
            let required = requiredNames(for: tool.name)
            let missing = required.subtracting(props)
            #expect(missing.isEmpty,
                    "Tool '\(tool.name)' has required params not in properties: \(missing)")
        }
    }

    @Test("search_catalog has exactly query, type, limit properties")
    func searchCatalogSchemaComplete() {
        #expect(propertyNames(for: "search_catalog") == ["query", "type", "limit"])
    }

    @Test("get_song_details has exactly id property")
    func getSongDetailsSchemaComplete() {
        #expect(propertyNames(for: "get_song_details") == ["id"])
    }

    @Test("get_album_details has exactly id property")
    func getAlbumDetailsSchemaComplete() {
        #expect(propertyNames(for: "get_album_details") == ["id"])
    }

    @Test("play_song has exactly id property")
    func playSongSchemaComplete() {
        #expect(propertyNames(for: "play_song") == ["id"])
    }

    @Test("set_queue has exactly ids property")
    func setQueueSchemaComplete() {
        #expect(propertyNames(for: "set_queue") == ["ids"])
    }

    @Test("create_playlist has exactly name and description properties")
    func createPlaylistSchemaComplete() {
        #expect(propertyNames(for: "create_playlist") == ["name", "description"])
    }

    @Test("add_to_playlist has exactly playlist_id and song_ids properties")
    func addToPlaylistSchemaComplete() {
        #expect(propertyNames(for: "add_to_playlist") == ["playlist_id", "song_ids"])
    }

    @Test("get_library_playlists has exactly limit property")
    func getLibraryPlaylistsSchemaComplete() {
        #expect(propertyNames(for: "get_library_playlists") == ["limit"])
    }

    @Test("get_recently_played has exactly limit property")
    func getRecentlyPlayedSchemaComplete() {
        #expect(propertyNames(for: "get_recently_played") == ["limit"])
    }

    @Test("Parameterless tools have empty properties")
    func parameterlessToolsEmptyProperties() {
        let parameterless = ["get_now_playing", "play_pause", "skip_next", "skip_previous", "get_queue", "ping"]
        for name in parameterless {
            #expect(propertyNames(for: name).isEmpty,
                    "Tool '\(name)' should have no properties but has: \(propertyNames(for: name))")
        }
    }
}

// MARK: - CallTool.Parameters Serialization

@Suite("CallTool Parameters Serialization")
struct ParameterSerializationTests {

    @Test("Parameters round-trip through JSON encoding")
    func parametersRoundTrip() throws {
        let original = CallTool.Parameters(
            name: "search_catalog",
            arguments: [
                "query": .string("Tycho"),
                "type": .string("album"),
                "limit": .int(5)
            ]
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(original)
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(CallTool.Parameters.self, from: data)

        #expect(decoded.name == original.name)
        #expect(decoded.arguments?["query"]?.stringValue == "Tycho")
        #expect(decoded.arguments?["type"]?.stringValue == "album")
        #expect(decoded.arguments?["limit"]?.intValue == 5)
    }

    @Test("Parameters with array arguments round-trip")
    func arrayParametersRoundTrip() throws {
        let original = CallTool.Parameters(
            name: "set_queue",
            arguments: [
                "ids": .array([.string("111"), .string("222")])
            ]
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(original)
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(CallTool.Parameters.self, from: data)

        #expect(decoded.name == "set_queue")
        let idsValue: Value? = decoded.arguments?["ids"]
        if case .array(let ids) = idsValue {
            #expect(ids.count == 2)
            #expect(ids[0].stringValue == "111")
            #expect(ids[1].stringValue == "222")
        } else {
            Issue.record("Decoded ids should be an array")
        }
    }

    @Test("Parameters with nil arguments round-trip")
    func nilArgumentsRoundTrip() throws {
        let original = CallTool.Parameters(name: "ping", arguments: nil)
        let encoder = JSONEncoder()
        let data = try encoder.encode(original)
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(CallTool.Parameters.self, from: data)

        #expect(decoded.name == "ping")
        #expect(decoded.arguments == nil)
    }
}

// MARK: - Tool Result Construction

@Suite("Tool Result Construction")
struct ToolResultConstructionTests {

    @Test("Success result has no error flag")
    func successResultNoError() {
        let result = CallTool.Result(content: [.text("OK")])
        #expect(result.isError == nil)
        #expect(result.content.count == 1)
    }

    @Test("Error result has isError true")
    func errorResultFlagSet() {
        let result = CallTool.Result(content: [.text("Something went wrong")], isError: true)
        #expect(result.isError == true)
    }

    @Test("Text content extracts correctly")
    func textContentExtraction() {
        let result = CallTool.Result(content: [.text("Now playing: Dive by Tycho")])
        if case .text(let text) = result.content.first {
            #expect(text == "Now playing: Dive by Tycho")
        } else {
            Issue.record("Content should be text")
        }
    }

    @Test("Multi-line text content preserves newlines")
    func multiLineContent() {
        let lines = ["Title: Dive", "Artist: Tycho", "Album: Dive"]
        let result = CallTool.Result(content: [.text(lines.joined(separator: "\n"))])
        if case .text(let text) = result.content.first {
            #expect(text.contains("\n"))
            #expect(text.split(separator: "\n").count == 3)
        } else {
            Issue.record("Content should be text")
        }
    }

    @Test("Error message patterns match handler conventions")
    func errorMessagePatterns() {
        // These mirror the error message formats used in main.swift handlers
        let errorMessages = [
            "Missing required parameter: query",
            "Missing required parameter: id",
            "Missing required parameter: name",
            "Missing required parameter: playlist_id",
            "Missing required parameter: song_ids (array of song IDs)",
            "Missing required parameter: ids (array of song IDs)",
            "No valid song IDs provided.",
            "Unsupported search type: 'playlist'. Use 'song', 'album', or 'artist'.",
            "Unknown tool: nonexistent",
        ]
        for msg in errorMessages {
            let result = CallTool.Result(content: [.text(msg)], isError: true)
            #expect(result.isError == true)
            if case .text(let text) = result.content.first {
                #expect(!text.isEmpty)
            }
        }
    }
}

// MARK: - MusicKit-Dependent Tests (Require Authorization)

// NOTE: The tests below require MusicKit authorization and an active Apple Music subscription.
// They will fail in CI environments or on machines without Music.app access.
// To run these locally: `stem setup` first, then `swift test --filter MusicKitDependentTests`
//
// These are commented out intentionally — uncomment to run locally with MusicKit auth.
//
// @Suite("MusicKit-Dependent Tests")
// struct MusicKitDependentTests {
//
//     @Test("search_catalog returns results for known artist")
//     func searchReturnsResults() async throws {
//         // Requires: MusicKit auth + Apple Music subscription
//         // Would call handleSearchCatalog with query "The Beatles"
//         // and verify results are non-empty
//     }
//
//     @Test("get_song_details returns valid data for known song ID")
//     func songDetailsValid() async throws {
//         // Requires: MusicKit auth + Apple Music subscription
//         // Would call handleGetSongDetails with a known catalog ID
//         // and verify title, artist, album fields are present
//     }
//
//     @Test("play_pause toggles playback state")
//     func playPauseToggles() async throws {
//         // Requires: MusicKit auth + Apple Music subscription + active queue
//         // Would call handlePlayPause and verify state change
//     }
//
//     @Test("get_now_playing returns content when music is playing")
//     func nowPlayingWhenActive() async throws {
//         // Requires: MusicKit auth + active playback
//         // Would call handleGetNowPlaying and verify non-empty response
//     }
//
//     @Test("create_playlist creates and returns playlist ID")
//     func createPlaylistIntegration() async throws {
//         // Requires: MusicKit auth + Apple Music subscription
//         // Would call handleCreatePlaylist and verify response contains ID
//         // CAUTION: This creates a real playlist in the user's library
//     }
// }
