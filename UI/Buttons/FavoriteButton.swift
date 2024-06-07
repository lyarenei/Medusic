import ButtonKit
import SFSafeSymbols
import SwiftUI

struct FavoriteButton: View {
    @EnvironmentObject
    private var library: LibraryRepository

    @State
    private var isFavorite = false

    private let item: any JellyfinItem
    private let textFavorite: String?
    private let textUnfavorite: String?

    init(
        item: any JellyfinItem,
        textFavorite: String? = nil,
        textUnfavorite: String? = nil
    ) {
        self.item = item
        self.textFavorite = textFavorite
        self.textUnfavorite = textUnfavorite
    }

    var body: some View {
        let symbol: SFSymbol = isFavorite ? .heartFill : .heart
        let text = isFavorite ? textUnfavorite : textFavorite
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
        .sensoryFeedback(.success, trigger: isFavorite) { old, new in !old && new }
        .sensoryFeedback(.impact, trigger: isFavorite) { old, new in old && !new }
        .onAppear { isFavorite = item.isFavorite }
        .disabledWhenLoading()
    }

    enum ButtonLayout {
        case horizontal
        case vertical
    }

    @MainActor
    private func action() async {
        do {
            switch item {
            case let artist as ArtistDto:
                try await library.setFavorite(artist: artist, isFavorite: !isFavorite)
            case let album as AlbumDto:
                try await library.setFavorite(album: album, isFavorite: !isFavorite)
            case let song as SongDto:
                try await library.setFavorite(song: song, isFavorite: !isFavorite)
            default:
                print("Unhandled item type: \(item)")
                return
            }

            isFavorite.toggle()
        } catch {
            print("Failed to update favorite status: \(error.localizedDescription)")
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
