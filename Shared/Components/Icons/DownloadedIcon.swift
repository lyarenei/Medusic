import SFSafeSymbols
import SwiftUI

struct DownloadedIcon: View {
    @Binding
    var isDownloaded: Bool

    var body: some View {
        let downloadedIcon: SFSymbol = isDownloaded ? .trash : .icloudAndArrowDown
        Image(systemSymbol: downloadedIcon)
            .resizable()
            .scaledToFit()
    }
}

#if DEBUG
struct DownloadedIcon_Previews: PreviewProvider {
    @State
    static var isDownloaded_yes = true

    @State
    static var isDownloaded_no = false

    static var previews: some View {
        DownloadedIcon(isDownloaded: $isDownloaded_yes)
        DownloadedIcon(isDownloaded: $isDownloaded_no)
    }
}
#endif
