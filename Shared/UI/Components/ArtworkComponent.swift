import Kingfisher
import OSLog
import SFSafeSymbols
import SwiftUI

struct ArtworkComponent: View {
    private static let cornerRadius = 5.0
    private static let fadeDuration = 0.5
    private static let retryCount = 5
    private static let retryInterval = 10.0

    @EnvironmentObject
    private var apiClient: ApiClient

    private let itemId: String
    private var showFavorite = false

    @available(*, deprecated, message: "Use init accepting item ID")
    init(for item: any JellyfinItem) {
        self.itemId = item.id
    }

    init(for itemId: String) {
        self.itemId = itemId
    }

    var body: some View {
        GeometryReader { proxy in
            KFImage
                .dataProvider(jellyfinProvider)
                .cacheOriginalImage()
                .resizable()
                .placeholder { ProgressView() }
                .fade(duration: Self.fadeDuration)
                .retry(maxCount: Self.retryCount, interval: .seconds(Self.retryInterval))
                .appendProcessor(DownsamplingImageProcessor(size: doubleSize(proxy.size)))
                .onFailureImage(.init(systemSymbol: .photoOnRectangleAngled))
                .onFailure { error in
                    Logger.artwork.debug("Failed to load image for item \(itemId): \(error.localizedDescription)")
                }
                .aspectRatio(contentMode: .fit)
                .fill(alignment: .center)
                .overlay(alignment: .bottomTrailing) {
                    if showFavorite {
                        favoriteOverlay(proxy)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: Self.cornerRadius))
                .border(.gray.opacity(0.5), cornerRadius: Self.cornerRadius)
        }
    }

    @ViewBuilder
    private func favoriteOverlay(_ proxy: GeometryProxy) -> some View {
        // This is pretty ugly on large sizes. :(
        // But it gets the job done on smaller sizes.
        ZStack {
            Circle()
                .fill(.ultraThickMaterial)

            Image(systemSymbol: .heartFill)
                .resizable()
                .foregroundStyle(.red)
                .padding(proxy.size.width / 20)
        }
        .frame(width: proxy.size.width / 4, height: proxy.size.height / 4)
    }

    private var jellyfinProvider: JellyfinImageDataProvider {
        JellyfinImageDataProvider(
            itemId: itemId,
            imageService: apiClient.services.imageService
        )
    }

    private func doubleSize(_ size: CGSize) -> CGSize {
        CGSize(
            width: size.width * 2,
            height: size.height * 2
        )
    }

    func showFavorite(_ value: Bool = true) -> ArtworkComponent {
        var view = self
        view.showFavorite = value
        return view
    }
}

#if DEBUG
// swiftlint:disable all

#Preview {
    ArtworkComponent(for: PreviewData.albums.first!.id)
        .environmentObject(PreviewUtils.apiClient)
        .frame(width: 200, height: 200)
}

// swiftlint:enable all
#endif
