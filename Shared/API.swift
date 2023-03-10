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
            albumService: DummyAlbumService(
                albums: [
                    Album(
                        uuid: "1",
                        name: "Nice album name",
                        artistName: "Album artist",
                        isDownloaded: false,
                        isLiked: true
                    ),
                    Album(
                        uuid: "2",
                        name: "Album with very long name that one gets tired reading it",
                        artistName: "Unamusing artist",
                        isDownloaded: true,
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
