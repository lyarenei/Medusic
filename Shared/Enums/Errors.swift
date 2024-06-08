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
    case removeFailed(reason: String)

    var localizedDescription: String {
        switch self {
        case .integrityCheckFailed(let reason):
            return "Integrity check failed: \(reason)"
        case .takenSpaceFailure:
            return "Could not calculate taken space."
        case .notFound:
            return "File does not exist."
        case .removeFailed(let reason):
            return "File remove failed: \(reason)"
        }
    }
}

enum DownloaderError: Error {
    case cacheIsFull
    case fileDownloadFailed
    case enqueueFailed
    case dequeueFailed

    var localizedDescription: String {
        switch self {
        case .cacheIsFull:
            return "Downloaded directory cache is full."
        case .fileDownloadFailed:
            return "File download failed."
        case .enqueueFailed:
            return "Failed to add download to queue."
        case .dequeueFailed:
            return "Failed to remove download from queue."
        }
    }
}
