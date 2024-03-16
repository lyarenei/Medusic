import ButtonKit
import SwiftUI

struct JellyfinSettings: View {
    @State
    private var viewModel: ViewModel

    init(client: ApiClient) {
        self.viewModel = ViewModel(client: client)
    }

    var body: some View {
        Form {
            serverUrl
            serverCredentials

            serverInfo
            saveButton
        }
        .navigationTitle("Jellyfin settings")
        .navigationBarTitleDisplayMode(.inline)
        .scrollDisabled(true)
    }

    @ViewBuilder
    private var serverUrl: some View {
        Section("Server") {
            TextField("URL", text: $viewModel.serverUrl)
                .keyboardType(.URL)
                .disableAutocorrection(true)
                .autocapitalization(.none)
        }
    }

    @ViewBuilder
    private var serverCredentials: some View {
        Section("Credentials") {
            TextField("username", text: $viewModel.username)
                .disableAutocorrection(true)
                .autocapitalization(.none)

            SecureField("password", text: $viewModel.password)
                .disableAutocorrection(true)
                .autocapitalization(.none)
        }
    }

    @ViewBuilder
    private var serverInfo: some View {
        Section("Server info") {
            VStack(alignment: .leading) {
                HStack {
                    Text("Server Status:")
                    Spacer()
                    Text(viewModel.serverStatus.rawValue)
                        .foregroundStyle(Color(viewModel.serverStatusColor))
                }

                HStack {
                    Text("User Status:")
                    Spacer()
                    Text(viewModel.userStatus.rawValue)
                        .foregroundStyle(Color(viewModel.userStatusColor))
                }

                infoEntry("Name:", value: viewModel.serverName)
                infoEntry("Version:", value: viewModel.serverVersion)
            }
        }
        .listRowBackground(Color.clear)
        .foregroundStyle(.secondary)
        .task { await viewModel.refreshServerStatus() }
    }

    @ViewBuilder
    private func infoEntry(_ title: String, value: String) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
        }
    }

    @ViewBuilder
    private var saveButton: some View {
        AsyncButton {
            await viewModel.onSaveCredentials()
        } label: {
            HStack {
                Spacer()
                Text("Save")
                Spacer()
            }
        }
    }
}

#Preview {
    NavigationStack {
        JellyfinSettings(client: ApiClient.shared)
    }
}
