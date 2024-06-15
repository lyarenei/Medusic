#if DEBUG

// swiftlint:disable all
// swiftformat:disable all

import Foundation
import UIKit

struct PreviewData {
    private static let formatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy/MM/dd"
        return df
    }()

    private static func loadJson<T>(assetName: String, ofType: T.Type) -> T where T: Decodable {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(formatter)

        let asset = NSDataAsset(name: assetName)!
        return try! decoder.decode(T.self, from: asset.data)
    }

    static let artists = loadJson(assetName: "Artists", ofType: [ArtistDto].self)
    static let artist = artists.first!

    static let albums = loadJson(assetName: "Albums", ofType: [AlbumDto].self)
    static let album = albums.first!

    static let songs = loadJson(assetName: "Songs", ofType: [SongDto].self)
    static let song = songs.first!
}

// swiftlint:enable all
// swiftformat:enable all

#endif
