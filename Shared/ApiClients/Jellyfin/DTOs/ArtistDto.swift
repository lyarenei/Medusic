import Foundation
import JellyfinAPI

struct ArtistDto: JellyfinItem {
    var id: String
    var name = ""
    var sortName = ""
    var isFavorite = false
    var about = ""
    var createdAt = Date.now
}

extension ArtistDto: Equatable {
    static func == (lhs: ArtistDto, rhs: ArtistDto) -> Bool {
        lhs.id == rhs.id
    }
}

extension ArtistDto {
    init?(from item: BaseItemDto?) {
        guard let item else { return nil }
        guard let id = item.id, let name = item.name else { return nil }

        self.id = id
        self.name = name
        self.sortName = item.sortName ?? name
        self.isFavorite = item.userData?.isFavorite ?? false
        self.about = item.overview ?? .empty
        self.createdAt = item.dateCreated ?? .now
    }
}