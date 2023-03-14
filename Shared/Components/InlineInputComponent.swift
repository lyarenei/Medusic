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
            HStack(spacing: 5) {
                if let symbol = labelSymbol {
                    Image(systemSymbol: symbol)
                        .frame(minWidth: 25)
                }

                if let text = labelText {
                    Text(text)
                }
            }

            Spacer(minLength: 20)

            VStack(spacing: 0) {
                if isSecure {
                    SecureField(placeholderText, text: $inputText)
                } else {
                    TextField(placeholderText, text: $inputText)
                }
            }
            .lineLimit(1)
            .multilineTextAlignment(.trailing)
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
