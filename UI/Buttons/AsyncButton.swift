import SwiftUI

/// From https://swiftbysundell.com/articles/building-an-async-swiftui-button/
struct AsyncButton<Label: View>: View {
    @State
    private var isPerformingTask = false

    @ViewBuilder
    private var label: () -> Label

    private var action: () async -> Void

    init(
        _ action: @escaping () async -> Void,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.action = action
        self.label = label
    }

    var body: some View {
        Button {
            isPerformingTask = true

            Task {
                await action()
                isPerformingTask = false
            }
        } label: {
            ZStack {
                // We hide the label by setting its opacity
                // to zero, since we don't want the button's
                // size to change while its task is performed:
                label().opacity(isPerformingTask ? 0 : 1)

                if isPerformingTask {
                    ProgressView()
                }
            }
        }
        .disabled(isPerformingTask)
    }
}

#if DEBUG
struct AsyncButton_Previews: PreviewProvider {
    static var previews: some View {
        AsyncButton {
            try? await Task.sleep(for: .seconds(2))
        } label: {
            Label("Refresh", systemSymbol: .arrowClockwise)
        }
    }
}
#endif
