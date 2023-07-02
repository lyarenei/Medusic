import SwiftUI

struct InlineInputComponent: View {
    var title: String?

    @Binding
    var inputText: String

    var placeholderText: String = .empty
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
        if let title {
            Text(title)
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
    var title: String?

    @Binding
    var inputNumber: UInt64
    var placeholderText: String = .empty
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
        if let title {
            Text(title)
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
                title: "Example",
                inputText: $input1
            )

            InlineInputComponent(
                title: "Example take 2",
                inputText: $input2
            )

            InlineNumberInputComponent(
                title: "Number input and longer text",
                inputNumber: $inputNumber,
                formatter: format
            )
        }
        .padding(.horizontal)
    }
}
#endif
