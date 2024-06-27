import SFSafeSymbols
import SwiftUI

struct ArtistDetailScreen: View {
    @EnvironmentObject
    private var library: LibraryRepository

    let artist: ArtistDto

    var body: some View {
        let artistAlbums = library.albums.filtered(by: .artistId(artist.id)).sorted(by: .name)
        List {
            artistHeader(albumCount: artistAlbums.count)
                .listRowSeparator(.hidden)

            albumsSection(artistAlbums)

            aboutSection(artist.about)
                .listRowSeparator(.hidden)

            genreSection(artist.genres)
                .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    ArtistMenuOptions(artist: artist)
                } label: {
                    Image(systemSymbol: .ellipsis)
                        .circleBackground()
                }
            }
        }
    }

    @ViewBuilder
    private func artistHeader(albumCount: Int) -> some View {
        HStack(spacing: 15) {
            ArtworkComponent(for: artist.id)
                .frame(width: 90, height: 90)

            VStack(alignment: .leading, spacing: 10) {
                Text(artist.name)
                    .font(.title)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)

                let runtime = getRuntime()
                Text("\(albumCount) albums・\(runtime.minutes) minutes")
                    .font(.footnote)
                    .foregroundColor(.secondaryLabel)
            }
        }
    }

    @ViewBuilder
    private func albumsSection(_ albums: [AlbumDto]) -> some View {
        if albums.isNotEmpty {
            Section("Albums") {
                artistAlbums(albums)
            }
        } else {
            ContentUnavailableView {
                Text("No albums")
            }
            .listRowSeparator(.hidden)
            .listSectionSeparator(.hidden)
        }
    }

    @ViewBuilder
    private func artistAlbums(_ albums: [AlbumDto]) -> some View {
        ForEach(albums, id: \.id) { album in
            NavigationLink(value: album) {
                HStack {
                    ArtworkComponent(for: album.id)
                        .scaledToFit()
                        .frame(width: 40, height: 40)

                    Text(album.name)
                        .font(.title3)
                }
                .frame(height: 40)
            }
        }
    }

    @ViewBuilder
    private func aboutSection(_ aboutText: String) -> some View {
        if aboutText.isNotEmpty {
            Section("About") {
                Text(aboutText)
            }
        }
    }

    @ViewBuilder
    private func genreSection(_ genres: [String]) -> some View {
        if genres.isNotEmpty {
            Section("Genres") {
                Text(genres.joined(separator: "・"))
            }
        }
    }

    private func getRuntime() -> TimeInterval {
        var totalRuntime: TimeInterval = 0
        for album in library.albums.filtered(by: .artistId(artist.id)) {
            totalRuntime += getAlbumRuntime(album.id)
        }

        return totalRuntime
    }

    private func getAlbumRuntime(_ albumId: String) -> TimeInterval {
        var totalRuntime: TimeInterval = 0
        for song in library.songs.filtered(by: .albumId(albumId)) {
            totalRuntime += song.runtime
        }

        return totalRuntime
    }
}

#if DEBUG
// swiftlint:disable all

#Preview {
    NavigationStack {
        ArtistDetailScreen(artist: PreviewData.artist)
            .environmentObject(PreviewUtils.apiClient)
            .environmentObject(PreviewUtils.libraryRepo)
    }
}

// swiftlint:enable all
#endif
