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
    private var layout: ButtonLayout = .horizontal

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
            switch layout {
            case .horizontal:
                hLayout(symbol, text)
            case .vertical:
                vLayout(symbol, text)
            }
        }
        .sensoryFeedback(.success, trigger: isFavorite) { old, new in !old && new }
        .sensoryFeedback(.impact, trigger: isFavorite) { old, new in old && !new }
        .onAppear {
            isFavorite = item.isFavorite
        }
        .disabledWhenLoading()
    }

    enum ButtonLayout {
        case horizontal
        case vertical
    }

    @ViewBuilder
    private func hLayout(_ symbol: SFSymbol, _ text: String?) -> some View {
        HStack {
            icon(symbol)
            buttonText(text)
        }
    }

    @ViewBuilder
    private func vLayout(_ symbol: SFSymbol, _ text: String?) -> some View {
        VStack {
            icon(symbol)
            buttonText(text)
        }
    }

    @ViewBuilder
    private func buttonText(_ text: String?) -> some View {
        if let text {
            Text(text)
        }
    }

    @ViewBuilder
    private func icon(_ symbol: SFSymbol) -> some View {
        Image(systemSymbol: symbol)
            .scaledToFit()
            .foregroundColor(.red)
    }

    @MainActor
    private func action() async {
        do {
            switch item {
            case let artist as Artist:
                try await library.setFavorite(artist: artist, isFavorite: !isFavorite)
            case let album as Album:
                try await library.setFavorite(album: album, isFavorite: !isFavorite)
            case let song as Song:
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

extension FavoriteButton {
    func setLayout(_ layout: ButtonLayout) -> FavoriteButton {
        var view = self
        view.layout = layout
        return view
    }
}

#if DEBUG
struct FavoriteButton_Previews: PreviewProvider {
    static var previews: some View {
        FavoriteButton(item: PreviewData.album)
            .previewDisplayName("Icon only")
            .font(.title)
            .environmentObject(PreviewUtils.libraryRepo)

        FavoriteButton(item: PreviewData.album, textUnfavorite: "Test")
            .setLayout(.horizontal)
            .previewDisplayName("Horizontal")
            .font(.title)
            .environmentObject(PreviewUtils.libraryRepo)

        FavoriteButton(item: PreviewData.album, textUnfavorite: "Test")
            .setLayout(.vertical)
            .previewDisplayName("Vertical")
            .font(.title)
            .environmentObject(PreviewUtils.libraryRepo)
    }
}
#endif
