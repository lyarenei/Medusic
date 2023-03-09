import Foundation
import JellyfinAPI

public struct Album {

    public var uuid: String
    public var name: String
    public var artistName: String

    public init(
        uuid: String,
        name: String,
        artistName: String
    ) {
        self.uuid = uuid
        self.name = name
        self.artistName = artistName
    }

    public init(from item: BaseItemDto) {
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
    }
}


public struct Song {

    public var uuid: String
    public var index: Int
    public var name: String

    public init(
        uuid: String,
        index: Int,
        name: String
    ) {
        self.uuid = uuid
        self.index = index
        self.name = name
    }

    public init(from item: BaseItemDto) {
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
    }
}