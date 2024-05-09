import SwiftUI

struct PreviewComponent<Preview: View, Full: View>: View {
    @State
    private var displaySheet = false

    @ViewBuilder
    private let previewView: Preview

    @ViewBuilder
    private let fullView: Full

    init(
        @ViewBuilder preview: @escaping () -> Preview,
        @ViewBuilder fullView: @escaping () -> Full
    ) {
        self.previewView = preview()
        self.fullView = fullView()
    }

    var body: some View {
        GeometryReader { proxy in
            VStack(spacing: 0.5) {
                previewView

                HStack {
                    Spacer()
                    Text("Show more")
                        .foregroundStyle(Color.accentColor)
                }
            }
            .frame(width: proxy.size.width)
            .contentShape(Rectangle())
            .onTapGesture { displaySheet.toggle() }
            .sheet(isPresented: $displaySheet) { fullView }
        }
    }
}

#if DEBUG
// swiftlint:disable all

#Preview {
    PreviewComponent {
        Text("Lorem ipsum")
    } fullView: {
        Text("Longer lorem ipsum")
    }
    .padding(.horizontal)
}

// swiftlint:enable all
#endif
