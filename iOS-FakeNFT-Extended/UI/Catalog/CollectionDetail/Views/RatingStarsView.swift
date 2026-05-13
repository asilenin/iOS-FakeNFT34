import SwiftUI

/// Отрисовка рейтинга в виде 5 звёзд.
///
/// Отображает рейтинг от 0 до 5 звёзд на плашке размером 68×12pt.
/// Первые `rating` звёзд активные (жёлтые), остальные неактивные (серые).
/// Используется в ячейках каталога для визуализации оценки NFT.
struct RatingStarsView: View {

    /// Рейтинг от 0 до 5.
    let rating: Int

    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<5, id: \.self) { index in
                if index < rating {
                    Image(.starActive)
                        .resizable()
                        .scaledToFit()
                } else {
                    Image(.starInactive)
                        .resizable()
                        .scaledToFit()
                }
            }
        }
        .frame(width: 68, height: 12)
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 12) {
        RatingStarsView(rating: 0)
        RatingStarsView(rating: 1)
        RatingStarsView(rating: 2)
        RatingStarsView(rating: 3)
        RatingStarsView(rating: 4)
        RatingStarsView(rating: 5)
    }
    .padding()
}
