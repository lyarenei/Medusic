import Defaults

extension Defaults.Keys {
    // Jellyfin settings
    static let serverUrl = Key<String>("serverUrl", default: "")
    static let username = Key<String>("username", default: "")
    static let userId = Key<String>("userId", default: "")

    // Appearance settings
    static let albumDisplayMode = Key<AlbumDisplayMode>("albumDisplayMode", default: .asTiles)
    static let primaryAction = Key<PrimaryAction>("primaryAction", default: .download)

    // App settings
    static let offlineMode = Key<Bool>("offlineMode", default: false)
    static let previewMode = Key<Bool>("previewMode", default: false)
    static let maxCacheSize = Key<UInt64>("maxCacheSize", default: 1000)
}

enum PrimaryAction: String, Defaults.Serializable {
    case download
    case favorite
}
