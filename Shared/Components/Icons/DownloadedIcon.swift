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
    static var isDownloadedYes = true

    @State
    static var isDownloadedNo = false

    static var previews: some View {
        DownloadedIcon(isDownloaded: $isDownloadedYes)
        DownloadedIcon(isDownloaded: $isDownloadedNo)
    }
}
#endif
