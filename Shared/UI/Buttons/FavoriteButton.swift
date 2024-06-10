import ButtonKit
import OSLog
import SFSafeSymbols
import SwiftUI

struct FavoriteButton: View {
    @State
    var isFavorite: Bool

    let itemId: String
    let action: (String, Bool) async throws -> Void

    init(artistId: String, isFavorite: Bool, repo: LibraryRepository = .shared) {
        self.itemId = artistId
        self.isFavorite = isFavorite
        self.action = repo.setFavorite(artistId:isFavorite:)
    }

    init(albumId: String, isFavorite: Bool, repo: LibraryRepository = .shared) {
        self.itemId = albumId
        self.isFavorite = isFavorite
        self.action = repo.setFavorite(albumId:isFavorite:)
    }

    init(songId: String, isFavorite: Bool, repo: LibraryRepository = .shared) {
        self.itemId = songId
        self.isFavorite = isFavorite
        self.action = repo.setFavorite(songId:isFavorite:)
    }

    init(itemId: String, isFavorite: Bool, action: @escaping (String, Bool) async throws -> Void) {
        self.itemId = itemId
        self.isFavorite = isFavorite
        self.action = action
    }

    var body: some View {
        let symbol: SFSymbol = isFavorite ? .heartFill : .heart
        let text = isFavorite ? "Undo favorite" : "Favorite"
        AsyncButton {
            do {
                try await action(itemId, !isFavorite)
                isFavorite.toggle()
            } catch let error as MedusicError {
                Alerts.error(error)
            } catch {
                Alerts.error("Action failed")
            }
        } label: {
            Label(text, systemSymbol: symbol)
                .scaledToFit()
                .foregroundStyle(.red)
                .contentTransition(.symbolEffect(.replace))
        }
        .sensoryFeedback(.impact, trigger: isFavorite)
        .disabledWhenLoading()
    }
}

#if DEBUG
// swiftlint:disable all

#Preview {
    FavoriteButton(albumId: PreviewData.album.id, isFavorite: PreviewData.album.isFavorite)
        .font(.title)
        .environmentObject(PreviewUtils.libraryRepo)
}

// swiftlint:enable all
#endif
