import SwiftUI

struct ProfileView: View {
    var body: some View {
        ZStack {
            Color.ypWhite.ignoresSafeArea()

            // TODO(profile epic): replace with the real profile screen
            // bound to ProfileViewModel.
            Text("Profile – coming soon")
                .font(.bold22)
                .foregroundStyle(.ypBlack)
        }
        .navigationTitle(Text("Tab.profile"))
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        ProfileView()
    }
}
