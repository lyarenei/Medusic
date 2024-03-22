import ButtonKit
import MarqueeText
import SFSafeSymbols
import SwiftUI

struct ArtistLibraryScreen: View {
    @State
    private var viewModel: ViewModel

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    init(artists: [Artist], repo: LibraryRepository = .shared) {
        self.viewModel = ViewModel(artists: artists, repo: repo)
    }

    var body: some View {
        content
            .navigationTitle("Artists")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    FilterSortMenuButton(
                        filter: $viewModel.filter,
                        sort: $viewModel.sortBy,
                        sortDirection: $viewModel.sortDirection
                    )
                }

                ToolbarItem(placement: .topBarTrailing) { refreshButton }
            }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.artists.isNotEmpty {
            let artistGroups = viewModel.artists
                .filtered(by: viewModel.filter)
                .sorted(by: viewModel.sortBy)
                .ordered(by: viewModel.sortDirection)
                .grouped(by: .firstLetter)

            List {
                ForEach(enumerating: artistGroups.keys) { key in
                    Section(key) {
                        ForEach(artistGroups[key] ?? []) { artist in
                            NavigationLink {
                                ArtistDetailScreen(artist: artist)
                            } label: {
                                ArtworkComponent(itemId: artist.id)
                                    .frame(width: 40, height: 40)

                                MarqueeText(
                                    text: artist.name,
                                    font: .preferredFont(forTextStyle: .title2),
                                    leftFade: UIConstants.marqueeFadeLen,
                                    rightFade: UIConstants.marqueeFadeLen,
                                    startDelay: UIConstants.marqueeDelay
                                )
                            }
                        }
                    }
                }
            }
            .listStyle(.grouped)
        } else {
            Text("No artists")
                .font(.title3)
                .foregroundColor(.gray)
        }
    }

    @ViewBuilder
    private var refreshButton: some View {
        AsyncButton {
            await viewModel.onRefreshButton()
        } label: {
            Image(systemSymbol: .arrowClockwise)
                .scaledToFit()
        }
    }
}

#Preview("With navigation") {
    NavigationStack {
        ArtistLibraryScreen(artists: PreviewData.artists, repo: PreviewUtils.libraryRepo)
    }
}

#Preview("Plain") {
    ArtistLibraryScreen(artists: PreviewData.artists, repo: PreviewUtils.libraryRepo)
}
