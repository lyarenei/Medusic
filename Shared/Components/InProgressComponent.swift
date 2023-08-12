import SwiftUI

struct InProgressComponent: View {
    let text: String

    init(_ text: String = "Refreshing ...") {
        self.text = text
    }

    var body: some View {
        VStack(alignment: .center, spacing: 5) {
            ProgressView()
            Text(text)
                .foregroundColor(.gray)
        }
    }
}

#if DEBUG
struct InProgressComponent_Previews: PreviewProvider {
    static var previews: some View {
        InProgressComponent()
    }
}
#endif
