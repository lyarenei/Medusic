import Defaults
import Foundation
import SwiftUI

struct GeneralSettings: View {
    @Default(.streamBitrate)
    private var streamBitrate: Int

    @Default(.downloadBitrate)
    private var downloadBitrate: Int

    var body: some View {
        Section {
            streamBitrateOption
            downloadBitrateOption
        }
    }

    @ViewBuilder
    private var streamBitrateOption: some View {
        Picker("Stream quality (kbps)", selection: $streamBitrate) {
            Text("Original").tag(-1)
            Text("320").tag(320_000)
            Text("256").tag(256_000)
            Text("192").tag(192_000)
            Text("128").tag(128_000)
            Text("64").tag(064_000)
        }
    }

    @ViewBuilder
    private var downloadBitrateOption: some View {
        Picker("Download quality (kbps)", selection: $downloadBitrate) {
            Text("Original").tag(-1)
            Text("320").tag(320_000)
            Text("256").tag(256_000)
            Text("192").tag(192_000)
            Text("128").tag(128_000)
            Text("64").tag(064_000)
        }
    }
}
