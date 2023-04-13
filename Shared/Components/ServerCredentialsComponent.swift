import Defaults
import SimpleKeychain
import SwiftUI

struct ServerCredentialsComponent: View {
    @Default(.username)
    var username: String

    @State
    var password = ""

    let keychain = SimpleKeychain()

    var body: some View {
        usernameInput()
        passwordInput()
    }

    @ViewBuilder
    func usernameInput() -> some View {
        InlineInputComponent(
            labelText: "Username",
            labelSymbol: .personCropCircle,
            inputText: $username,
            placeholderText: "Account username"
        )
        .disableAutocorrection(true)
        .autocapitalization(.none)
    }

    @ViewBuilder
    func passwordInput() -> some View {
        InlineInputComponent(
            labelText: "Password",
            labelSymbol: .key,
            inputText: $password,
            placeholderText: "Account password",
            isSecure: true
        )
        .disableAutocorrection(true)
        .autocapitalization(.none)
        .onChange(of: password, debounceTime: 0.5) { newPassword in
            savePassword(newPassword)
        }
    }

    func savePassword(_ newPassword: String) {
        do {
            try keychain.set(newPassword, forKey: "password")
        } catch {
            print("Failed to save password: \(error.localizedDescription)")
        }
    }
}

#if DEBUG
struct ServerCredentialsComponent_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            ServerCredentialsComponent()
        }
        .padding(.horizontal)
    }
}
#endif
