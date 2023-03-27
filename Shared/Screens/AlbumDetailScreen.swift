import Kingfisher
import SFSafeSymbols
import SwiftUI
import SwiftUIBackports

struct AlbumDetailScreen: View {
    @StateObject
    private var controller: AlbumDetailController

    init (for itemId: String) {
        self._controller = StateObject(wrappedValue: AlbumDetailController(albumId: itemId))
    }

    init(_ controller: AlbumDetailController) {
        self._controller = StateObject(wrappedValue: controller)
    }

    var body: some View {
        Group {
            if let album = controller.album {
                ScrollView {
                    VStack {
                        AlbumHeading(album: album)
                            .padding(.bottom, 10)

                        AlbumActions()
                            .padding(.bottom, 30)

                        SongCollection(
                            songs: controller.songs,
                            showAlbumOrder: true,
                            showArtwork: false,
                            showAction: true,
                            showArtistName: false
                        )
                        .padding(.horizontal)
                    }
                    .padding(.top, 15)
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar(content: {
                    ToolbarItem(content: {
                        PrimaryActionButton(for: album.uuid)
                            .disabled(true)
                    })
                })
            } else {
                Text("Failed to load album data")
            }
        }
        .onAppear { self.controller.setAlbum() }
        .onAppear { self.controller.setSongs() }
        .fixNavTitleTransition()
        .backport.refreshable { await self.controller.refresh() }
    }
}

#if DEBUG
struct AlbumDetailScreen_Previews: PreviewProvider {
    static var previews: some View {
        AlbumDetailScreen(AlbumDetailController(
            albumId: "1",
            albumRepo: AlbumRepository(store: .previewStore(items: PreviewData.albums, cacheIdentifier: \.uuid)),
            songRepo: SongRepository(store: .previewStore(items: PreviewData.songs, cacheIdentifier: \.uuid))
        ))
        AlbumDetailScreen(AlbumDetailController(
            albumId: "2",
            albumRepo: AlbumRepository(store: .previewStore(items: PreviewData.albums, cacheIdentifier: \.uuid)),
            songRepo: SongRepository(store: .previewStore(items: PreviewData.songs, cacheIdentifier: \.uuid))
        ))
    }
}
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
    var body: some View {
        HStack {
            Button {
                // Album play action
            } label: {
                Image(systemSymbol: .playFill)
                Text("Play")
            }
            .frame(width: 120, height: 37)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(style: StrokeStyle(lineWidth: 1.0))
            )
            .disabled(true)

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

// MARK: - Song list component

private struct SongList: View {
    var songs: [Song]?

    var body: some View {
        if let allSongs = songs, allSongs.isEmpty {
            Text("No songs available")
                .font(.title3)
                .foregroundColor(Color(UIColor.secondaryLabel))
        } else if let allSongs = songs {
            LazyVStack {
                ForEach(allSongs) { song in
                    SongEntryComponent(
                        song: song,
                        showAlbumOrder: true,
                        showArtwork: false,
                        showAction: true
                    )
                    .padding(.leading)
                    .padding(.trailing)
                    .font(.title3)

                    Divider()
                        .padding(.leading, 10)
                        .padding(.trailing, 10)
                }
            }
        } else {
            ProgressView()
        }
    }
}

extension View {
    func fixNavTitleTransition() -> some View {
        self.padding(.top, -0.3)
    }
}
