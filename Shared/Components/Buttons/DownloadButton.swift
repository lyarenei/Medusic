import SwiftUI

struct DownloadButton: View {
    @Binding
    var isDownloaded: Bool

    var body: some View {
        Button {
            // Song download action
        } label: {
            DownloadedIcon(isDownloaded: $isDownloaded)
        }
    }
}

#if DEBUG
struct DownloadButton_Previews: PreviewProvider {
    @State
    static var isDownloaded = true

    static var previews: some View {
        DownloadButton(isDownloaded: $isDownloaded)
    }
}
#endif
