import Defaults
import SwiftUI

struct ServerUrlComponent: View {
    @Default(.serverUrl)
    var serverUrl: String

    var body: some View {
        InlineInputComponent(
            title: "URL",
            inputText: $serverUrl,
            placeholderText: "Server URL"
        )
        .keyboardType(.URL)
        .disableAutocorrection(true)
        .autocapitalization(.none)
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
