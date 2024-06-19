import MarqueeLabel
import SwiftUI

struct MarqueeTextComponent: UIViewRepresentable {
    var text: String
    var font: Font
    var color: Color

    init(_ text: String, font: Font = .body, color: Color = .primary) {
        self.text = text
        self.font = font
        self.color = color
    }

    func makeUIView(context: Context) -> MarqueeLabel {
        let label = MarqueeLabel()

        label.text = text
        label.fadeLength = UIConstants.marqueeFadeLen
        label.animationDelay = UIConstants.marqueeDelay
        label.font = font.uiFont
        label.textColor = color.toUIColor()
        label.speed = .rate(UIConstants.marqueeSpeed)

        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        label.isUserInteractionEnabled = false

        return label
    }

    func updateUIView(_ uiView: MarqueeLabel, context: Context) {
        uiView.text = text
        uiView.font = font.uiFont
        uiView.textColor = color.toUIColor()
        uiView.restartLabel()
    }
}

#if DEBUG
// swiftlint:disable all

#Preview {
    MarqueeTextComponent("A very long text that can't possibly ever fit on a phone screen in portrait orientation.")
}

// swiftlint:enable all
#endif
