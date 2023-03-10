import SwiftUI

struct ServerUrlView: View {

    @State
    private var serverUrl = ""

    @Binding
    var isLoggedIn: Bool

    @Binding
    var isLoginPresented: Bool

    var body: some View {
        NavigationView {
            VStack(spacing: 15) {
                Spacer()

                Text("Connect to Jellyfin server")
                    .font(.headline)
                    .bold()

                TextField(
                    "Jellyfin server URL",
                    text: $serverUrl
                )
                    .keyboardType(.URL)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                    .textFieldStyle(.roundedBorder)

                NavigationLink("Next") {
                    SignInView(
                        isLoggedIn: $isLoggedIn,
                        isLoginPresented: $isLoginPresented
                    )
                }
                    .disabled(serverUrl.isEmpty)
                    .frame(minWidth: 0, maxWidth: 100)
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.accentColor)
                    .cornerRadius(10)
                    .onDisappear {
                        UserDefaults.standard.set(
                            serverUrl,
                            forKey: "server_url"
                        )
                    }

                Spacer()
            }
            .padding()
        }
    }
}

#if DEBUG
struct ServerUrlView_Previews: PreviewProvider {

    @State
    static var isLoggedIn = false

    @State
    static var isLoginPresented = false

    static var previews: some View {
        ServerUrlView(
            isLoggedIn: $isLoggedIn,
            isLoginPresented: $isLoginPresented
        )
    }
}
#endif
