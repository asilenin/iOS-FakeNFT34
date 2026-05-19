import SwiftUI

/// Отрисовка рейтинга в виде 5 звёзд.
///
/// Отображает рейтинг от 0 до 5 звёзд на плашке размером 68×12pt.
/// Первые `rating` звёзд активные (жёлтые), остальные неактивные (серые).
/// Используется в ячейках каталога для визуализации оценки NFT.
struct RatingStarsView: View {

    // MARK: - Constants

    private enum Constants {
        static let maxRating = 5
        static let starSize = CGSize(width: 12, height: 12)
        static let spacing: CGFloat = 2
        static let totalWidth: CGFloat = 68
    }

    // MARK: - Input

    /// Рейтинг от 0 до 5.
    let rating: Int

    // MARK: - Body

    var body: some View {
        HStack(spacing: Constants.spacing) {
            ForEach(0..<Constants.maxRating, id: \.self) { index in
                Image(index < normalizedRating ? .starActive : .starInactive)
                    .resizable()
                    .scaledToFit()
                    .frame(
                        width: Constants.starSize.width,
                        height: Constants.starSize.height
                    )
            }
        }
        .frame(width: Constants.totalWidth, height: Constants.starSize.height)
    }

    // MARK: - Private

    private var normalizedRating: Int {
        min(max(rating, 0), Constants.maxRating)
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 12) {
        ForEach(0...5, id: \.self) { rating in
            RatingStarsView(rating: rating)
        }
    }
    .padding()
}
