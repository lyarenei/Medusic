import Foundation
import JellyfinAPI

extension Album {
    init(from item: BaseItemDto) {
        self.uuid = item.id ?? ""
        self.name = item.name ?? ""
        self.artistName = item.albumArtist ?? ""
        self.isFavorite = item.userData?.isFavorite ?? false
        self.createdAt = item.dateCreated ?? Date()
    }
}

extension Song {
    init(from item: BaseItemDto) {
        self.uuid = item.id ?? ""
        self.index = Int(item.indexNumber ?? 0)
        self.name = item.name ?? ""
        self.parentId = item.albumID ?? item.parentID ?? ""
        self.isFavorite = item.userData?.isFavorite ?? false
        self.size = {
            guard let sources = item.mediaSources else { return 0 }
            var sum: UInt64 = 0
            for source in sources {
                sum += UInt64(source.size ?? 0)
            }

            return sum
        }()
        self.runtime = item.runTimeTicks?.timeInterval ?? 0
        self.albumDisc = Int(item.parentIndexNumber ?? 0)
    }
}
