import SFSafeSymbols
import SwiftData
import SwiftUI

struct IPadArtistDetailScreen: View {
    @Bindable
    var artist: Artist

    var body: some View {
        List {
            artistHeader
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)

            aboutSection
                .listRowSeparator(.hidden)

            albumsSection
                .listSectionSeparatorTint(.systemGroupedBackground)
        }
        .listStyle(.plain)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
//            ToolbarItem(placement: .navigationBarTrailing) { favoriteButton }
//            ToolbarItem(placement: .navigationBarTrailing) { refreshButton }
        }
    }

    @ViewBuilder
    private var artistHeader: some View {
        HStack(spacing: 15) {
            ArtworkComponent(for: artist.jellyfinId)
                .frame(width: 90, height: 90)

            VStack(alignment: .leading, spacing: 10) {
                Text(artist.name)
                    .font(.title)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)

                Text("\(artist.albums.count) albums, \(artist.runtime.minutes) minutes")
                    .font(.footnote)
                    .foregroundColor(.secondaryLabel)
            }
        }
    }

    @ViewBuilder
    private var albumsSection: some View {
        if artist.albums.isNotEmpty {
            Section("Albums (\(artist.albums.count))") {
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
        ForEach(artist.albums, id: \.jellyfinId) { album in
            NavigationLink(value: album) {
                Label {
                    Text(album.name)
                        .font(.title3)
                } icon: {
                    ArtworkComponent(for: album.jellyfinId)
                        .scaledToFit()
                }
                .labelStyle(.titleAndIcon)
            }
            .frame(height: 40)
        }
    }

    @ViewBuilder
    private var aboutSection: some View {
        if artist.aboutInfo.isNotEmpty {
            Section("About") {
                PreviewComponent {
                    Text(artist.aboutInfo)
                        .lineLimit(5)
                } fullView: {
                    ArtistProfile(artist: artist)
                        .presentationDragIndicator(.visible)
                }
            }
        }
    }
}

private struct ArtistProfile: View {
    @Bindable
    var artist: Artist

    var body: some View {
        GeometryReader { proxy in
            List {
                content(proxy)
                    .listRowSeparator(.hidden)
                    .listSectionSeparator(.hidden)
            }
        }
    }

    @ViewBuilder
    private func content(_ proxy: GeometryProxy) -> some View {
        ArtworkComponent(for: artist.jellyfinId)
            .frame(height: min(400, proxy.size.width))

        artistName
        aboutSection
        genreSection
    }

    @ViewBuilder
    private var artwork: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("\(artist.albums.count) albums, \(artist.runtime.minutes) minutes")
                .font(.footnote)
                .foregroundColor(.secondaryLabel)
        }
    }

    @ViewBuilder
    private var artistName: some View {
        Text(artist.name)
            .multilineTextAlignment(.center)
            .font(.title)
    }

    @ViewBuilder
    private var aboutSection: some View {
        if artist.aboutInfo.isNotEmpty {
            VStack(alignment: .leading) {
                Text("About")
                    .font(.caption)
                    .padding(.bottom, 3)
                    .foregroundStyle(Color.gray)

                Text(artist.aboutInfo)
            }
        }
    }

    @ViewBuilder
    private var genreSection: some View {
        VStack(alignment: .leading) {
            Text("Genre")
                .font(.caption)
                .padding(.bottom, 3)
                .foregroundStyle(Color.gray)

            Text("artist.genre")
        }
    }
}

#if DEBUG
// swiftlint:disable all

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Artist.self, configurations: config)

    let artist = Artist(from: PreviewData.artist)
    return IPadArtistDetailScreen(artist: artist)
        .modelContainer(container)
        .environmentObject(ApiClient(previewEnabled: true))
}

// swiftlint:enable all
#endif
