import SwiftUI

struct TabBarView: View {
    var body: some View {
        TabView {
            // TODO: implement Catalog screen (epic: catalog, part 1)
            Text(verbatim: "Catalog – coming soon")
                .tabItem {
                    Label(
                        NSLocalizedString("Tab.catalog", comment: ""),
                        systemImage: "square.stack.3d.up.fill"
                    )
                }
        }
    }
}
