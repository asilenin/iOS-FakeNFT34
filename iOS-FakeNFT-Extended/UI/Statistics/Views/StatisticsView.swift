import SwiftUI

struct StatisticsView: View {
    var body: some View {
        ZStack {
            Color.ypWhite.ignoresSafeArea()

            // TODO(statistics epic): replace with the real users rating
            // screen bound to StatisticsViewModel.
            Text("Statistics – coming soon")
                .font(.bold22)
                .foregroundStyle(.ypBlack)
        }
        .navigationTitle(Text("Tab.statistics"))
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        StatisticsView()
    }
}
