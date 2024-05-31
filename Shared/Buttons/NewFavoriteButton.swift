import ButtonKit
import OSLog
import SFSafeSymbols
import SwiftData
import SwiftUI

struct NewFavoriteButton: View {
    let itemId: PersistentIdentifier

    @State
    var isFavorite: Bool

    let apiClient: ApiClient = .shared

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
            let actor = try BackgroundDataManager()
            try await actor.setFavoriteSong(id: itemId, isFavorite: !isFavorite)
            withAnimation { isFavorite.toggle() }
        } catch let error as DataManagerError {
            Alerts.error("Operation failed", reason: error.localizedDescription)
        } catch {
            Alerts.error("Operation failed")
        }
    }
}
