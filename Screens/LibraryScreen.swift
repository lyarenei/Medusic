import ButtonKit
import Defaults
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
            ArtistLibraryScreen(artists: library.artists)
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
        if showRecentlyAdded {
            itemCollectionPreview(
                title: "Favorite Albums",
                items: library.albums.filtered(by: .favorite).sorted(by: Array<Album>.AlbumSortBy.dateAdded),
                previewLimit: Defaults[.maxPreviewItems]
            )
        }
    }

    @ViewBuilder
    private var recentlyAdded: some View {
        if showRecentlyAdded {
            itemCollectionPreview(
                title: "Recently added",
                items: library.albums,
                previewLimit: Defaults[.maxPreviewItems]
            )
        }
    }

    @ViewBuilder
    private func itemCollectionPreview(
        title: String,
        items: [Album],
        previewLimit: Int
    ) -> some View {
        Section {
            ScrollView(.horizontal) {
                LazyHStack(spacing: 20) {
                    AlbumCollection(albums: items.prefix(previewLimit))
                        .forceMode(.asTiles)
                }
                .padding(.leading)
                .padding(.top)
            }
            .listRowInsets(EdgeInsets())
        } header: {
            HStack {
                Text(title)
                    .font(.system(size: 24))
                    .bold()
                    .foregroundStyle(Color.primary)

                Spacer()
                NavigationLink(value: items) {
                    Text("View all")
                }
            }
        }
    }

    @ViewBuilder
    private var refreshButton: some View {
        AsyncButton {
            try await library.refreshAll()
        } label: {
            Image(systemSymbol: .arrowClockwise)
                .scaledToFit()
        }
    }
}

#Preview {
    LibraryScreen()
        .environmentObject(PreviewUtils.libraryRepo)
        .environmentObject(ApiClient(previewEnabled: true))
}

    }
}
