import Boutique
import Defaults
import Kingfisher
import SFSafeSymbols
import SwiftUI

struct SettingsScreen: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 10) {
                List {
                    JellyfinSection()
                    GeneralSection()
                }
                .navigationTitle("Settings")
                .listStyle(.grouped)
                .buttonStyle(.plain)
            }
        }
    }
}

#if DEBUG
struct SettingsScreen_Previews: PreviewProvider {
    static var previews: some View {
        SettingsScreen()
            .environment(\.api, .init())
    }
}
#endif

// MARK: - JellyfinSection view

// TODO: Implement validators (url is not garbage, user can log in)
// TODO: Implement controller and move all logic there
private struct JellyfinSection: View {
    @StateObject
    private var controller = JellyfinSettingsController()

    @Default(.serverUrl)
    private var serverUrl: String

    @State
    private var serverUrlEdit: String = ""

    @Default(.username)
    private var username: String

    // TODO: figure out how to securely store this
    @State
    private var password = ""

    var body: some View {
        Section(
            header: Text("Jellyfin"),
            content: {
                InlineInputComponent(
                    labelText: "URL",
                    labelSymbol: .link,
                    inputText: $serverUrlEdit,
                    placeholderText: "Server URL"
                )
                .keyboardType(.URL)
                .disableAutocorrection(true)
                .autocapitalization(.none)
                .onChange(of: serverUrlEdit) { newValue in
                    // TODO: delay to avoid spam
                    if self.validateUrl(newValue) {
                        serverUrl = newValue
                    } else {
                        // TODO: show in UI
                        print("Server URL is not valid")
                    }
                }
                .onAppear {
                    // TODO:
                    serverUrlEdit = serverUrl
                }

                InlineInputComponent(
                    labelText: "Username",
                    labelSymbol: .personCropCircle,
                    inputText: $username,
                    placeholderText: "Account username"
                )
                .disableAutocorrection(true)
                .autocapitalization(.none)

                InlineInputComponent(
                    labelText: "Password",
                    labelSymbol: .key,
                    inputText: $password,
                    placeholderText: "Account password",
                    isSecure: true
                )
                .disableAutocorrection(true)
                .autocapitalization(.none)
            }
        )

        Section(content: {
            ServerStatus(controller: self.controller.serverStatusController)
                .onAppear { Task { await self.controller.setServerStatus() }}
        })
    }

    func validateUrl(_ url: String) -> Bool {
        if let url = URL(string: url) {
            return UIApplication.shared.canOpenURL(url)
        }

        return false
    }
}

private struct ServerStatus: View {
    @ObservedObject
    private var controller: ServerStatusController

    init(controller: ServerStatusController) {
        self.controller = controller
    }

    var body: some View {
        InlineValueComponent(
            labelText: "Server status",
            labelSymbol: .linkIcloud,
            value: $controller.serverStatus
        )
        .foregroundColor(controller.statusColor)
    }
}

// MARK: - GeneralSection view

private struct GeneralSection: View {
    var body: some View {
        Section(
            header: Text("General"),
            content: {
                PreviewModeToggle()

                NavigationLink {
                    // TODO: advanced settings view
                } label: {
                    ListOptionComponent(
                        symbol: .wrenchAndScrewdriver,
                        text: "Advanced"
                    )
                }
                .disabled(true)

                PurgeCaches()
            }
        )
    }
}

private struct PreviewModeToggle: View {
    @Environment(\.api)
    var api

    @Default(.previewMode)
    var previewEnabled: Bool

    var body: some View {
        Toggle(isOn: $previewEnabled) {
            ListOptionComponent(
                symbol: .eyes,
                text: "Preview mode"
            )
        }
        .onChange(of: previewEnabled, perform: { newValue in
            if newValue {
                api.usePreviewMode()
                return
            }

            do {
                api.useDefaultMode()
                try api.performAuth()
            } catch {
                print("Failed to switch to default mode: \(error)")
            }
        })
    }
}

private struct PurgeCaches: View {
    @Stored(in: .albums)
    private var albums: [Album]

    @Stored(in: .songs)
    private var songs: [Song]

    @State
    private var showPurgeCacheConfirm = false

    var body: some View {
        Button {
            showPurgeCacheConfirm = true
        } label: {
            ListOptionComponent(
                symbol: .trash,
                text: "Purge all caches"
            )
        }
        .buttonStyle(.plain)
        .foregroundColor(.red)
        .alert(isPresented: $showPurgeCacheConfirm, content: {
            Alert(
                title: Text("Purge all caches"),
                message: Text("This will remove all metadata, images and downloads"),
                primaryButton: .destructive(
                    Text("Purge"),
                    action: { self.purgeCaches() }
                ),
                secondaryButton: .default(
                    Text("Cancel"),
                    action: { showPurgeCacheConfirm = false }
                )
            )
        })
    }

    private func purgeCaches() {
        Kingfisher.ImageCache.default.clearMemoryCache()
        Kingfisher.ImageCache.default.clearDiskCache()

        Task {
            do {
                try await self.$albums.removeAll()
                try await self.$songs.removeAll()
            } catch {
                print("Purging caches failed: \(error)")
            }
        }
    }
}
