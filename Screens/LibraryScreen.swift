import ButtonKit
import Defaults
import OSLog
import SFSafeSymbols
import SwiftUI

struct LibraryScreen: View {
    @EnvironmentObject
    private var library: LibraryRepository

    @Default(.libraryShowFavorites)
    private var showFavoriteAlbums

    @Default(.libraryShowRecentlyAdded)
    private var showRecentlyAdded

    var body: some View {
        NavigationStack {
            List {
                navSection
                    .font(.system(size: 20))

                Group {
                    favoriteAlbums
                    recentlyAdded
                }
                .listRowSeparator(.hidden)
                .textCase(.none)
            }
            .listStyle(.grouped)
            .navigationTitle("Library")
            .navigationBarTitleDisplayMode(.large)
            .scrollContentBackground(.hidden)
            .toolbar {
                ToolbarItem { refreshButton }
            }
        }
    }

    @ViewBuilder
    private var navSection: some View {
        NavigationLink {} label: {
            Label("Playlists", systemSymbol: .musicNoteList)
        }
        .disabled(true)

        NavigationLink {
            ArtistLibraryScreen()
        } label: {
            Label("Artists", systemSymbol: .musicMic)
        }

        NavigationLink {
            AlbumLibraryScreen(albums: library.albums)
        } label: {
            Label("Albums", systemSymbol: .squareStack)
        }

        NavigationLink {
            SongsLibraryScreen(songs: library.songs)
        } label: {
            Label("Songs", systemSymbol: .musicNote)
        }
    }

    @ViewBuilder
    private var favoriteAlbums: some View {
        if showFavoriteAlbums {
            ItemCollectionPreview("Favorite Albums", items: library.albums.filtered(by: .favorite)) { item in
                // swiftlint:disable:next force_cast
                let album = item as! Album
                NavigationLink {
                    AlbumDetailScreen(album: album)
                } label: {
                    TileComponent(item: album)
                        .tileSubTitle(album.artistName)
                        .padding(.bottom)
                }
                .foregroundStyle(Color.primary)
            } viewAll: { items in
                albumEntries(items)
                    .navigationTitle("Favorite Albums")
                    .navigationBarTitleDisplayMode(.inline)
                    .listStyle(.plain)
            } empty: {
                ContentUnavailableView("No favorites", systemImage: "star.slash")
            }
        }
    }

    @ViewBuilder
    private var recentlyAdded: some View {
        if showRecentlyAdded {
            ItemCollectionPreview("Recently added", items: library.albums) { item in
                // swiftlint:disable:next force_cast
                let album = item as! Album
                NavigationLink {
                    AlbumDetailScreen(album: album)
                } label: {
                    TileComponent(item: album)
                        .tileSubTitle(album.artistName)
                        .padding(.bottom)
                }
                .foregroundStyle(Color.primary)
            } viewAll: { items in
                albumEntries(items)
                    .navigationTitle("Recently added")
                    .navigationBarTitleDisplayMode(.inline)
                    .listStyle(.plain)
            } empty: {
                ContentUnavailableView("No recents", systemImage: "clock.badge.xmark")
            }
        }
    }

    @ViewBuilder
    private func albumEntries(_ items: [any JellyfinItem]) -> some View {
        List(items, id: \.id) { item in
            // swiftlint:disable:next force_cast
            let album = item as! Album

            NavigationLink {
                AlbumDetailScreen(album: album)
            } label: {
                HStack {
                    ArtworkComponent(for: album.id)
                        .frame(width: 50, height: 50)

                    VStack(alignment: .leading, spacing: 3) {
                        Text(album.name)
                            .font(.title2)

                        Text(album.artistName)
                            .font(.caption)
                            .foregroundStyle(Color.gray)
                    }

                    Spacer()
                }
            }
        }
    }

    @ViewBuilder
    private var refreshButton: some View {
        AsyncButton {
            do {
                try await library.refreshAll()
            } catch {
                Logger.library.warning("Library refresh failed: \(error.localizedDescription)")
                Alerts.error("Refresh failed")
            }

        } label: {
            Image(systemSymbol: .arrowClockwise)
                .scaledToFit()
        }
    }
}

#Preview("Default") {
    LibraryScreen()
        .environmentObject(PreviewUtils.libraryRepo)
        .environmentObject(ApiClient(previewEnabled: true))
}

#Preview("Empty") {
    LibraryScreen()
        .environmentObject(PreviewUtils.libraryRepoEmpty)
        .environmentObject(ApiClient(previewEnabled: true))
}

struct ItemCollectionPreview<Tile: View, ViewAll: View, Empty: View>: View {
    @Default(.maxPreviewItems)
    private var previewLimit: Int

    private var title: String
    private var items: [any JellyfinItem]
    private var tileView: (any JellyfinItem) -> Tile
    private var viewAllView: ([any JellyfinItem]) -> ViewAll
    private var emptyView: Empty?

    init(
        _ title: String,
        items: [any JellyfinItem],
        @ViewBuilder itemTile: @escaping (any JellyfinItem) -> Tile,
        @ViewBuilder viewAll: @escaping ([any JellyfinItem]) -> ViewAll,
        @ViewBuilder empty: @escaping () -> Empty
    ) {
        self.title = title
        self.items = items
        self.tileView = itemTile
        self.viewAllView = viewAll
        self.emptyView = empty()
    }

    var body: some View {
        Section {
            if items.isEmpty {
                if let emptyView {
                    emptyView
                } else {
                    ContentUnavailableView("No items", systemImage: "square.stack.3d.up.slash")
                }
            } else {
                content
            }
        } header: {
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
            .padding(.top, -15)
        }
    }

    private var content: some View {
        ScrollView(.horizontal) {
            LazyHStack(spacing: 20) {
                ForEach(items.prefix(previewLimit), id: \.id) { item in
                    tileView(item)
                }
            }
            .padding(.leading)
            .padding(.top)
        }
        .listRowInsets(EdgeInsets())
    }
}

extension ItemCollectionPreview where Empty == EmptyView {
    init(
        _ title: String,
        items: [any JellyfinItem],
        @ViewBuilder itemTile: @escaping (any JellyfinItem) -> Tile,
        @ViewBuilder viewAll: @escaping ([any JellyfinItem]) -> ViewAll
    ) {
        self.title = title
        self.items = items
        self.tileView = itemTile
        self.viewAllView = viewAll
        self.emptyView = nil
    }
}
