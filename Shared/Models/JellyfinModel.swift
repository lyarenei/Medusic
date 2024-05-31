import Foundation
import SwiftData

protocol JellyfinModel: PersistentModel, Equatable {
    var jellyfinId: String { get }
    var name: String { get }
    var isFavorite: Bool { get set }
}
