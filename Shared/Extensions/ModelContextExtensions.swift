import Foundation
import OSLog
import SwiftData

/// From: https://useyourloaf.com/blog/swiftdata-fetching-an-existing-object/
extension ModelContext {
    func existingModel<T: PersistentModel>(for objectId: PersistentIdentifier) -> T? {
        if let model: T = registeredModel(for: objectId) {
            return model
        }

        let fetchDesc = FetchDescriptor<T>(
            predicate: #Predicate { $0.persistentModelID == objectId }
        )

        do {
            return try fetch(fetchDesc).first
        } catch {
            Logger.library.debug("Failed to fetch object: \(error.localizedDescription)")
            return nil
        }
    }

    func existingMode<T: JellyfinModel>(for jellyfinId: String) -> T? {
        let fetchDesc = FetchDescriptor<T>(
            predicate: #Predicate { $0.jellyfinId == jellyfinId }
        )

        do {
            return try fetch(fetchDesc).first
        } catch {
            Logger.library.debug("Failed to fetch object: \(error.localizedDescription)")
            return nil
        }
    }
}
