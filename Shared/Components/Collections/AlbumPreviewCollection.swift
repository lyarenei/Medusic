import Defaults
import SwiftUI

struct AlbumPreviewCollection<Content: View>: View {
    private var albums: [Album]
    private var titleText: String
    private var emptyText = "No albums"

    @ViewBuilder
    private var showAllDest: () -> Content

    init(
        for albums: [Album],
        titleText: String,
        emptyText: String,
        @ViewBuilder showAllDest: @escaping () -> Content
    ) {
        self.albums = albums
        self.titleText = titleText
        self.emptyText = emptyText
        self.showAllDest = showAllDest
    }

    var body: some View {
        VStack(spacing: 7) {
            Group {
                sectionTitle()
                Divider()
            }
            .padding(.leading)

            // TODO: configurable force + automatic
            // TODO: limit counts, 10 default, configurable up to 20
            if Defaults[.libraryShowFavorites] && Defaults[.libraryShowLatest] {
                sectionHContent()
            } else {
                sectionVContent()
                    .padding(.leading)
            }
        }
    }

    @ViewBuilder
    private func sectionTitle() -> some View {
        HStack {
            Text(titleText)
                .font(.title)
                .bold()

            Spacer()

            if let showAllDest {
                NavigationLink("Show all") { showAllDest() }
                    .padding(.trailing)
                    .disabled(true)
            }
        }
    }

    @ViewBuilder
    private func sectionVContent() -> some View {
        if albums.isNotEmpty {
            AlbumCollection(albums: albums)
                .forceMode(.asPlainList)
                .buttonStyle(.plain)
        } else {
            emptyText(emptyText)
        }
    }

    @ViewBuilder
    private func sectionHContent() -> some View {
        if albums.isNotEmpty {
            ScrollView(.horizontal) {
                LazyHStack(spacing: 20) {
                    AlbumCollection(albums: albums)
                        .forceMode(.asTiles)
                        .padding(.top, 10)
                        .padding(.bottom, 15)
                }
                .padding(.leading)
            }
        } else {
            emptyText(emptyText)
        }
    }

    @ViewBuilder
    private func emptyText(_ text: String) -> some View {
        Text(text)
            .font(.title3)
            .foregroundColor(.gray)
            .padding(.top, 10)
    }
}

#if DEBUG
struct AlbumPreviewCollection_Previews: PreviewProvider {
    static var previews: some View {
        AlbumPreviewCollection(
            for: PreviewData.albums,
            titleText: "Preview albums",
            emptyText: "No albums"
        ) {}
            .previewDisplayName("Default")

        AlbumPreviewCollection(
            for: [],
            titleText: "Preview albums",
            emptyText: "No albums"
        ) {}
            .previewDisplayName("Empty")
    }
}
#endif
