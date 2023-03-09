import SwiftUI

struct ContentView: View {
    @State var isModal: Bool = false
    @State var isLoggedIn = false
    @State var isLoginPresented = false
    
    var body: some View {
        Button("Login") {
            self.isModal = true
        }.sheet(isPresented: $isModal, content: {
            ServerUrlView(
                isLoggedIn: $isLoggedIn,
                isLoginPresented: $isLoginPresented)
        })
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
