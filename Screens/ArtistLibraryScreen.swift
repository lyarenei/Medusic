import ButtonKit
import MarqueeText
import OSLog
import SFSafeSymbols
import SwiftUI

struct ArtistLibraryScreen: View {
    @EnvironmentObject
    private var repo: LibraryRepository

    @State
    var filter: FilterOption = .all

    @State
    var sortBy: SortOption = .name

    @State
    var sortDirection: SortDirection = .ascending

    var body: some View {
        content
            .navigationTitle("Artists")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    FilterSortMenuButton(
                        filter: $filter,
                        sort: $sortBy,
                        sortDirection: $sortDirection
                    )
                }

                ToolbarItem(placement: .topBarTrailing) { refreshButton }
            }
    }

    @ViewBuilder
    private var content: some View {
        if repo.artists.isNotEmpty {
            let artistGroups = repo.artists
                .filtered(by: filter)
                .sorted(by: sortBy)
                .ordered(by: sortDirection)
                .grouped(by: .firstLetter)

            List {
                ForEach(enumerating: artistGroups.keys) { key in
                    if let artists = artistGroups[key] {
                        artistSection(name: key, artists: artists)
                    }
                }
            }
            .listStyle(.plain)
        } else {
            ContentUnavailableView(
                "No artists in library",
                systemImage: "music.mic",
                description: Text("Perhaps you forgot to refresh data from Jellyfin?")
            )
        }
    }

    @ViewBuilder
    private func artistSection(name: String, artists: [Artist]) -> some View {
        Section {
            ForEach(artists) { artist in
                NavigationLink {
                    ArtistDetailScreen(artist: artist)
                } label: {
                    ArtworkComponent(for: artist)
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
        } header: {
            Text(name)
                .bold()
                .foregroundStyle(Color.primary)
                .font(.title3)
        }
    }

    @ViewBuilder
    private var refreshButton: some View {
        AsyncButton {
            await onRefreshButton()
        } label: {
            Image(systemSymbol: .arrowClockwise)
                .scaledToFit()
        }
    }

    private func onRefreshButton() async {
        do {
            try await repo.refreshArtists()
        } catch {
            Logger.repository.warning("Refreshing artists failed: \(error.localizedDescription)")
            Alerts.error("Refresh failed")
        }
    }
}

#Preview("Normal") {
    NavigationStack {
        ArtistLibraryScreen()
            .environmentObject(PreviewUtils.libraryRepo)
            .environmentObject(ApiClient(previewEnabled: true))
    }
}

#Preview("Empty") {
    NavigationStack {
        ArtistLibraryScreen()
            .environmentObject(PreviewUtils.libraryRepoEmpty)
            .environmentObject(ApiClient(previewEnabled: true))
    }
}
