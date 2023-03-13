import SwiftUI
import Kingfisher

struct ArtworkComponent: View {
    private static let cornerRadius: CGFloat = 5

    @Environment(\.api)
    var api

    @State
    private var artworkImage: PlatformImage? = nil

    var itemId: String

    private var dataProvider: ImageDataProvider {
        JellyfinImageDataProvider(itemId: itemId, imageService: api.imageService)
    }

    var body: some View {
        GeometryReader { proxy in
            KFImage.dataProvider(dataProvider)
                .downsampling(size: CGSize(width: proxy.size.width * UIScreen.main.scale, height: proxy.size.height * UIScreen.main.scale))
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
struct ArtworkComponent_Previews: PreviewProvider {
    static var previews: some View {
        ArtworkComponent(itemId: "asdf")
            .environment(\.api, .preview)
            .previewLayout(.fixed(width: 200, height: 200))
    }
}
#endif
