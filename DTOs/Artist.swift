import Foundation
import JellyfinAPI

struct Artist: JellyfinItem {
    var id: String
    var name = ""
    var sortName = ""
    var isFavorite = false
}

extension Artist: Equatable {
    static func == (lhs: Artist, rhs: Artist) -> Bool {
        lhs.id == rhs.id
    }
}

extension Artist {
    init?(from item: BaseItemDto?) {
        guard let item else { return nil }
        guard let id = item.id, let name = item.name else { return nil }

        self.id = id
        self.name = name
        self.sortName = item.sortName ?? name
        self.isFavorite = item.userData?.isFavorite ?? false
    }
}
