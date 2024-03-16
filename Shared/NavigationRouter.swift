import Foundation
import SwiftUI

final class NavigationRouter: ObservableObject {
    @Published
    var settingsPath = NavigationPath()
}

enum SettingsNav {
    case advanced
    case jellyfin

    #if DEBUG
    case developer
    #endif
}
