import SwiftUI

struct FavoriteButton: View {
    @Binding
    var isFavorite: Bool

    var body: some View {
        Button {
            // Song like action
        } label: {
            FavoriteIcon(isFavorite: $isFavorite)
        }
    }
}

#if DEBUG
struct FavoriteButton_Previews: PreviewProvider {
    @State
    static var isFavorite = true

    static var previews: some View {
        FavoriteButton(isFavorite: $isFavorite)
    }
}
#endif
