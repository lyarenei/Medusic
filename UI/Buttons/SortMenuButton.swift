import SwiftUI

enum UserSortBy {
    case name
}

struct SortMenuButton: View {
    @Binding
    var sortBy: UserSortBy

    var body: some View {
        Menu {
            sortByNameButton
        } label: {
            switch sortBy {
            case .name:
                Image(systemSymbol: .textformat)
            }
        }
    }

    @ViewBuilder
    private var sortByNameButton: some View {
        Button {
            sortBy = .name
        } label: {
            Label("Name", systemSymbol: .textformat)
        }
    }
}

struct SortMenuButton_Previews: PreviewProvider {
    @State
    static var sortBy: UserSortBy = .name

    static var previews: some View {
        SortMenuButton(sortBy: $sortBy)
    }
}
