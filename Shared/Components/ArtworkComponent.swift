import SwiftUI
import Kingfisher

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
            let dataProvider = JellyfinImageDataProvider(
                itemId: itemId,
                imageService: apiClient.services.imageService,
                imageSize: CGSize(
                    width: proxy.size.width * UIScreen.main.scale,
                    height: proxy.size.height * UIScreen.main.scale
                )
            )

            KFImage.dataProvider(dataProvider)
                .cacheOriginalImage()
                .resizable()
                .placeholder { ProgressView() }
                .fade(duration: 0.25)
                .retry(maxCount: Int.max, interval: .seconds(10))
                .clipShape(RoundedRectangle(cornerRadius: Self.cornerRadius))
                .overlay(
                    RoundedRectangle(cornerRadius: Self.cornerRadius)
                        .stroke(style: StrokeStyle(lineWidth: 0.5))
                        .foregroundColor(Color(UIColor.separator.cgColor))
                )
        }
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
