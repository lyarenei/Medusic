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
            label()
                .lineLimit(1)

            Spacer(minLength: 20)
            inputField()
                .lineLimit(1)
                .multilineTextAlignment(.trailing)
        }
    }

    @ViewBuilder
    private func label() -> some View {
        if let labelText {
            Text(labelText)
        }
    }

    @ViewBuilder
    private func inputField() -> some View {
        if isSecure {
            SecureField(placeholderText, text: $inputText)
        } else {
            TextField(placeholderText, text: $inputText)
        }
    }
}

struct InlineNumberInputComponent: View {
    var labelText: String?
    var labelSymbol: SFSymbol?

    @Binding
    var inputNumber: UInt64
    var placeholderText = ""
    var formatter: Formatter

    var body: some View {
        HStack(spacing: 0) {
            label()
                .lineLimit(1)

            Spacer(minLength: 20)
            TextField(placeholderText, value: $inputNumber, formatter: formatter)
                .lineLimit(1)
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: 120)
        }
        .keyboardType(.numberPad)
    }

    @ViewBuilder
    private func label() -> some View {
        if let labelText {
            Text(labelText)
        }
    }
}

#if DEBUG
struct InlineInputComponent_Previews: PreviewProvider {
    @State
    static var input1 = "some value"

    @State
    static var input2 = "some longer value"

    @State
    static var inputNumber: UInt64 = 1234
    static var format = {
        var fmt = NumberFormatter()
        fmt.allowsFloats = false
        fmt.minimum = 100
        fmt.numberStyle = .none
        return fmt
    }()

    static var previews: some View {
        VStack {
            InlineInputComponent(
                labelText: "Example",
                labelSymbol: .return,
                inputText: $input1
            )

            InlineInputComponent(
                labelText: "Example take 2",
                labelSymbol: .info,
                inputText: $input2
            )

            InlineNumberInputComponent(
                labelText: "Number input and longer text",
                labelSymbol: ._00Circle,
                inputNumber: $inputNumber,
                formatter: format
            )
        }
        .padding(.horizontal)
    }
}
#endif
