import Foundation
import UIKit

extension UIDevice {
    static var deviceType: UIUserInterfaceIdiom {
        UIDevice.current.userInterfaceIdiom
    }

    static var isPhone: Bool {
        deviceType == .phone
    }

    static var isTablet: Bool {
        deviceType == .pad
    }
}
