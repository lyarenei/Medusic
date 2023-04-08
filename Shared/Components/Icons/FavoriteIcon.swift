import SFSafeSymbols
import SwiftUI

struct FavoriteIcon: View {
    var isFavorite: Bool

    var body: some View {
        let favoriteIcon: SFSymbol = isFavorite ? .heartSlashFill : .heart
        Image(systemSymbol: favoriteIcon)
            .resizable()
            .scaledToFit()
    }
}

#if DEBUG
struct FavoriteIcon_Previews: PreviewProvider {
    static var previews: some View {
        FavoriteIcon(isFavorite: true)
        FavoriteIcon(isFavorite: false)
    }
}
#endif
