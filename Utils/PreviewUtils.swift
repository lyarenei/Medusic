import Foundation

#if DEBUG
// swiftlint:disable all
// swiftformat:disable all
struct PreviewUtils {
    static var libraryRepo: LibraryRepository {
        LibraryRepository(
            artistStore: .previewStore(items: PreviewData.artists, cacheIdentifier: \.id),
            albumStore: .previewStore(items: PreviewData.albums, cacheIdentifier: \.id),
            songStore: .previewStore(items: PreviewData.songs, cacheIdentifier: \.id),
            apiClient: .init(previewEnabled: true)
        )
    }

    static var libraryRepoEmpty: LibraryRepository {
        LibraryRepository(
            artistStore: .previewStore(items: [], cacheIdentifier: \.id),
            albumStore: .previewStore(items: [], cacheIdentifier: \.id),
            songStore: .previewStore(items: [], cacheIdentifier: \.id),
            apiClient: .init(previewEnabled: true)
        )
    }

    static var player: MusicPlayer {
        MusicPlayer(
            preview: true,
            apiClient: .init(previewEnabled: true)
        )
    }
}
// swiftformat:enable all
// swiftlint:enable all
#endif
