import SFSafeSymbols
import SwiftUI

struct DownloadIcon: View {
    var isDownloaded: Bool

    var body: some View {
        Image(systemSymbol: isDownloaded ? .trash : .icloudAndArrowDown)
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
