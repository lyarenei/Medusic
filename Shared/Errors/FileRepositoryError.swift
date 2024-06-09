import Foundation

enum FileRepositoryError: MedusicError {
    case integrityCheckFailed(reason: String)
    case takenSpaceFailure
    case notFound
    case removeFailed(reason: String)
}

extension FileRepositoryError {
    var errorDescription: String? {
        switch self {
        case .integrityCheckFailed:
            return "Integrity check failed"
        case .takenSpaceFailure:
            return "Could not calculate taken space"
        case .notFound:
            return "File does not exist"
        case .removeFailed:
            return "File remove failed"
        }
    }

    var failureReason: String? {
        switch self {
        case .integrityCheckFailed(let reason):
            return reason
        case .removeFailed(let reason):
            return reason
        default:
            return nil
        }
    }

    var localizedDescription: String {
        if let failureReason {
            return "\(errorDescription ?? "missing_description"): \(failureReason)"
        }

        return errorDescription ?? "missing_description"
    }
}
