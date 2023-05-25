import SwiftUI

struct ConfirmButton: View {
    @State
    var showConfirm = false

    var btnText: String

    var alertTitle: String
    var alertMessage: String

    var alertPrimaryBtnText: String
    var alertPrimaryAction: () -> Void

    init(
        btnText: String,
        alertTitle: String,
        alertMessage: String,
        alertPrimaryBtnText: String,
        alertPrimaryAction: @escaping () -> Void
    ) {
        self.btnText = btnText
        self.alertTitle = alertTitle
        self.alertMessage = alertMessage
        self.alertPrimaryBtnText = alertPrimaryBtnText
        self.alertPrimaryAction = alertPrimaryAction
    }

    var body: some View {
        if #available(iOS 15.0, *) {
            Button(btnText) {
                showConfirm = true
            }
            .alert(alertTitle, isPresented: $showConfirm) {
                Button(alertPrimaryBtnText, role: .destructive) { alertPrimaryAction() }
                Button("Cancel", role: .cancel) { showConfirm = false }
            } message: {
                Text(alertMessage)
            }
        } else {
            Button(btnText) {
                showConfirm = true
            }
            .alert(isPresented: $showConfirm) {
                Alert(
                    title: Text(alertTitle),
                    message: Text(alertMessage),
                    primaryButton: .destructive(Text(alertPrimaryBtnText)) { alertPrimaryAction() },
                    secondaryButton: .default(Text("Cancel")) { showConfirm = false }
                )
            }
        }
    }
}

#if DEBUG
struct AlertButton_Previews: PreviewProvider {
    static var previews: some View {
        ConfirmButton(
            btnText: "Button text",
            alertTitle: "Alert title",
            alertMessage: "Alert message",
            alertPrimaryBtnText: "Primary button"
        ) {}
    }
}
#endif
