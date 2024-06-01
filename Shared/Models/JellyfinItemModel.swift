import Foundation
import SwiftData

protocol JellyfinItemModel: PersistentModel, Equatable {
    var jellyfinId: String { get }
    var name: String { get }
    var isFavorite: Bool { get set }
}
