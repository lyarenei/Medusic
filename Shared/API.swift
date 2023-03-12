import Foundation
import SwiftUI
import JellyfinAPI

struct API {
    let albumService: any AlbumService
    let songService: any SongService
    let imageService: any ImageService
    let systemService: any SystemService
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
                        isFavorite: true
                    ),
                    Album(
                        uuid: "2",
                        name: "Album with very long name that one gets tired reading it",
                        artistName: "Unamusing artist",
                        isDownloaded: true
                    ),
                ]
            ),
            songService: DummySongService(
                songs: [
                    // Songs for album 1
                    Song(
                        uuid: "1",
                        index: 1,
                        name: "Song name 1",
                        parentId: "1",
                        isDownloaded: true
                    ),
                    Song(
                        uuid: "2",
                        index: 2,
                        name: "Song name 2 but this one has very long name",
                        parentId: "1",
                        isDownloaded: true
                    ),
                    // Songs for album 2
                    Song(
                        uuid: "3",
                        index: 1,
                        name: "Song name 3",
                        parentId: "2",
                        isDownloaded: true
                    ),
                    Song(
                        uuid: "4",
                        index: 2,
                        name: "Song name 4 but this one has very long name",
                        parentId: "2",
                        isDownloaded: true
                    ),
                ]
            ),
            imageService: DummyImageService(),
            systemService: MockSystemService()
        )
    }
}

extension EnvironmentValues {
    var api: API {
        get { self[APIEnvironmentKey.self] }
        set { self[APIEnvironmentKey.self] = newValue }
    }
}
