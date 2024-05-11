import Boutique
import LNPopupUI
import SFSafeSymbols
import SwiftUI

struct MainScreen: View {
    @EnvironmentObject
    private var player: MusicPlayer

    @EnvironmentObject
    private var downloader: Downloader

    @State
    private var showNowPlayingBar = false

    @State
    private var selectedTab: NavigationTab = .library

    var body: some View {
        TabView(selection: $selectedTab) {
            libraryTab
                .tag(NavigationTab.library)

            searchTab
                .tag(NavigationTab.search)

            downloadsTab
                .tag(NavigationTab.downloads)

            settingsTab
                .tag(NavigationTab.settings)
        }
        .onChange(of: player.currentSong) { evaluateBarPresent() }
        .onChange(of: selectedTab) { evaluateBarPresent() }
        .popup(isBarPresented: $showNowPlayingBar) {
            MusicPlayerScreen()
                .padding(.top, 30)
        }
        .popupBarCustomView { NowPlayingBarComponent() }
    }

    @ViewBuilder
    private var libraryTab: some View {
        LibraryScreen()
            .tabItem {
                Image(systemSymbol: .musicQuarternote3)
                Text("Library")
            }
    }

    @ViewBuilder
    private var searchTab: some View {
        SearchScreen()
            .tabItem {
                Image(systemSymbol: .magnifyingglass)
                Text("Search")
            }
    }

    @ViewBuilder
    private var downloadsTab: some View {
        Group {
            if downloader.queue.isEmpty {
                ContentUnavailableView(
                    "No active downloads",
                    systemImage: "",
                    description: Text("Any items currently being downloaded will appear here.")
                )
            } else {
                downloadQueueList
            }
        }
        .tabItem { Label("Downloads", systemSymbol: .icloudAndArrowDown) }
        .badge(downloader.queue.count)
    }

    @ViewBuilder
    private var settingsTab: some View {
        SettingsScreen()
            .tabItem {
                Image(systemSymbol: .gear)
                Text("Settings")
            }
    }

    private func evaluateBarPresent() {
        showNowPlayingBar = player.currentSong != nil && selectedTab != .settings
    }
}

extension MainScreen {
    enum NavigationTab {
        case library
        case search
        case downloads
        case settings
    }
}

extension MainScreen {
    @ViewBuilder
    private var downloadQueueList: some View {
        // TODO: can support download queue removal (think about cancellation and stuff)
        List(downloader.queue) { song in
            HStack {
                Text(song.name)
                Spacer()
                ProgressView()
            }
        }
        .listStyle(.plain)
        .navigationTitle("Downloads")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#if DEBUG
// swiftlint:disable all

#Preview {
    MainScreen()
        .environmentObject(PreviewUtils.libraryRepo)
        .environmentObject(PreviewUtils.player)
        .environmentObject(ApiClient(previewEnabled: true))
        .environmentObject(PreviewUtils.fileRepo)
        .environmentObject(Downloader.shared)
}

// swiftlint:enable all
#endif
