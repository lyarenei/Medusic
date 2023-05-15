import Foundation

extension Int64 {
    var timeInterval: TimeInterval {
        let ticksPerSecond: Int64 = 10_000_000
        return Double(self / ticksPerSecond)
    }
}

extension TimeInterval {
    /// Express this interval in seconds.
    var seconds: Int {
        guard !isInfinite && !isNaN else { return 0 }
        return Int(self) % 60
    }

    /// Express this interval in minutes.
    var minutes: Int {
        guard !isInfinite && !isNaN else { return 0 }
        return Int(self) / 60
    }

    /// Format this interval into minutes:seconds.
    var timeString: String {
        String(format: "%01d:%02d", minutes, seconds)
    }

    var ticks: Int64 {
        guard !isInfinite && !isNaN else { return 0 }
        let ticksPerSecond: Int64 = 10_000_000
        return Int64(rounded(.toNearestOrAwayFromZero)) * ticksPerSecond
    }
}
