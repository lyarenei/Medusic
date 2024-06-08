import Foundation

enum ServiceError: Error {
    case invalidResult
    case notFound
}

enum LibraryError: Error {
    case notFound
    case saveFailed

    var localizedDescription: String {
        switch self {
        case .notFound:
            return "Item does not exist in the library."
        case .saveFailed:
            return "Saving changes failed."
        }
    }
}

enum FileRepositoryError: Error {
    case integrityCheckFailed(reason: String)
    case takenSpaceFailure
    case notFound
    case removeFailed

    var localizedDescription: String {
        switch self {
        case .integrityCheckFailed(let reason):
            return "Integrity check failed: \(reason)"
        case .takenSpaceFailure:
            return "Could not calculate taken space."
        case .notFound:
            return "File does not exist."
        case .removeFailed:
            return "File remove failed."
        }
    }
}
