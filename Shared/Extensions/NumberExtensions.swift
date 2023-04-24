import Foundation

extension Int64 {
    var timeInterval: TimeInterval {
        let ticksPerSecond: Int64 = 10_000_000
        return Double(self / ticksPerSecond)
    }
}

extension TimeInterval {
    var timeString: String {
        let minutes = Int(self) / 60
        let seconds = Int(self) % 60
        return String(format: "%01d:%02d", minutes, seconds)
    }
}
