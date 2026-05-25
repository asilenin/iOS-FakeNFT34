import SwiftUI

extension View {
    func errorAlert(
        error: Binding<Error?>,
        retry: @escaping () -> Void
    ) -> some View {
        modifier(ErrorAlertModifier(error: error, retry: retry))
    }
}

private struct ErrorAlertModifier: ViewModifier {

    @Binding var error: Error?
    let retry: () -> Void

    func body(content: Content) -> some View {
        content.alert(
            Text("Error.title"),
            isPresented: isPresented,
            presenting: error
        ) { _ in
            Button(role: .cancel) {
                error = nil
            } label: {
                Text("Error.cancel")
            }
            Button {
                error = nil
                retry()
            } label: {
                Text("Error.retry")
            }
        } message: { error in
            Text(error.localizedDescription)
        }
    }

    private var isPresented: Binding<Bool> {
        Binding(
            get: { error != nil },
            set: { newValue in
                if !newValue { error = nil }
            }
        )
    }
}
