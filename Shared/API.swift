import Foundation
import SwiftUI
import JellyfinAPI

struct API {
    let albumService: any AlbumService
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
                    AlbumInfo(albumArtists: ["yo mama"], indexNumber: 1, name: "Very nice album."),
                    AlbumInfo(albumArtists: ["yo tata"], indexNumber: 2, name: "Another nice album."),
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
