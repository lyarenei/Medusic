import Foundation

final class MediaRepository {
    private let api: ApiClient

    init() {
        self.api = ApiClient()
    }
}
