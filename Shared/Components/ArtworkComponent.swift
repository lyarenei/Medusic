import Kingfisher
import OSLog
import SFSafeSymbols
import SwiftUI

struct ArtworkComponent: View {
    private static let cornerRadius: CGFloat = 5

    @State
    private var artworkImage: PlatformImage?

    let itemId: String
    let apiClient: ApiClient

    init(
        itemId: String,
        apiClient: ApiClient = .shared
    ) {
        self.itemId = itemId
        self.apiClient = apiClient
    }

    var body: some View {
        GeometryReader { proxy in
            KFImage.dataProvider(getDataProvider())
                .cacheOriginalImage()
                .resizable()
                .placeholder {
                    Image(systemSymbol: .photoOnRectangleAngled)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .fill(alignment: .center)
                }
                .fade(duration: 0.25)
                .retry(maxCount: 5, interval: .seconds(10))
                .appendProcessor(DownsamplingImageProcessor(size: doubleSize(proxy.size)))
                .onFailure { error in
                    Logger.artwork.debug("Failed to load image for item \(itemId): \(error.localizedDescription)")
                }
                .clipShape(RoundedRectangle(cornerRadius: Self.cornerRadius))
                .border(.gray.opacity(0.5), cornerRadius: Self.cornerRadius)
                .aspectRatio(contentMode: .fit)
                .fill(alignment: .center)
        }
    }

    private func getDataProvider() -> JellyfinImageDataProvider {
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
}

#if DEBUG
// swiftlint:disable all
struct ArtworkComponent_Previews: PreviewProvider {
    static var previews: some View {
        ArtworkComponent(
            itemId: PreviewData.albums.first!.id,
            apiClient: .init(previewEnabled: true)
        )
        .previewLayout(.fixed(width: 200, height: 200))
    }
}
// swiftlint:enable all
#endif
