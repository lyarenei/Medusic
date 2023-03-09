import Foundation
import JellyfinAPI

protocol AlbumService: ObservableObject {
    func getAlbums() async throws -> [AlbumInfo]
}
