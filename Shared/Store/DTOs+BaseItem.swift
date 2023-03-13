import Foundation
import JellyfinAPI

public extension Album {
    init(from item: BaseItemDto) {
        self.isDownloaded = false

        if let albumId = item.id {
            self.uuid = albumId
        } else {
            self.uuid = ""
        }

        if let albumName = item.name {
            self.name = albumName
        } else {
            self.name = ""
        }

        if let name = item.albumArtist {
            self.artistName = name
        } else {
            self.artistName = ""
        }

        if let isFavorite = item.userData?.isFavorite {
            self.isFavorite = isFavorite
        } else {
            self.isFavorite = false
        }

        self.songs = []
    }
}

public extension Song {
    init(from item: BaseItemDto) {
        self.isDownloaded = false

        if let songId = item.id {
            self.uuid = songId
        } else {
            self.uuid = ""
        }

        if let index = item.indexNumber {
            self.index = Int(index)
        } else {
            self.index = 0
        }

        if let songName = item.name {
            self.name = songName
        } else {
            self.name = ""
        }

        if let parentId = item.albumID {
            self.parentId = parentId
        } else {
            self.parentId = ""
        }

        if let isFavorite = item.userData?.isFavorite {
            self.isFavorite = isFavorite
        } else {
            self.isFavorite = false
        }
    }
}
