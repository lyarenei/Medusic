import OSLog

extension Logger {
    private static var subsystem = Bundle.main.bundleIdentifier!

    static let library = Logger(subsystem: subsystem, category: "library")
    static let jellyfin = Logger(subsystem: subsystem, category: "jellyfin")
    static let repository = Logger(subsystem: subsystem, category: "repository")
    static let player = Logger(subsystem: subsystem, category: "player")
}
