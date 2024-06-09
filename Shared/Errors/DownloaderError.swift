import Foundation

enum DownloaderError: MedusicError {
    case downloadFailed(reason: String)
    case cancelFailed(reason: String)
}

extension DownloaderError {
    var errorDescription: String? {
        switch self {
        case .downloadFailed:
            return "Download failed"
        case .cancelFailed:
            return "Download cancellation failed"
        }
    }

    var failureReason: String? {
        switch self {
        case .downloadFailed(let reason):
            return reason
        case .cancelFailed(let reason):
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
