import Foundation

extension LibraryRepository {
    /// Get songs for a specified album. Songs are automatically sorted in the correct order.
    nonisolated func getSongs(for album: Album) async -> [Song] {
        await songs.filtered(by: .albumId(album.id)).sorted(by: .index).sorted(by: .albumDisc)
    }
}
