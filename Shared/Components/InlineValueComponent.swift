import SwiftUI

struct InlineValueComponent: View {
    var title: String?

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
        if let title {
            Text(title)
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
                title: "Example",
                value: $v1
            )

            InlineValueComponent(
                title: "Example take 2",
                value: $v2
            )
        }
        .padding(.horizontal)
    }
}
// swiftlint:enable all
#endif
