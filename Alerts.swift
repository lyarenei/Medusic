import Drops
import SFSafeSymbols
import SwiftUI

enum Alerts {
    static func info(_ text: String) {
        Drops.show(
            .init(
                title: text,
                titleNumberOfLines: 1,
                subtitle: nil,
                subtitleNumberOfLines: 0,
                icon: .init(systemSymbol: .infoCircle),
                action: nil,
                position: .top,
                duration: .recommended,
                accessibility: nil
            )
        )
    }

    static func done(_ text: String) {
        Drops.show(
            .init(
                title: text,
                titleNumberOfLines: 1,
                subtitle: nil,
                subtitleNumberOfLines: 0,
                icon: .checkmark,
                action: nil,
                position: .top,
                duration: .recommended,
                accessibility: nil
            )
        )
    }

    static func error(_ text: String) {
        Drops.show(
            .init(
                title: text,
                titleNumberOfLines: 1,
                subtitle: nil,
                subtitleNumberOfLines: 0,
                icon: .remove,
                action: nil,
                position: .top,
                duration: .recommended,
                accessibility: nil
            )
        )
    }
}
