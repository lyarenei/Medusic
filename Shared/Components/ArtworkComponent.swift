import SwiftUI
import Kingfisher
import OSLog

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
                .placeholder { ProgressView() }
                .fade(duration: 0.25)
                .retry(maxCount: 5, interval: .seconds(10))
                .appendProcessor(DownsamplingImageProcessor(size: proxy.size))
                .onSuccess { _ in
                    Logger.artwork.debug("Loaded image for item \(itemId)")
                }
                .onFailure { error in
                    Logger.artwork.debug("Failed to load image for item \(itemId): \(error.localizedDescription)")
                }
                .clipShape(RoundedRectangle(cornerRadius: Self.cornerRadius))
                .overlay(
                    RoundedRectangle(cornerRadius: Self.cornerRadius)
                        .stroke(style: StrokeStyle(lineWidth: 0.5))
                        .foregroundColor(Color(UIColor.separator.cgColor))
                )
        }
    }

    private func getDataProvider() -> JellyfinImageDataProvider {
        JellyfinImageDataProvider(
            itemId: itemId,
            imageService: apiClient.services.imageService
        )
    }
}

#if DEBUG
// swiftlint:disable all
struct ArtworkComponent_Previews: PreviewProvider {
    static var previews: some View {
        ArtworkComponent(
            itemId: PreviewData.albums.first!.uuid,
            apiClient: .init(previewEnabled: true)
        )
        .previewLayout(.fixed(width: 200, height: 200))
    }
}
// swiftlint:enable all
#endif
