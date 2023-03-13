import Foundation
import Kingfisher

protocol ImageService: ObservableObject {
    func getImage(for itemId: String) async throws -> Data
}
