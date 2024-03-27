import Defaults
import SwiftUI

extension Defaults.Keys {
    // Jellyfin settings
    static let serverUrl = Key<String>("serverUrl", default: .empty)
    static let username = Key<String>("username", default: .empty)
    static let userId = Key<String>("userId", default: .empty)

    static let deviceName = Key<String>("deviceName", default: "device_name_not_set")
    static let deviceId = Key<String>("deviceId", default: "device_id_not_set")

    // Appearance settings
    static let albumDisplayMode = Key<AlbumDisplayMode>("albumDisplayMode", default: .asTiles)
    static let primaryAction = Key<PrimaryAction>("primaryAction", default: .download)
    static let libraryShowFavorites = Key<Bool>("libraryShowFavorites", default: true)
    static let libraryShowRecentlyAdded = Key<Bool>("libraryShowRecentlyAdded", default: true)
    static let maxPreviewItems = Key<Int>("maxPreviewItems", default: 10)
    static let appColorScheme = Key<AppColorScheme>("appColorScheme", default: .system)

    // App settings
    static let offlineMode = Key<Bool>("offlineMode", default: false)
    static let maxCacheSize = Key<UInt64>("maxCacheSize", default: 1000)
    static let streamBitrate = Key<Int>("streamBitrate", default: -1)
    static let downloadBitrate = Key<Int>("downloadBitrate", default: -1)

    // Developer settings
    static let previewMode = Key<Bool>("previewMode", default: false)
    static let readOnly = Key<Bool>("readOnly", default: false)
    static let restorePlaybackQueue = Key<Bool>("restorePlaybackQueue", default: false)
}

enum PrimaryAction: String, Defaults.Serializable {
    case download
    case favorite
}

enum AppColorScheme: Int, Defaults.Serializable {
    case system
    case light
    case dark
}

extension AppColorScheme {
    var asColorScheme: ColorScheme? {
        switch self {
        case .system:
            return nil
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
}
