import Kingfisher
import SwiftUI

struct TileComponent: View {
    @EnvironmentObject
    private var library: LibraryRepository

    private let itemId: String
    private var titleText: String?
    private var subtitleText: String?
    private var edgeSize = UIConstants.tileSize

    init(for itemId: String) {
        self.itemId = itemId
    }

    var body: some View {
        let widthScale = subtitleText != nil ? 0.82 : 0.88
        ZStack(alignment: .leading) {
            GeometryReader { proxy in
                VStack(alignment: .leading) {
                    ArtworkComponent(for: itemId)

                    VStack(alignment: .leading, spacing: 2) {
                        if let titleText {
                            title(titleText, width: proxy.size.width)
                        }

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
    private func title(_ text: String, width: CGFloat) -> some View {
        let textSize = width / 11.176
        MarqueeTextComponent(text, font: .system(size: textSize, weight: .medium))
    }

    @ViewBuilder
    private func subtitle(_ text: String, width: CGFloat) -> some View {
        let textSize = width / 15.83
        MarqueeTextComponent(text, font: .system(size: textSize, weight: .medium), color: .gray)
    }
}

extension TileComponent {
    func tileTitle(_ text: String) -> TileComponent {
        var view = self
        view.titleText = text
        return view
    }

    func tileSubTitle(_ text: String) -> TileComponent {
        var view = self
        view.subtitleText = text
        return view
    }

    func setSize(_ newEdgeSize: Double) -> TileComponent {
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
        .tileTitle("Title")
        .tileSubTitle("Subtitle")
        .environmentObject(PreviewUtils.libraryRepo)
        .environmentObject(PreviewUtils.apiClient)
}

// swiftlint:enable all
#endif
