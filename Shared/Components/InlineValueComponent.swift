import SwiftUI
import SFSafeSymbols

struct InlineValueComponent: View {
    var labelText: String?
    var labelSymbol: SFSymbol?

    @Binding
    var value: String

    var body: some View {
        HStack(spacing: 0) {
            ListOptionComponent(
                symbol: labelSymbol,
                text: labelText
            )

            Spacer(minLength: 20)

            Text(value)
                .lineLimit(1)
                .multilineTextAlignment(.trailing)
        }
    }
}

#if DEBUG
struct InlineValueComponent_Previews: PreviewProvider {
    @State
    static var v1 = " Foo"

    @State
    static var v2 = " Bar"

    static var previews: some View {
        VStack{
            InlineValueComponent(
                labelText: "Example",
                labelSymbol: .return,
                value: $v1
            )
            .padding(.leading)
            .padding(.trailing)

            InlineValueComponent(
                labelText: "Example take 2",
                labelSymbol: .info,
                value: $v2
            )
            .padding(.leading)
            .padding(.trailing)
        }
    }
}
#endif
