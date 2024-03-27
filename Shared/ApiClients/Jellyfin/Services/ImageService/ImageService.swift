import Foundation
import Kingfisher

protocol ImageService: ObservableObject {
    func getImage(for itemId: String) async throws -> Data
    func getImage(for itemId: String, size: CGSize) async throws -> Data
}
