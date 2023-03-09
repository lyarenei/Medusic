import SwiftUI

struct SignInView: View {
    
    @State private var username = ""
    @State private var password = ""
    
    @Binding var isLoggedIn: Bool
    @Binding var isLoginPresented: Bool
    
    var body: some View {
        NavigationView {
            VStack{
                Spacer()
                Text("Log in to Jellyfin server")
                    .font(.headline)
                    .bold()
                    .padding()
                
                TextField(
                    "Username",
                    text: $username)
                    .disableAutocorrection(true)
                    .textFieldStyle(.roundedBorder)
                    .autocapitalization(.none)
                
                SecureField(
                    "Password",
                    text: $password
                )
                    .disableAutocorrection(true)
                    .textFieldStyle(.roundedBorder)
                    .autocapitalization(.none)
                
                Button("Log in") {
                    print("login hadling")
                    isLoggedIn = true
                    isLoginPresented = false
                }
                //.disabled(username.isEmpty || password.isEmpty)
                .frame(minWidth: 0, maxWidth: 100)
                .padding()
                .accentColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                .foregroundColor(.primary)
                .cornerRadius(0.5)
                
                Spacer()
            }
            .padding()
        }
    }
}

#if DEBUG
struct SignInView_Previews: PreviewProvider {
    
    @State static var isLoggedIn = true
    @State static var isLoginPresented = true
    
    static var previews: some View {
        SignInView(
            isLoggedIn: $isLoggedIn,
            isLoginPresented: $isLoginPresented
        )
    }
}
#endif
