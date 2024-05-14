import ButtonKit
import SwiftData
import SwiftUI

struct IPadRefreshButton: View {
    var body: some View {
        AsyncButton {
            await action()
        } label: {
            Label("Refresh library", systemSymbol: .arrowTriangle2Circlepath)
        }
        .disabledWhenLoading()
    }

    private func action() async {
        do {
            let container = try ModelContainer(for: Artist.self, Album.self, Song.self)
            let manager = BackgroundDataManager(with: container)
            try await manager.refreshLibrary()
        } catch {
            Alerts.error("Refresh failed", reason: error.localizedDescription)
        }
    }
}
