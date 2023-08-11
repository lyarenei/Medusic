import Foundation

struct Artist: Identifiable, Codable {
    var id: String
    var name = ""
    var sortName = ""
}

extension Artist: Equatable {
    public static func == (lhs: Artist, rhs: Artist) -> Bool {
        lhs.id == rhs.id
    }
}
