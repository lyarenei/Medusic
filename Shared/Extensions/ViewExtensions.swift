import Foundation
import SwiftUI

struct CircleBackground: ViewModifier {
    let material: Material

    func body(content: Content) -> some View {
        content
            .background {
                Circle()
                    .fill(.ultraThickMaterial)
            }
    }
}

extension View {
    func circleBackground(material: Material = .ultraThickMaterial) -> some View {
        modifier(CircleBackground(material: material))
    }
}
