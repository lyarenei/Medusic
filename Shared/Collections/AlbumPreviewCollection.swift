import Defaults
import SwiftUI

struct AlbumPreviewCollection: View {
    private var albums: [Album]
    private var titleText: String
    private var emptyText = "No albums"
    private var stackType: StackType = .vertical

    @Default(.maxPreviewItems)
    private var limit

    init(
        for albums: [Album],
        titleText: String,
        emptyText: String
    ) {
        self.albums = albums
        self.titleText = titleText
        self.emptyText = emptyText
    }

    var body: some View {
        VStack(spacing: 7) {
            Group {
                sectionTitle
                Divider()
            }
            .padding(.leading)

            switch stackType {
            case .vertical:
                sectionVContent
                    .padding(.leading)
            case .horizontal:
                sectionHContent
            }
        }
    }

    @ViewBuilder
    private var sectionTitle: some View {
        HStack {
            Text(titleText)
                .font(.title2)
                .bold()
                .lineLimit(1)

            Spacer()
            NavigationLink("Show all") {
                showMoreScreen
            }
            .padding(.trailing)
            .disabled(albums.isEmpty || albums.count <= limit)
        }
    }

    @ViewBuilder
    private var sectionVContent: some View {
        if albums.isNotEmpty {
            AlbumCollection(albums: albums.prefix(limit))
                .forceMode(.asPlainList)
                .buttonStyle(.plain)
        } else {
            emptyText(emptyText)
        }
    }

    @ViewBuilder
    private var sectionHContent: some View {
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

    @ViewBuilder
    private var showMoreScreen: some View {
        List {
            AlbumCollection(albums: albums)
                .forceMode(.asList)
        }
        .listStyle(.plain)
        .navigationTitle(titleText)
        .navigationBarTitleDisplayMode(.inline)
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
        )
        .previewDisplayName("Default")

        AlbumPreviewCollection(
            for: [],
            titleText: "Preview albums",
            emptyText: "No albums"
        )
        .previewDisplayName("Empty")
    }
}
#endif
