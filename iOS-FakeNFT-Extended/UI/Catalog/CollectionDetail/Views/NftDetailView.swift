import SwiftUI

/// Экран деталей NFT — заглушка для P2.
///
/// В отдельном эпике "NFT детали" будет заменён на полноценный экран
/// с изображением, названием, рейтингом, описанием и кнопкой покупки.
/// В P2 показывает только id NFT — достаточно для проверки навигации
/// с экрана коллекции.
struct NftDetailView: View {

    let nftId: String

    var body: some View {
        ZStack {
            Color.ypWhite.ignoresSafeArea()

            VStack(spacing: 8) {
                Text("NFT detail")
                    .font(.bold22)
                    .foregroundStyle(Color.ypBlack)

                Text("id: \(nftId)")
                    .font(.regular13)
                    .foregroundStyle(Color.ypGrayUniversal)

                Text("Coming soon")
                    .font(.regular17)
                    .foregroundStyle(Color.ypGrayUniversal)
                    .padding(.top, 16)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        NftDetailView(nftId: "archie_id")
    }
}
