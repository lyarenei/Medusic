import MediaPlayer
import SwiftUI
import UIKit

// Does not work in previews, only on real device.

struct VolumeSliderComponent: UIViewRepresentable {
    func makeUIView(context: Context) -> MPVolumeView {
        let volumeView = MPVolumeView(frame: .zero)
        // Despite the warning, the default is true, so the button is displayed.
        volumeView.showsRouteButton = false
        return volumeView
    }

    func updateUIView(_ view: MPVolumeView, context: Context) {}
}
