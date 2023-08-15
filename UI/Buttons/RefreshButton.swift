import OSLog
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
        let text = "Refreshing"
        do {
            switch mode {
            case .artist(let id):
                Alerts.info("\(text) artist...")
                try await library.refresh(artistId: id)
            case .album(let id):
                Alerts.info("\(text) album...")
                try await library.refresh(albumId: id)
                try await library.refreshSongs(for: id)
            case .allArtists:
                Alerts.info("\(text) artists...")
                try await library.refreshArtists()
            case .allAlbums:
                Alerts.info("\(text) albums...")
                try await library.refreshAlbums()
                try await library.refreshSongs()
            case .allSongs:
                Alerts.info("\(text) songs...")
                try await library.refreshSongs()
            case .all:
                Alerts.info("\(text)...")
                try await library.refreshAll()
            }

            Alerts.done("\(text) complete")
        } catch {
            Logger.library.info("\(text) failed: \(error.localizedDescription)")
            Alerts.error("\(text) failed")
        }
    }

    enum ButtonMode {
        case artist(id: String)
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
