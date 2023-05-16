import SwiftUI

struct ItemListScreen<Item: JellyfinItem, Content: View>: View {
    private let title: String
    private let itemArray: [Item]
    private let listEntryView: (Item) -> Content

    init(
        title: String,
        itemArray: [Item],
        @ViewBuilder listEntryView: @escaping (Item) -> Content
    ) {
        self.title = title
        self.itemArray = itemArray
        self.listEntryView = listEntryView
    }

    var body: some View {
        List {
            ForEach(itemArray) { item in
                listEntryView(item)
            }
        }
        .listStyle(.plain)
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#if DEBUG
struct ItemListScreen_Previews: PreviewProvider {
    static var previews: some View {
        ItemListScreen(
            title: "More albums",
            itemArray: PreviewData.albums
        ) { album in
            VStack(alignment: .leading) {
                Text(album.name)
                Text(album.artistName)
            }
        }
    }
}
#endif
