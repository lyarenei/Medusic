import OSLog

extension Logger {
    // swiftlint:disable:next force_unwrapping
    private static var subsystem = Bundle.main.bundleIdentifier!

    static let library = Logger(subsystem: subsystem, category: "library")
    static let jellyfin = Logger(subsystem: subsystem, category: "jellyfin")
    static let repository = Logger(subsystem: subsystem, category: "repository")
    static let player = Logger(subsystem: subsystem, category: "player")
    static let artwork = Logger(subsystem: subsystem, category: "artwork")
    static let downloader = Logger(subsystem: subsystem, category: "downloader")

    static let notifier = Logger(subsystem: subsystem, category: "notifier")
}

extension Logger {
    func logDebug(_ err: Error) {
        debug("\(err.localizedDescription)")
    }

    func logInfo(_ err: Error) {
        info("\(err.localizedDescription)")
    }

    func logWarn(_ err: Error) {
        warning("\(err.localizedDescription)")
    }

    func logErr(_ err: Error) {
        error("\(err.localizedDescription)")
    }
}
