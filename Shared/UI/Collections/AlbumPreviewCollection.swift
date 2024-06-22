import Defaults
import SwiftUI

@available(*, deprecated, message: "Use ItemPreviewCollection")
struct AlbumPreviewCollection: View {
    private var albums: [AlbumDto]
    private var titleText: String
    private var emptyText = "No albums"
    private var stackType: StackType = .vertical

    @Default(.maxPreviewItems)
    private var limit

    init(
        for albums: [AlbumDto],
        titleText: String,
        emptyText: String
    ) {
        self.albums = albums
        self.titleText = titleText
        self.emptyText = emptyText
    }

    var body: some View {
        let maxHeight = UIConstants.tileSize + 105
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
                    .padding(.trailing)
            }
        }
        .frame(height: albums.isNotEmpty ? maxHeight : 80, alignment: .top)
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
            .disabled(albums.count <= limit)
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
                LazyHStack(alignment: .top, spacing: 20) {
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
        NavigationStack {
            ScrollView {
                AlbumPreviewCollection(
                    for: PreviewData.albums,
                    titleText: "Preview albums",
                    emptyText: "No albums"
                )
            }
        }
        .previewDisplayName("Vertical")
        .environmentObject(PreviewUtils.libraryRepo)

        NavigationStack {
            AlbumPreviewCollection(
                for: PreviewData.albums,
                titleText: "Preview albums",
                emptyText: "No albums"
            )
            .stackType(.horizontal)
        }
        .previewDisplayName("Horizontal")
        .environmentObject(PreviewUtils.libraryRepo)

        NavigationStack {
            AlbumPreviewCollection(
                for: [],
                titleText: "Preview albums",
                emptyText: "No albums"
            )
        }
        .previewDisplayName("Empty")
        .environmentObject(PreviewUtils.libraryRepo)
    }
}
#endif
