import Boutique
import DebouncedOnChange
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
    }
}
#endif

// MARK: - JellyfinSection view

private struct JellyfinSection: View {
    @StateObject
    private var controller = JellyfinSettingsController()

    var body: some View {
        Section(
            header: Text("Jellyfin"),
            content: {
                InlineInputComponent(
                    labelText: "URL",
                    labelSymbol: .link,
                    inputText: $controller.serverUrlEdit,
                    placeholderText: "Server URL"
                )
                .keyboardType(.URL)
                .disableAutocorrection(true)
                .autocapitalization(.none)
                .onChange(of: controller.serverUrlEdit, debounceTime: 1.5) { newValue in
                    if self.controller.validateUrl(newValue) {
                        Task { await controller.saveUrl(newValue) }
                    } else {
                        // TODO: show in UI
                        print("Server URL is not valid")
                    }
                }

                // TODO: add credentials validation
                InlineInputComponent(
                    labelText: "Username",
                    labelSymbol: .personCropCircle,
                    inputText: $controller.usernameEdit,
                    placeholderText: "Account username"
                )
                .disableAutocorrection(true)
                .autocapitalization(.none)
                .onChange(of: controller.usernameEdit, debounceTime: 0.5) { newValue in
                    Task { await controller.saveUsername(newValue) }
                }

                InlineInputComponent(
                    labelText: "Password",
                    labelSymbol: .key,
                    inputText: $controller.passwordEdit,
                    placeholderText: "Account password",
                    isSecure: true
                )
                .disableAutocorrection(true)
                .autocapitalization(.none)
                .onChange(of: controller.passwordEdit, debounceTime: 0.5) { newValue in
                    Task { try? await controller.savePassword(newValue) }
                }
            }
        )
        .onAppear {
            self.controller.restoreUrl()
            self.controller.restoreUsername()
        }

        Section(content: {
            ServerStatus(controller: self.controller.serverStatusController)
                .onAppear { Task { await self.controller.setServerStatus() }}
        })
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

            Task {
                do {
                    api.useDefaultMode()
                    let _ = try await api.performAuth()
                } catch {
                    print("Failed to switch to default mode: \(error)")
                }
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
