import Defaults
import SwiftUI

struct ServerUrlComponent: View {
    @Default(.serverUrl)
    var serverUrl: String

    @State
    var urlStatus: ServerUrlStatus = .unknown

    var body: some View {
        InlineInputComponent(
            labelText: "URL",
            labelSymbol: .link,
            inputText: $serverUrl,
            placeholderText: "Server URL"
        )
        .keyboardType(.URL)
        .disableAutocorrection(true)
        .autocapitalization(.none)
        .foregroundColor(mapStatusToColor())
        .onChange(of: serverUrl, debounceTime: 1) { newValue in
            urlStatus = validateUrl(newValue)
        }
    }

    func validateUrl(_ url: String) -> ServerUrlStatus {
        if url.isEmpty { return .unknown }
        if let url = URL(string: url) {
            if UIApplication.shared.canOpenURL(url) { return .valid }
            // TODO: Check if jellyfin server
        }

        return .invalid
    }

    func mapStatusToColor() -> Color {
        switch urlStatus {
        case .unknown:
            return .primary
        case .invalid:
            return .red
        case .valid:
            return .green
        }
    }

    enum ServerUrlStatus {
        /// Server URL has not been evaluated
        case unknown
        /// Server URL is invalid or does not point to Jellyfin server.
        case invalid
        /// Server URL is valid and points to Jellyfin server..
        case valid
    }
}

#if DEBUG
struct ServerUrlComponent_Previews: PreviewProvider {
    static var previews: some View {
        ServerUrlComponent()
            .padding(.horizontal)
    }
}
#endif
