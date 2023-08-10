import Defaults
import SimpleKeychain
import SwiftUI

struct ServerCredentialsComponent: View {
    @Default(.username)
    var username: String

    @State
    var password: String = .empty

    let keychain = SimpleKeychain()

    var body: some View {
        usernameInput()
        passwordInput()
    }

    @ViewBuilder
    func usernameInput() -> some View {
        InlineInputComponent(
            title: "Username",
            inputText: $username,
            placeholderText: "Account username"
        )
        .disableAutocorrection(true)
        .autocapitalization(.none)
    }

    @ViewBuilder
    func passwordInput() -> some View {
        InlineInputComponent(
            title: "Password",
            inputText: $password,
            placeholderText: "Account password",
            isSecure: true
        )
        .disableAutocorrection(true)
        .autocapitalization(.none)
        .onChange(of: password, debounceTime: 1) { newPassword in
            savePassword(newPassword)
            NotificationCenter.default.post(name: .PasswordChanged, object: nil)
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
