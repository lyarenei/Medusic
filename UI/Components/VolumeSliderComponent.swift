import SwiftUI

// Volume slider does not work on simulator.

#if targetEnvironment(simulator)

struct VolumeSliderComponent: View {
    @State
    private var value = 0.35

    var body: some View {
        Slider(value: $value)
    }
}

#else

import MediaPlayer
import UIKit

struct VolumeSliderComponent: UIViewRepresentable {
    func makeUIView(context: Context) -> MPVolumeView {
        let volumeView = MPVolumeView(frame: .zero)
        // Ignore warning, we don't want the button anyway.
        volumeView.showsRouteButton = false
        return volumeView
    }

    func updateUIView(_ view: MPVolumeView, context: Context) {}
}

#endif
