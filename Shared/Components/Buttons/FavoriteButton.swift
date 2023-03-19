import SwiftUI

struct FavoriteButton: View {
    var isFavorite: Bool

    var body: some View {
        Button {
            // Song like action
        } label: {
            FavoriteIcon(isFavorite: isFavorite)
        }
    }
}

#if DEBUG
struct FavoriteButton_Previews: PreviewProvider {
    static var previews: some View {
        FavoriteButton(isFavorite: true)
        FavoriteButton(isFavorite: false)
    }
}
#endif
