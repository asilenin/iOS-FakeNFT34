import SwiftUI

struct CollectionDetailView: View {

    let collection: NftCollection

    var body: some View {
        ZStack {
            Color.ypWhite.ignoresSafeArea()

            VStack(spacing: 16) {
                Text(collection.name)
                    .font(.bold22)
                    .foregroundStyle(Color.ypBlack)

                Text("CollectionDetail.placeholder")
                    .font(.regular17)
                    .foregroundStyle(Color.ypGrayUniversal)
            }
        }
    }
}

#Preview {
    NavigationStack {
        CollectionDetailView(collection: MockCatalogService.mockCollections[0])
    }
}
