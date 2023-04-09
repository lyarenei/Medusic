import SwiftUI

extension Array where Element == Album {
    /// Get album by specified album ID.
    func getById(_ albumId: String) -> Album? {
        first { album -> Bool in
            album.uuid == albumId
        }
    }

    var favorite: [Album] {
        filter(\.isFavorite)
    }

    // TODO: only temporary for consistency, until user can configure sort options
    var consistent: [Album] {
        sorted { lhs, rhs -> Bool in lhs.uuid < rhs.uuid }
    }
}

extension Array where Element == Song {
    /// Sorts songs by album ID, then by their order.
    /// This results in songs being grouped by their albums, and in correct order in that album.
    func sortByAlbum() -> [Song] {
        sorted { lhs, rhs -> Bool in
            // Sort by album ID, then by index
            if lhs.parentId < rhs.parentId { return true }
            if lhs.parentId > rhs.parentId { return false }
            if lhs.parentId == rhs.parentId {
                return lhs.index < rhs.index
            }

            return false
        }
    }

    /// Get only songs which belong to Album specified by its ID.
    /// These songs are sorted by their order in that album.
    func filterByAlbum(id albumId: String) -> [Song] {
        let filteredSongs = filter { song -> Bool in
            song.parentId == albumId
        }

        return filteredSongs.sortByAlbum()
    }

    /// Get song by specified song ID.
    func getById(_ songId: String) -> Song? {
        first { song -> Bool in
            song.uuid == songId
        }
    }
}

extension ScrollView {
    private typealias PaddedContent = ModifiedContent<Content, _PaddingLayout>

    /// Fixes flickering on navigation view when scrolling up with not enough content to need scrolling.
    /// Theoretically might be cause of some issues on newer iOS versions.
    ///
    /// From: https://stackoverflow.com/a/67270977
    func fixFlickering() -> some View {
        GeometryReader { geo in
            ScrollView<PaddedContent>(axes, showsIndicators: showsIndicators) {
                // swiftlint:disable:next force_cast
                content.padding(geo.safeAreaInsets) as! PaddedContent
            }
            .edgesIgnoringSafeArea(.all)
        }
    }
}
