import SwiftUI
import Kingfisher

typealias PlatformImage = KFCrossPlatformImage

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
extension Image {
    // Creates an Image with either UIImage or NSImage.
    init(platformImage: PlatformImage?) {
        #if canImport(UIKit)
        self.init(uiImage: platformImage ?? PlatformImage())
        #elseif canImport(AppKit)
        self.init(nsImage: platformImage ?? PlatformImage())
        #endif
    }
}
