import Defaults
import SwiftUI

extension Defaults.Keys {
    // MARK: - Jellyfin settings

    static let serverUrl = Key<String>("serverUrl", default: "")
    static let username = Key<String>("username", default: "")
    static let userId = Key<String>("userId", default: "")

    // MARK: - App settings

    static let offlineMode = Key<Bool>("offlineMode", default: false)
}
