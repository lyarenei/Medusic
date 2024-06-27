import Kingfisher
import MarqueeText
import SwiftUI

struct IPadTileComponent<Item: JellyfinModel>: View {
    private let item: Item
    private var titleText: String?
    private var subtitleText: String?
    private var edgeSize = UIConstants.tileSize

    init(item: Item) {
        self.item = item
    }

    var body: some View {
        let widthScale = subtitleText != nil ? 0.82 : 0.88
        ZStack(alignment: .leading) {
            GeometryReader { proxy in
                VStack(alignment: .leading) {
                    ArtworkComponent(for: item.jellyfinId)

                    VStack(alignment: .leading, spacing: 2) {
                        title(proxy.size.width)

                        if let subtitleText {
                            subtitle(subtitleText, width: proxy.size.width)
                        }
                    }
                }
                .frame(width: proxy.size.width, height: proxy.size.width / widthScale)
            }
        }
        .frame(width: edgeSize, height: edgeSize / widthScale)
    }

    @ViewBuilder
    private func title(_ width: CGFloat) -> some View {
        let textSize = width / 11.176
        MarqueeText(
            text: titleText ?? item.name,
            font: .systemFont(ofSize: textSize, weight: .medium),
            leftFade: UIConstants.marqueeFadeLen,
            rightFade: UIConstants.marqueeFadeLen,
            startDelay: UIConstants.marqueeDelay
        )
    }

    @ViewBuilder
    private func subtitle(_ text: String, width: CGFloat) -> some View {
        let textSize = width / 15.83
        MarqueeText(
            text: text,
            font: .systemFont(ofSize: textSize),
            leftFade: UIConstants.marqueeFadeLen,
            rightFade: UIConstants.marqueeFadeLen,
            startDelay: UIConstants.marqueeDelay
        )
        .foregroundColor(.gray)
    }
}

extension IPadTileComponent {
    func tileTitle(_ text: String) -> IPadTileComponent {
        var view = self
        view.titleText = text
        return view
    }

    func tileSubTitle(_ text: String) -> IPadTileComponent {
        var view = self
        view.subtitleText = text
        return view
    }

    func setSize(_ newEdgeSize: Double) -> IPadTileComponent {
        var view = self
        view.edgeSize = newEdgeSize
        return view
    }
}

#if DEBUG
// swiftlint:disable all

#Preview {
    TileComponent(for: PreviewData.album.id)
        .setSize(UIConstants.tileSize)
        .tileSubTitle("Subtitle")
        .environmentObject(PreviewUtils.libraryRepo)
        .environmentObject(PreviewUtils.apiClient)
}

// swiftlint:enable all
#endif
