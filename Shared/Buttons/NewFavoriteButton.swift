import ButtonKit
import OSLog
import SFSafeSymbols
import SwiftData
import SwiftUI

struct NewFavoriteButton<Item: JellyfinItemModel>: View {
    @Environment(\.modelContext)
    var context: ModelContext

    @Bindable
    var item: Item

    let apiClient: ApiClient = .shared

    var body: some View {
        let symbol: SFSymbol = item.isFavorite ? .heartFill : .heart
        let text = item.isFavorite ? "Undo favorite" : "Favorite"
        AsyncButton {
            await action()
        } label: {
            Label(text, systemSymbol: symbol)
                .contentTransition(.symbolEffect(.replace))
        }
        .sensoryFeedback(.success, trigger: item.isFavorite) { old, new in !old && new }
        .sensoryFeedback(.impact, trigger: item.isFavorite) { old, new in old && !new }
        .disabledWhenLoading()
    }

    private func action() async {
        do {
            try await apiClient.services.mediaService.setFavorite(itemId: item.jellyfinId, isFavorite: !item.isFavorite)
            withAnimation { item.isFavorite.toggle() }
            try context.save()
        } catch {
            Logger.jellyfin.warning("Failed to update favorite status: \(error.localizedDescription)")
            Alerts.error("Action failed")
        }
    }
}
