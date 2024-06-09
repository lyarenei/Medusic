import Foundation

enum LibraryRepositoryError: MedusicError {
    case notFound
    case actionFailed(reason: String)
}

extension LibraryRepositoryError {
    var errorDescription: String? {
        switch self {
        case .notFound:
            return "Item does not exist"
        case .actionFailed:
            return "Action failed"
        }
    }

    var failureReason: String? {
        switch self {
        case .actionFailed(let reason):
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
