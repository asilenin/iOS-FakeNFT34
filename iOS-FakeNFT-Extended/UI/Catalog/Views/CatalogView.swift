import SwiftUI

struct CatalogView: View {
    @Environment(Router.self) private var router
    
    var body: some View {
        ZStack {
            Color.ypWhite.ignoresSafeArea()

            // TODO(catalog epic, part 1): replace with the real
            // collections list bound to CatalogViewModel.
            Text("Catalog – coming soon")
                .font(.bold22)
                .foregroundStyle(.ypBlack)
        }
        .navigationTitle(Text("Tab.catalog"))
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        CatalogView()
    }
}
