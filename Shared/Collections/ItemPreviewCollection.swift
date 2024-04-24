import Defaults
import SwiftUI

struct ItemPreviewCollection<Tile: View, ViewAll: View, NoItems: View, Item: JellyfinItem>: View {
    @Default(.maxPreviewItems)
    private var previewLimit: Int

    private var title: String
    private var items: [Item]
    private var tileView: (Item) -> Tile
    private var viewAllView: ([Item]) -> ViewAll
    private var noItemsView: NoItems?

    init(
        _ title: String,
        items: [Item],
        @ViewBuilder itemTile: @escaping (Item) -> Tile,
        @ViewBuilder viewAll: @escaping ([Item]) -> ViewAll,
        @ViewBuilder noItems: @escaping () -> NoItems
    ) {
        self.title = title
        self.items = items
        self.tileView = itemTile
        self.viewAllView = viewAll
        self.noItemsView = noItems()
    }

    var body: some View {
        Section {
            contentView
        } header: {
            headerView
                .padding(.top, -15)
        }
    }

    @ViewBuilder
    private var contentView: some View {
        if items.isEmpty {
            if let noItemsView {
                noItemsView
            } else {
                ContentUnavailableView("No items", systemImage: "square.stack.3d.up.slash")
            }
        } else {
            content
        }
    }

    @ViewBuilder
    private var content: some View {
        ScrollView(.horizontal) {
            LazyHStack(spacing: 20) {
                ForEach(items.prefix(previewLimit), id: \.id) { item in
                    tileView(item)
                }
            }
            .padding(.horizontal)
            .padding(.top)
        }
        .listRowInsets(EdgeInsets())
    }

    @ViewBuilder
    private var headerView: some View {
        HStack {
            Text(title)
                .font(.system(size: 24))
                .bold()
                .foregroundStyle(Color.primary)

            Spacer()

            NavigationLink("View all") {
                viewAllView(items)
            }
            .disabled(items.count < previewLimit)
        }
    }
}

extension ItemPreviewCollection where NoItems == EmptyView {
    init(
        _ title: String,
        items: [Item],
        @ViewBuilder itemTile: @escaping (Item) -> Tile,
        @ViewBuilder viewAll: @escaping ([Item]) -> ViewAll
    ) {
        self.title = title
        self.items = items
        self.tileView = itemTile
        self.viewAllView = viewAll
        self.noItemsView = nil
    }
}

#if DEBUG

#Preview("Default") {
    List {
        ItemPreviewCollection("Items preview", items: PreviewData.albums) { album in
            TileComponent(item: album)
                .tileSubTitle(album.artistName)
                .padding(.bottom)
        } viewAll: { items in
            List(items, id: \.id) { album in
                Text(album.name)
            }
        }
    }
    .environmentObject(ApiClient(previewEnabled: true))
    .listStyle(.plain)
}

#Preview("Empty") {
    List {
        ItemPreviewCollection("Items preview", items: [Album]()) { album in
            TileComponent(item: album)
                .tileSubTitle(album.artistName)
                .padding(.bottom)
        } viewAll: { items in
            List(items, id: \.id) { album in
                Text(album.name)
            }
        }
    }
    .environmentObject(ApiClient(previewEnabled: true))
    .listStyle(.plain)
}

#endif
