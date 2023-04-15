import SwiftUI

extension View {
    /// Hide list row separator.
    ///
    /// Taken from https://stackoverflow.com/a/64350901
    @ViewBuilder
    func hideListRowSeparator() -> some View {
        if #available(iOS 15.0, *) {
            listRowSeparator(.hidden)
        } else {
            frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                .listRowInsets(EdgeInsets(top: -1, leading: -1, bottom: -1, trailing: -1))
                .background(Color(.systemBackground))
        }
    }
}
