import Foundation

protocol ImageService: ObservableObject {
    func getImage(for itemId: String) async throws -> Optional<Data>
}
