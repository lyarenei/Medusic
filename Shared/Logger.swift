import OSLog

extension Logger {
    private static var subsystem = Bundle.main.bundleIdentifier!

    static let library = Logger(subsystem: subsystem, category: "library")
}
