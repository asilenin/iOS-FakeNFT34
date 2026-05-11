import SwiftUI
import Kingfisher

struct CatalogRow: View {

    let collection: NftCollection

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            cover
            title
        }
        .padding(.bottom, 13)
    }

    private var cover: some View {
        Color.ypGrayLight
            .aspectRatio(343 / 140, contentMode: .fit)
            .overlay(alignment: .top) {
                KFImage(collection.cover)
                    .placeholder { SkeletonView() }
                    .resizable()
                    .scaledToFill()
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var title: some View {
        Text("\(collection.name) (\(collection.nfts.count))")
            .font(.bold17)
            .foregroundStyle(Color.ypBlack)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview("Single row") {
    CatalogRow(collection: MockCatalogService.mockCollections[0])
        .padding(.horizontal, 16)
}

#Preview("List") {
    ScrollView {
        VStack(spacing: 8) {
            ForEach(MockCatalogService.mockCollections) { collection in
                CatalogRow(collection: collection)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 20)
    }
}
