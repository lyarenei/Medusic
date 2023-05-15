import SFSafeSymbols
import SwiftUI

struct AlbumDetailScreen: View {
    @ObservedObject
    var albumRepo: AlbumRepository

    @ObservedObject
    var songRepo: SongRepository

    let album: Album

    init(
        for album: Album,
        albumRepo: AlbumRepository = .shared,
        songRepo: SongRepository = .shared
    ) {
        self.album = album
        _albumRepo = ObservedObject(wrappedValue: albumRepo)
        _songRepo = ObservedObject(wrappedValue: songRepo)
    }

    var body: some View {
        ScrollView {
            VStack {
                AlbumHeading(album: album)
                    .padding(.bottom, 10)

                AlbumActions(album: album)
                    .padding(.bottom, 20)

                if songRepo.songs.getAlbumDiscCount(albumId: album.uuid) <= 1 {
                    Divider()
                        .padding(.leading)
                }

                albumSongs()
                stats()
                    .padding(.vertical, 8)
            }
            .padding(.top, 15)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                albumToolbarMenu()
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                RefreshButton(mode: .album(id: album.uuid))
            }
        }
    }

    @ViewBuilder
    private func albumSongs() -> some View {
        if songRepo.songs.filterByAlbum(id: album.uuid).isEmpty {
            Text("No songs available")
                .foregroundColor(.gray)
                .font(.title3)
        } else {
            songList()
        }
    }

    @ViewBuilder
    private func stats() -> some View {
        let sum = songRepo.songs.filterByAlbum(id: album.uuid).count
        if sum > 0 {
            let runtime = songRepo.songs.getRuntime(for: album.uuid)
            Text("\(sum) songs, \(runtime.minutes) minutes")
                .foregroundColor(.gray)
                .font(.system(size: 16))
        }
    }

    @ViewBuilder
    private func songList() -> some View {
        let discCount = songRepo.songs.getAlbumDiscCount(albumId: album.uuid)
        if discCount > 1 {
            ForEach(enumerating: 1...discCount) { idx in
                let songs = songRepo.songs.filterByAlbum(id: album.uuid).filterByAlbumDisc(idx)
                Section {
                    songCollection(
                        songs: songs.sortByIndex(),
                        showLastDivider: idx == discCount
                    )
                } header: {
                    discGroupHeader(text: "Disc \(idx)")
                }
            }
        } else {
            songCollection(
                songs: songRepo.songs.filterByAlbum(id: album.uuid),
                showLastDivider: true
            )
        }
    }

    @ViewBuilder
    private func songCollection(songs: [Song], showLastDivider: Bool) -> some View {
        SongCollection(songs: songs)
            .showAlbumOrder()
            .showArtistName()
            .collectionType(.plain)
            .rowHeight(30)
            .showLastDivider(showLastDivider)
            .font(.system(size: 16))
    }

    @ViewBuilder
    private func discGroupHeader(text: String) -> some View {
        ZStack {
            Color(UIColor.systemGroupedBackground)

            HStack {
                Text(text)
                    .foregroundColor(.gray)
                    .font(.system(size: 16))

                Spacer()
            }
            .padding(.leading)
            .padding(.top)
            .padding(.bottom, 5)
        }
    }

    @ViewBuilder
    private func albumToolbarMenu() -> some View {
        Menu {
            AlbumContextMenu(album: album)
        } label: {
            Image(systemSymbol: .ellipsisCircle)
                .imageScale(.large)
        }
    }
}

#if DEBUG
// swiftlint:disable all
struct AlbumDetailScreen_Previews: PreviewProvider {
    static var previews: some View {
        AlbumDetailScreen(
            for: PreviewData.albums.first!,
            albumRepo: .init(
                store: .previewStore(
                    items: PreviewData.albums,
                    cacheIdentifier: \.uuid
                )
            ),
            songRepo: .init(
                store: .previewStore(
                    items: PreviewData.songs,
                    cacheIdentifier: \.uuid
                )
            )
        )
        .previewDisplayName("Default")

        NavigationView {
            AlbumDetailScreen(
                for: PreviewData.albums.first!,
                albumRepo: .init(
                    store: .previewStore(
                        items: PreviewData.albums,
                        cacheIdentifier: \.uuid
                    )
                ),
                songRepo: .init(
                    store: .previewStore(
                        items: PreviewData.songs,
                        cacheIdentifier: \.uuid
                    )
                )
            )
        }
        .previewDisplayName("With nav")

        AlbumDetailScreen(
            for: PreviewData.albums.first!,
            albumRepo: .init(
                store: .previewStore(
                    items: PreviewData.albums,
                    cacheIdentifier: \.uuid
                )
            ),
            songRepo: .init(
                store: .previewStore(
                    items: [],
                    cacheIdentifier: \.uuid
                )
            )
        )
        .previewDisplayName("Empty")
    }
}
// swiftlint:enable all
#endif

// MARK: - Album heading component

private struct AlbumHeading: View {
    var album: Album

    var body: some View {
        VStack(spacing: 20) {
            ArtworkComponent(itemId: album.id)
                .frame(width: 270, height: 270)

            VStack(spacing: 5) {
                Text(album.name)
                    .font(.title3)
                    .bold()
                    .multilineTextAlignment(.center)

                Text(album.artistName)
                    .font(.body)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.leading, 20)
        .padding(.trailing, 20)
    }
}

// MARK: - Album actions component

private struct AlbumActions: View {
    let album: Album

    var body: some View {
        HStack {
            PlayButton(text: "Play", item: album)
                .frame(width: 120, height: 37)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(style: StrokeStyle(lineWidth: 1.0))
                )

            Button {
                // Album shuffle play action
            } label: {
                Image(systemSymbol: .shuffle)
                Text("Shuffle")
            }
            .frame(width: 120, height: 37)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(style: StrokeStyle(lineWidth: 1.0))
            )
            .disabled(true)
        }
    }
}
