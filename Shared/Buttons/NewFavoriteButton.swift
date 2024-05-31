import ButtonKit
import OSLog
import SFSafeSymbols
import SwiftData
import SwiftUI

struct NewFavoriteButton: View {
    @Environment(\.modelContext)
    private var ctx: ModelContext

    @State
    private var isFavorite: Bool

    private let itemId: PersistentIdentifier
    private let apiClient: ApiClient

    init(for itemId: PersistentIdentifier, isFavorite: Bool, apiClient: ApiClient = .shared) {
        self.itemId = itemId
        self.isFavorite = isFavorite
        self.apiClient = apiClient
    }

    var body: some View {
        let symbol: SFSymbol = isFavorite ? .heartFill : .heart
        let text = isFavorite ? "Undo favorite" : "Favorite"
        AsyncButton {
            await action()
        } label: {
            Label(text, systemSymbol: symbol)
                .contentTransition(.symbolEffect(.replace))
        }
        .sensoryFeedback(.success, trigger: isFavorite) { old, new in !old && new }
        .sensoryFeedback(.impact, trigger: isFavorite) { old, new in old && !new }
        .disabledWhenLoading()
    }

    private func action() async {
        do {
            let actor = try BackgroundDataManager(using: apiClient)
            try await actor.setFavoriteSong(id: itemId, isFavorite: !isFavorite)
        } catch let error as DataManagerError {
            Alerts.error("Operation failed", reason: error.localizedDescription)
        } catch {
            Alerts.error("Operation failed")
        }
    }
}
