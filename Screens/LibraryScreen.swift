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
        ItemPreviewCollection("Favorite Albums", items: library.albums.filtered(by: .favorite)) { album in
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
        } noItems: {
            ContentUnavailableView("No recents", systemImage: "clock.badge.xmark")
        }
    }

    @ViewBuilder
    private func albumEntries(_ albums: [Album]) -> some View {
        List(albums, id: \.id) { album in
            NavigationLink {
                AlbumDetailScreen(album: album)
            } label: {
                // TODO: use album list row
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
