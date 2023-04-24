import Foundation

extension String {
    /// Get all matches and capture groups with regex.
    /// First element of sub-array is the match and all subsequent elements are the capture groups.
    ///
    /// From: https://stackoverflow.com/a/56616990
    func match(_ regex: String) -> [[String]] {
        let nsString = self as NSString
        let regex = try? NSRegularExpression(pattern: regex, options: [])
        let range = NSRange(location: 0, length: nsString.length)
        return regex?.matches(in: self, options: [], range: range).map { match in
            (0..<match.numberOfRanges).map { position in
                match.range(at: position).location == NSNotFound ? "" : nsString.substring(with: match.range(at: position))
            }
        } ?? []
    }

    /// Convenience indicator for checking if the string is not empty.
    @inlinable
    public var isNotEmpty: Bool { !isEmpty }
}
