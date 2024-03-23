import SFSafeSymbols
import SwiftUI

enum FilterOption {
    case all
    case favorite
}

enum SortOption {
    case name
    case dateAdded
}

enum SortDirection {
    case ascending
    case descending
}

struct FilterSortMenuButton: View {
    @Binding
    var filter: FilterOption

    @Binding
    var sort: SortOption

    @Binding
    var sortDirection: SortDirection

    var body: some View {
        Menu {
            filterSection
            sortSection
            sortDirectionSection
        } label: {
            Image(systemSymbol: .line3HorizontalDecrease)
        }
    }

    @ViewBuilder
    private var filterSection: some View {
        Section {
            Button {
                filter = .all
            } label: {
                Text("All")
                if filter == .all {
                    Image(systemSymbol: .checkmark)
                }
            }

            Button {
                filter = .favorite
            } label: {
                Text("Favorites")
                if filter == .favorite {
                    Image(systemSymbol: .checkmark)
                }
            }
        }
    }

    @ViewBuilder
    private var sortSection: some View {
        Section {
            Button {
                sort = .name
            } label: {
                Text("Name")
                if sort == .name {
                    Image(systemSymbol: .checkmark)
                }
            }

            Button {
                sort = .dateAdded
            } label: {
                Text("Date Added")
                if sort == .dateAdded {
                    Image(systemSymbol: .checkmark)
                }
            }
        }
    }

    @ViewBuilder
    private var sortDirectionSection: some View {
        Section {
            Button {
                sortDirection = .ascending
            } label: {
                Text("Ascending")
                if sortDirection == .ascending {
                    Image(systemSymbol: .checkmark)
                }
            }

            Button {
                sortDirection = .descending
            } label: {
                Text("Descending")
                if sortDirection == .descending {
                    Image(systemSymbol: .checkmark)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        Text("View")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    FilterSortMenuButton(
                        filter: .constant(FilterOption.all),
                        sort: .constant(SortOption.name),
                        sortDirection: .constant(SortDirection.ascending)
                    )
                }
            }
    }
}
