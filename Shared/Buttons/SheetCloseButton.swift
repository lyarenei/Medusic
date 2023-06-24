import SwiftUI

struct SheetCloseButton: View {
    @Binding
    var isPresented: Bool

    var body: some View {
        Button {
            isPresented = false
        } label: {
            Image(systemSymbol: .chevronCompactDown)
                .font(.system(size: 42))
                .foregroundColor(.lightGray)
                .padding(.top, 10)
                .padding(.bottom, 1)
        }
    }
}

#if DEBUG
struct SheetCloseButton_Previews: PreviewProvider {
    @State
    static var isPresented = false
    static var previews: some View {
        VStack {
            SheetCloseButton(isPresented: $isPresented)
            Text("Text")
        }
        .padding()
        .border(.black)
    }
}
#endif
