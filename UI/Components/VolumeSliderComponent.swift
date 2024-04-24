import SFSafeSymbols
import SwiftUI

struct VolumeSliderComponent: View {
    var body: some View {
        HStack(alignment: .center) {
            Image(systemSymbol: .speaker)
                .foregroundStyle(Color.gray)

            UIVolumeSlider()

            Image(systemSymbol: .speakerWave3)
                .foregroundStyle(Color.gray)
        }
    }
}

// Volume slider does not work on simulator.

#if targetEnvironment(simulator)

private struct UIVolumeSlider: View {
    @State
    private var value = 0.35

    var body: some View {
        Slider(value: $value)
    }
}

#else

import MediaPlayer
import UIKit

/// Volume slider that can be verically centered.
/// From: https://stackoverflow.com/a/76360501
private struct UIVolumeSlider: UIViewRepresentable {
    class SystemVolumeView: MPVolumeView {
        override func volumeSliderRect(forBounds bounds: CGRect) -> CGRect {
            var newBounds = super.volumeSliderRect(forBounds: bounds)
            newBounds.origin.y = bounds.origin.y
            newBounds.size.height = bounds.size.height
            return newBounds
        }
    }

    func makeUIView(context: Context) -> SystemVolumeView {
        var view = SystemVolumeView(frame: .zero)
        view.showsVolumeSlider = true
        view.showsRouteButton = false
        return view
    }

    func updateUIView(_ view: SystemVolumeView, context: Context) {}
}

#endif
