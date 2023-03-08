import SwiftUI

struct AccountSettingsView: View {
    
    @AppStorage("isLoggedIn")
    private var isLoggedIn = false
    
    @State
    var isLoginPresented = false
    
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
        .onAppear(perform: {
            if (!isLoggedIn) {
                isLoginPresented = true
            }
        })
    }
}

struct AccountSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        AccountSettingsView()
    }
}
