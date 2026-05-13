import SwiftUI
import Kingfisher

/// Шапка экрана коллекции NFT.
///
/// Содержит обложку коллекции на всю ширину экрана (aspect ratio 375:310,
/// скругление только нижних углов 12pt), название, строку с кликабельным
/// именем автора и многострочное описание.
/// Используется как первый элемент в `CollectionDetailView` (см. 2.8).
struct CollectionHeader: View {

    let collection: NftCollection
    let onAuthorTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            cover
            textBlock
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 16)
        }
    }

    // MARK: - Subviews

    private var cover: some View {
        KFImage(collection.cover)
            .resizable()
            .scaledToFill()
            .aspectRatio(375.0 / 310.0, contentMode: .fill)
            .frame(maxWidth: .infinity)
            .clipped()
            .clipShape(
                .rect(
                    topLeadingRadius: 0,
                    bottomLeadingRadius: 12,
                    bottomTrailingRadius: 12,
                    topTrailingRadius: 0
                )
            )
    }

    private var textBlock: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(collection.name)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(Color.ypBlack)
                .padding(.bottom, 8)

            authorRow

            Text(collection.description)
                .font(.system(size: 13, weight: .regular))
                .foregroundStyle(Color.ypBlack)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var authorRow: some View {
        HStack(alignment: .firstTextBaseline, spacing: 4) {
            Text("Автор коллекции:")
                .font(.system(size: 13, weight: .regular))
                .foregroundStyle(Color.ypBlack)

            Button(action: onAuthorTap) {
                Text(collection.author)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(Color.ypBlueUniversal)
            }
            .buttonStyle(.plain)
        }
        .frame(height: 28, alignment: .center)
    }
}

#Preview {
    ScrollView {
        CollectionHeader(
            collection: MockCatalogService.mockCollections[0],
            onAuthorTap: {}
        )
    }
    .background(Color.ypWhite)
}
