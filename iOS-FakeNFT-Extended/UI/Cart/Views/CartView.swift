import SwiftUI

struct CartView: View {
    var body: some View {
        ZStack {
            Color.ypWhite.ignoresSafeArea()

            // TODO(cart epic): replace with the real order screen
            // bound to CartViewModel.
            Text("Cart – coming soon")
                .font(.bold22)
                .foregroundStyle(.ypBlack)
        }
        .navigationTitle(Text("Tab.cart"))
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        CartView()
    }
}
