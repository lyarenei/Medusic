import SwiftUI

struct ArtworkComponent: View {

    @Environment(\.api)
    var api

    @State
    private var isLoading = true

    @State
    private var artworkImage: Optional<UIImage> = nil

    var itemId: String
    var frameWidth: CGFloat = 160
    var frameHeight: CGFloat = 160

    var body: some View {
        Group {
            if let image = artworkImage {
                Image(uiImage: image)
                    .resizable()
                    .frame(width: frameWidth, height: frameHeight)
                    .clipShape(RoundedRectangle(cornerRadius: 5.0))
            } else {
                if isLoading {
                    ProgressView()
                        .frame(width: frameWidth, height: frameHeight)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5.0)
                                .stroke(style: StrokeStyle(lineWidth: 1.0))
                        )
                } else {
                    Rectangle()
                        .frame(width: frameWidth, height: frameHeight)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5.0)
                                .stroke(style: StrokeStyle(lineWidth: 1.0))
                        )
                }
            }
        }
        .onAppear {
            isLoading = true

            Task {
                do {
                    // Overdramatize
                    sleep(1)

                    if let data = try await api.imageService.getImage(for: itemId) {
                        artworkImage = UIImage(data: data)
                        isLoading = false
                    }
                } catch {
                    isLoading = false
                }
            }
        }
    }
}

struct ArtworkComponent_Previews: PreviewProvider {
    static var previews: some View {
        ArtworkComponent(itemId: "asdf")
            .environment(\.api, .preview)
    }
}
