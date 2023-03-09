import SwiftUI

struct ServerUrlView: View {
    
    @State private var serverUrl = ""
    @Binding var isLoggedIn: Bool
    @Binding var isLoginPresented: Bool
    
    var body: some View {
        NavigationView {
            VStack{
                Spacer()
                Text("Connect to Jellyfin server")
                    .font(.headline)
                    .bold()
                    .padding()
                
                TextField(
                    "Jellyfin server URL",
                    text: $serverUrl
                )
                    .disableAutocorrection(true)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.URL)
                    .autocapitalization(.none)
                
                NavigationLink("Next") {
                    SignInView(
                        isLoggedIn: $isLoggedIn,
                        isLoginPresented: $isLoginPresented
                    )
                }
                //.disabled(serverUrl.isEmpty)
                .frame(minWidth: 0, maxWidth: 100)
                .padding()
                
                Spacer()
            }
            .padding()
        }
    }
}

#if DEBUG
struct ServerUrlView_Previews: PreviewProvider {
    
    @State static var isLoggedIn = false
    @State static var isLoginPresented = false
    
    static var previews: some View {
        ServerUrlView(
            isLoggedIn: $isLoggedIn,
            isLoginPresented: $isLoginPresented
        )
    }
}
#endif
