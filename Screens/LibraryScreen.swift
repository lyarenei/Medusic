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
                    if showFavoriteAlbums {
                        favoriteAlbums
                    }

                    if showRecentlyAdded {
                        recentlyAdded
                    }
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
        NavigationLink {
            ArtistLibraryScreen(library.artists)
        } label: {
            Label("Artists", systemSymbol: .musicMic)
        }

        NavigationLink {
            AlbumLibraryScreen(library.albums)
        } label: {
            Label("Albums", systemSymbol: .squareStack)
        }

        NavigationLink {
            SongLibraryScreen(library.songs)
        } label: {
            Label("Songs", systemSymbol: .musicNote)
        }
    }

    @ViewBuilder
    private var favoriteAlbums: some View {
        ItemPreviewCollection(
            "Favorite Albums",
            items: library.albums.filtered(by: .favorite).sorted(by: .name)
        ) { album in
            NavigationLink {
                AlbumDetailScreen(album: album)
            } label: {
                TileComponent(for: album.id)
                    .tileTitle(album.name)
                    .tileSubTitle(album.artistName)
                    .padding(.bottom)
            }
            .foregroundStyle(Color.primary)
        } viewAll: { items in
            albumEntries(items)
                .navigationTitle("Favorite Albums")
                .navigationBarTitleDisplayMode(.inline)
                .listStyle(.plain)
        } noItems: {
            ContentUnavailableView("No favorites", systemImage: "star.slash")
        }
    }

    @ViewBuilder
    private var recentlyAdded: some View {
        ItemPreviewCollection("Recently added", items: library.albums) { album in
            NavigationLink {
                AlbumDetailScreen(album: album)
            } label: {
                TileComponent(for: album.id)
                    .tileTitle(album.name)
                    .tileSubTitle(album.artistName)
                    .padding(.bottom)
            }
            .foregroundStyle(Color.primary)
        } viewAll: { items in
            albumEntries(items)
                .navigationTitle("Recently added")
                .navigationBarTitleDisplayMode(.inline)
                .listStyle(.plain)
        } noItems: {
            ContentUnavailableView("No recents", systemImage: "clock.badge.xmark")
        }
    }

    @ViewBuilder
    private func albumEntries(_ albums: [AlbumDto]) -> some View {
        List(albums, id: \.id) { album in
            AlbumListRow(album: album)
                .frame(height: 60)
                .albumContextMenu(for: album)
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

#if DEBUG
// swiftlint:disable all

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

// swiftlint:enable all
#endif
