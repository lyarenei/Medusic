import ButtonKit
import SFSafeSymbols
import SwiftUI

struct ArtistDetailScreen: View {
    @State
    private var viewModel: ViewModel

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    init(artist: Artist, repo: LibraryRepository = .shared) {
        self.viewModel = ViewModel(artist: artist, repo: repo)
    }

    var body: some View {
        List {
            artistHeader
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)

            albumsSection
                .listSectionSeparatorTint(.systemGroupedBackground)
        }
        .listStyle(.plain)
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.updateDetails() }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) { favoriteButton }
            ToolbarItem(placement: .navigationBarTrailing) { refreshButton }
        }
    }

    @ViewBuilder
    private var artistHeader: some View {
        HStack(spacing: 15) {
            ArtworkComponent(itemId: viewModel.artist.id)
                .frame(width: 90, height: 90)

            VStack(alignment: .leading, spacing: 10) {
                Text(viewModel.artist.name)
                    .font(.title)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)

                Text("\(viewModel.albums.count) albums, \(viewModel.runtime.minutes) minutes")
                    .font(.footnote)
                    .foregroundColor(.secondaryLabel)
            }
        }
    }

    @ViewBuilder
    private var albumsSection: some View {
        if viewModel.albums.isNotEmpty {
            Section("Albums") {
                artistAlbums
            }
        } else {
            Text("No albums found")
                .font(.title2)
                .foregroundStyle(Color.gray)
        }
    }

    @ViewBuilder
    private var artistAlbums: some View {
        ForEach(viewModel.albums) { album in
            // TODO: value based navigation
            NavigationLink {
                AlbumDetailScreen(album: album)
            } label: {
                Label {
                    Text(album.name)
                        .font(.title3)
                } icon: {
                    ArtworkComponent(itemId: album.id)
                        .scaledToFit()
                }
                .labelStyle(.titleAndIcon)
            }
            .frame(height: 40)
        }
    }

    @ViewBuilder
    private var favoriteButton: some View {
        AsyncButton {
            await viewModel.onFavoriteButton()
        } label: {
            if viewModel.artist.isFavorite {
                Image(systemSymbol: .heartFill)
            } else {
                Image(systemSymbol: .heart)
            }
        }
        .disabled(true)
    }

    @ViewBuilder
    private var refreshButton: some View {
        AsyncButton {
            await viewModel.onRefreshButton()
        } label: {
            Image(systemSymbol: .arrowClockwise)
        }
        .disabled(true)
    }
}

#Preview {
    NavigationStack {
        ArtistDetailScreen(artist: PreviewData.artist, repo: PreviewUtils.libraryRepo)
    }
}
