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
                try await SongRepository.shared.refresh(for: id)
            case .allAlbums:
                try await library.refreshAlbums()
            case .allSongs:
                try await SongRepository.shared.refresh()
            case .all:
                try await library.refreshAll()
                try await SongRepository.shared.refresh()
            }
        } catch {
            print("Refresh failed")
        }
    }

    enum ButtonMode {
        case album(id: String)
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
