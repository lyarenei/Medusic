import Foundation

enum ServiceError: Error {
    case invalidResult
    case notFound
}

enum LibraryError: Error {
    case notFound

    var localizedDescription: String {
        switch self {
        case .notFound:
            return "Item does not exist in the library."
        }
    }
}
