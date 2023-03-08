import SwiftUI

struct AccountSettingsView: View {
    
    @State var isLoggedIn = false
    @State var isLoginPresented = false
    
    var body: some View {
        Button {
            if (isLoggedIn) {
                isLoggedIn = false
            } else {
                isLoginPresented = true
            }
        } label: {
            if (isLoggedIn) {
                Text("Account")
            } else {
                Text("Log in")
            }
        }
        .navigationTitle("Account")
        .sheet(
            isPresented: $isLoginPresented,
            content: {
                ServerUrlView(
                    isLoggedIn: $isLoggedIn,
                    isLoginPresented: $isLoginPresented
                )
            }
        )
    }
}

struct AccountSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        AccountSettingsView()
    }
}
