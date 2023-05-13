import Defaults
import SwiftUI

struct AlbumPreviewCollection<Content: View>: View {
    private var albums: [Album]
    private var titleText: String
    private var emptyText = "No albums"
    private var stackType: StackType = .vertical

    @ViewBuilder
    private var showAllDest: () -> Content

    @Default(.maxPreviewItems)
    private var limit

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

            switch stackType {
            case .vertical:
                sectionVContent()
                    .padding(.leading)
            case .horizontal:
                sectionHContent()
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
            AlbumCollection(albums: albums.prefix(limit))
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
                    AlbumCollection(albums: albums.prefix(limit))
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

    enum StackType {
        case vertical
        case horizontal
    }
}

extension AlbumPreviewCollection {
    func stackType(_ value: StackType) -> AlbumPreviewCollection {
        var view = self
        view.stackType = value
        return view
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
