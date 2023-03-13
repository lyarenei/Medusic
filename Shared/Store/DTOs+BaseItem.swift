import Foundation
import JellyfinAPI

public extension Album {
    init(from item: BaseItemDto) {
        self.uuid = item.id ?? ""
        self.name = item.name ?? ""
        self.artistName = item.albumArtist ?? ""
        self.isFavorite = item.userData?.isFavorite ?? false
        self.isDownloaded = false

        // TODO: to be removed
        self.songs = []
    }
}

public extension Song {
    init(from item: BaseItemDto) {
        self.uuid = item.id ?? ""
        self.index = Int(item.indexNumber ?? 0)
        self.name = item.name ?? ""
        self.parentId = item.albumID ?? item.parentID ?? ""
        self.isFavorite = item.userData?.isFavorite ?? false
        self.isDownloaded = false
    }
}
