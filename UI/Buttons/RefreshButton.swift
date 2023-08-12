import SFSafeSymbols
import SwiftUI

struct RefreshButton: View {
    @EnvironmentObject
    private var library: LibraryRepository

    let text: String? = nil
    let mode: ButtonMode

    var body: some View {
        AsyncButton {
            await action()
        } label: {
            if let text {
                Label(text, systemSymbol: .arrowClockwise)
            } else {
                Image(systemSymbol: .arrowClockwise)
            }
        }
    }

    private func action() async {
        do {
            switch mode {
            case .album(let id):
                try await library.refresh(albumId: id)
                try await library.refreshSongs(for: id)
            case .allArtists:
                try await library.refreshArtists()
            case .allAlbums:
                try await library.refreshAlbums()
                try await library.refreshSongs()
            case .allSongs:
                try await library.refreshSongs()
            case .all:
                try await library.refreshAll()
            }
        } catch {
            print("Refresh failed")
        }
    }

    enum ButtonMode {
        case album(id: String)
        case allArtists
        case allAlbums
        case allSongs
        case all
    }
}

#if DEBUG
struct RefreshButton_Previews: PreviewProvider {
    static var previews: some View {
        RefreshButton(mode: .allAlbums)
            .environmentObject(PreviewUtils.libraryRepo)
    }
}
#endif
