import SwiftUI
import SFSafeSymbols

struct InlineInputComponent: View {
    var labelText: String?
    var labelSymbol: SFSymbol?

    @Binding
    var inputText: String

    var placeholderText = ""
    var isSecure = false

    var body: some View {
        HStack(spacing: 0) {
            ListOptionComponent(
                symbol: labelSymbol,
                text: labelText
            )

            Spacer(minLength: 20)

            inputField()
                .lineLimit(1)
                .multilineTextAlignment(.trailing)
        }
    }

    @ViewBuilder
    func inputField() -> some View {
        if isSecure {
            SecureField(placeholderText, text: $inputText)
        } else {
            TextField(placeholderText, text: $inputText)
        }
    }
}

#if DEBUG
struct InlineInputComponent_Previews: PreviewProvider {
    @State
    static var input1 = "some value"

    @State
    static var input2 = "some longer value"

    static var previews: some View {
        VStack{
            InlineInputComponent(
                labelText: "Example",
                labelSymbol: .return,
                inputText: $input1
            )
            .padding(.leading)
            .padding(.trailing)

            InlineInputComponent(
                labelText: "Example take 2",
                labelSymbol: .info,
                inputText: $input2
            )
            .padding(.leading)
            .padding(.trailing)
        }
    }
}
#endif
