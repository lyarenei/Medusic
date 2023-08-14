import Foundation
import JellyfinAPI

struct Album: JellyfinItem {
    var id: String
    var name: String
    var sortName: String
    var artistId: String
    var isFavorite: Bool
    var createdAt = Date.now
    var artistName = ""
}

extension Album: Equatable {
    public static func == (lhs: Album, rhs: Album) -> Bool {
        lhs.id == rhs.id
    }
}

extension Album {
    init?(from item: BaseItemDto?) {
        guard let item else { return nil }
        guard let id = item.id,
              let name = item.name,
              let artist = item.albumArtists?.first,
              let artistId = artist.id,
              let artistName = artist.name
        else { return nil }

        self.id = id
        self.name = name
        self.artistId = artistId
        self.artistName = artistName

        self.isFavorite = item.userData?.isFavorite ?? false
        self.createdAt = item.dateCreated ?? Date.now
        self.sortName = item.sortName ?? name
    }
}
