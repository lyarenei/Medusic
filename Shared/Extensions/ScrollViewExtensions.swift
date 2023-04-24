import SwiftUI

extension ScrollView {
    private typealias PaddedContent = ModifiedContent<Content, _PaddingLayout>

    /// Fixes flickering on navigation view when scrolling up with not enough content to need scrolling.
    /// Theoretically might be cause of some issues on newer iOS versions.
    ///
    /// From: https://stackoverflow.com/a/67270977
    func fixFlickering() -> some View {
        GeometryReader { geo in
            ScrollView<PaddedContent>(axes, showsIndicators: showsIndicators) {
                // swiftlint:disable:next force_cast
                content.padding(geo.safeAreaInsets) as! PaddedContent
            }
            .edgesIgnoringSafeArea(.all)
        }
    }
}
