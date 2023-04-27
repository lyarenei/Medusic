import SwiftUI
import SFSafeSymbols

struct InlineValueComponent: View {
    var labelText: String?
    var labelSymbol: SFSymbol?

    @Binding
    var value: String

    var body: some View {
        HStack(spacing: 0) {
            label()
                .lineLimit(1)

            Spacer(minLength: 20)
            Text(value)
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
}

#if DEBUG
// swiftlint:disable all
struct InlineValueComponent_Previews: PreviewProvider {
    @State
    static var v1 = " Foo"

    @State
    static var v2 = " Bar"

    static var previews: some View {
        VStack {
            InlineValueComponent(
                labelText: "Example",
                labelSymbol: .return,
                value: $v1
            )

            InlineValueComponent(
                labelText: "Example take 2",
                labelSymbol: .info,
                value: $v2
            )
        }
        .padding(.horizontal)
    }
}
// swiftlint:enable all
#endif
