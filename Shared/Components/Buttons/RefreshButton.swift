import SFSafeSymbols
import SwiftUI

struct RefreshButton: View {
    @State
    var inProgress: Bool = false

    let text: String?
    let itemId: String?
    let mode: ButtonMode

    init(
        _ text: String? = nil,
        for itemId: String? = nil,
        mode: ButtonMode
    ) {
        self.text = text
        self.itemId = itemId
        self.mode = mode
    }

    var body: some View {
        if inProgress {
            ProgressView()
        } else {
            Button {
                action()
            } label: {
                Image(systemSymbol: .arrowClockwise)
                if let text = text {
                    Text(text)
                }
            }
        }
    }

    func action() {
        inProgress = true
        Task(priority: .userInitiated) {
            defer { setInProgress(false) }
            do {
                switch mode {
                case .allAlbums:
                    try await AlbumRepository.shared.refresh()
                case .allSongs:
                    try await SongRepository.shared.refresh()
                }
            } catch {
                print("Refresh failed")
            }
        }
    }

    func setInProgress(_ isInProgress: Bool) {
        Task(priority: .background) {
            await MainActor.run {
                self.inProgress = isInProgress
            }
        }
    }

    enum ButtonMode {
        case allAlbums
        case allSongs
    }
}

#if DEBUG
struct RefreshButton_Previews: PreviewProvider {
    static var previews: some View {
        RefreshButton(mode: .allAlbums)
    }
}
#endif
