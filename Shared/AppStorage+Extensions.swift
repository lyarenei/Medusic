import SwiftUI

extension AppStorage {
    public init(wrappedValue: Value, _ key: SettingsKeys) where Value == Bool {
        self.init(wrappedValue: wrappedValue, key.rawValue)
    }

    public init(wrappedValue: Value, _ key: SettingsKeys) where Value == String {
        self.init(wrappedValue: wrappedValue, key.rawValue)
    }

    public init(wrappedValue: Value, _ key: SettingsKeys) where Value == Int {
        self.init(wrappedValue: wrappedValue, key.rawValue)
    }
}

public enum SettingsKeys: String {
    case serverUrl = "serverUrl"
    case username = "username"
    case userId = "userId"
}
