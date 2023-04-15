import SFSafeSymbols
import SwiftUI

struct DownloadIcon: View {
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
    static var previews: some View {
        DownloadIcon(isDownloaded: true)
        DownloadIcon(isDownloaded: false)
    }
}
#endif
