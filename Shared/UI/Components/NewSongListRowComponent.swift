import SwiftUI

struct NewSongListRowComponent<MenuActions: View>: View {
    @EnvironmentObject
    private var library: LibraryRepository

    private var menuActions: (SongDto) -> MenuActions
    private var showArtwork = true
    private var showAlbumIndex = false

    let song: SongDto
    let subtitle: String

    init(
        for song: SongDto,
        subtitle: String = .empty,
        @ViewBuilder menuActions: @escaping (SongDto) -> MenuActions
    ) {
        self.song = song
        self.subtitle = subtitle
        self.menuActions = menuActions
    }

    var body: some View {
        GeometryReader { proxy in
            HStack {
                HStack {
                    Group {
                        if showArtwork {
                            ArtworkComponent(for: song.albumId)
                                .showFavorite(song.isFavorite)
                        } else {
                            Text("\(song.index)")
                        }
                    }
                    .frame(width: proxy.size.height, height: proxy.size.height, alignment: .center)

                    songDetail(name: song.name, subtitle: subtitle)
                        .frame(height: proxy.size.height)

                    Spacer()
                }
                .frame(width: proxy.size.width - proxy.size.height)
                .contentShape(Rectangle())
                .onTapGesture {
                    Alerts.notImplemented()
                }

                Menu {
                    menuActions(song)
                } label: {
                    Image(systemSymbol: .ellipsis)
                        .resizable()
                        .scaledToFit()
                        .padding(12)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .foregroundStyle(Color.accentColor)
                .frame(width: proxy.size.height, height: proxy.size.height)
            }
        }
    }

    @ViewBuilder
    private func songDetail(name: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            MarqueeTextComponent(name, font: .title3)

            if subtitle.isNotEmpty {
                MarqueeTextComponent(subtitle, font: .system(size: 12), color: .gray)
            }
        }
    }
}

extension NewSongListRowComponent {
    func showArtwork(_ value: Bool = true) -> NewSongListRowComponent {
        var view = self
        view.showArtwork = value
        view.showAlbumIndex = !value
        return view
    }

    func showAlbumIndex(_ value: Bool = true) -> NewSongListRowComponent {
        var view = self
        view.showArtwork = !value
        view.showAlbumIndex = value
        return view
    }
}
