import AVKit
import SwiftUI
import UIKit

struct AirPlayComponent: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        AVRoutePickerView()
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

#if DEBUG
struct AirPlayComponent_Previews: PreviewProvider {
    static var previews: some View {
        AirPlayComponent()
    }
}
#endif
