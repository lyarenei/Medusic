import ButtonKit
import OSLog
import SFSafeSymbols
import SwiftUI

struct FavoriteButton<Item: JellyfinItem>: View {
    @EnvironmentObject
    private var library: LibraryRepository

    private let item: Item
    private let textFavorite: String?
    private let textUnfavorite: String?

    init(
        item: Item,
        textFavorite: String? = nil,
        textUnfavorite: String? = nil
    ) {
        self.item = item
        self.textFavorite = textFavorite
        self.textUnfavorite = textUnfavorite
    }

    var body: some View {
        let symbol: SFSymbol = item.isFavorite ? .heartSlashFill : .heart
        let text = item.isFavorite ? textUnfavorite : textFavorite
        AsyncButton {
            await action()
        } label: {
            if let text {
                Label(text, systemSymbol: symbol)
            } else {
                Image(systemSymbol: symbol)
                    .resizable()
                    .scaledToFit()
            }
        }
        .sensoryFeedback(.success, trigger: item.isFavorite) { old, new in !old && new }
        .sensoryFeedback(.impact, trigger: item.isFavorite) { old, new in old && !new }
        .disabledWhenLoading()
    }

    @MainActor
    private func action() async {
        do {
            switch item {
            case let artist as ArtistDto:
                try await library.setFavorite(artist: artist, isFavorite: !item.isFavorite)
            case let album as AlbumDto:
                try await library.setFavorite(album: album, isFavorite: !item.isFavorite)
            case let song as SongDto:
                await library.setFavorite(songId: song.id, isFavorite: !item.isFavorite)
            default:
                Logger.library.debug("Unhandled item type: \(type(of: item))")
                Alerts.info("Action is not available")
                return
            }
        } catch {
            Logger.library.warning("Failed to update favorite status: \(error.localizedDescription)")
            Alerts.error("Action failed")
        }
    }
}

#if DEBUG
// swiftlint:disable all

#Preview {
    FavoriteButton(item: PreviewData.album)
        .font(.title)
        .environmentObject(PreviewUtils.libraryRepo)
}

// swiftlint:enable all
#endif
