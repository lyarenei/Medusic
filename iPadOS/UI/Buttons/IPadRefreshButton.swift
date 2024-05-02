import ButtonKit
import OSLog
import SwiftData
import SwiftUI

struct IPadRefreshButton: View {
    private let logger: Logger = .library

    var body: some View {
        AsyncButton {
            await action()
        } label: {
            Label("Refresh data", systemSymbol: .arrowTriangle2Circlepath)
        }
        .disabledWhenLoading()
    }

    private func action() async {
        do {
            let container = try ModelContainer(for: Artist.self)
            let manager = BackgroundDataManager(with: container)
            try await manager.refresh()
        } catch {
            logger.warning("Refreshing data failed: \(error.localizedDescription)")
            Alerts.error("Refresh failed")
        }
    }
}
