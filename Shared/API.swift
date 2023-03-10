import Foundation
import SwiftUI
import JellyfinAPI

struct API {
    let albumService: any AlbumService
    let songService: any SongService
}

private struct APIEnvironmentKey: EnvironmentKey {
    static let defaultValue: API = .preview
}

extension API {
    static var preview: API {
        API(
            albumService: FakeAlbumService(
                albums: [
                    // TODO: Add some more preview albums.
                    Album(
                        uuid: "1",
                        name: "Very nice album.",
                        artistName: "yo mama",
                        isDownloaded: false,
                        isLiked: false
                    ),
                    Album(
                        uuid: "2",
                        name: "Another nice album.",
                        artistName: "yo tata",
                        isDownloaded: false,
                        isLiked: false
                    ),
                ]
            ),
            songService: DummySongService(
                songs: [
                    Song(
                        uuid: "1",
                        index: 1,
                        name: "Song name 1"
                    ),
                    Song(
                        uuid: "2",
                        index: 2,
                        name: "Song name 2 but this one has very long name"
                    ),
                    Song(
                        uuid: "3",
                        index: 3,
                        name: "Song name 3"
                    )
                ]
            )
        )
    }
}

extension EnvironmentValues {
    var api: API {
        get { self[APIEnvironmentKey.self] }
        set { self[APIEnvironmentKey.self] = newValue }
    }
}
