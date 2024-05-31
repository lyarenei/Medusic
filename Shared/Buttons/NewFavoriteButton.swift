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
        .onReceive(NotificationCenter.default.publisher(for: .FavoriteStatusChanged)) { event in
            // Note: This is only because of the button in menu does not get properly updated
            // if there would be a simple toggle in button action.
            guard let data = event.userInfo,
                  let id = data["itemId"] as? PersistentIdentifier,
                  let isFavorite = data["isFavorite"] as? Bool
            else { return }

            // This apparently does some black magic as itemId == id evaluates to false
            if let song = ctx.model(for: id) as? Song {
                withAnimation { self.isFavorite = isFavorite }
            }
        }
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
