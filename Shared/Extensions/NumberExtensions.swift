import Foundation

extension Int {
    var timeInterval: TimeInterval {
        let ticksPerSecond = 10_000_000
        return Double(self / ticksPerSecond)
    }
}

extension TimeInterval {
    /// Express this interval in seconds.
    var seconds: Int {
        guard !isInfinite else { return 0 }
        guard !isNaN else { return 0 }
        return Int(self) % 60
    }

    /// Express this interval in minutes.
    var minutes: Int {
        guard !isInfinite else { return 0 }
        guard !isNaN else { return 0 }
        return Int(self) / 60
    }

    /// Format this interval into minutes:seconds.
    var timeString: String {
        String(format: "%01d:%02d", minutes, seconds)
    }

    var ticks: Int {
        guard !isInfinite else { return 0 }
        guard !isNaN else { return 0 }
        let ticksPerSecond = 10_000_000
        return Int(rounded(.toNearestOrAwayFromZero)) * ticksPerSecond
    }
}
