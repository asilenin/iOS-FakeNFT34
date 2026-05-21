//
//  RatingStarsView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Анастасия Федотова on 21.05.2026.
//

import SwiftUI

struct RatingStarsView: View {

    // MARK: - Constants

    private enum Constants {
        static let maxRating = 5
        static let starSize: CGFloat = 12
        static let defaultSpacing: CGFloat = 2
        static let defaultTotalWidth: CGFloat = 68
    }

    // MARK: - Properties

    let rating: Int
    let spacing: CGFloat
    let totalWidth: CGFloat

    private var normalizedRating: Int {
        min(max(rating, 0), Constants.maxRating)
    }

    // MARK: - Init

    init(
        rating: Int,
        spacing: CGFloat = Constants.defaultSpacing,
        totalWidth: CGFloat = Constants.defaultTotalWidth
    ) {
        self.rating = rating
        self.spacing = spacing
        self.totalWidth = totalWidth
    }

    // MARK: - Body

    var body: some View {
        HStack(spacing: spacing) {
            ForEach(0..<Constants.maxRating, id: \.self) { index in
                Image(index < normalizedRating ? .starActive : .starInactive)
                    .renderingMode(.original)
                    .resizable()
                    .scaledToFit()
                    .frame(width: Constants.starSize, height: Constants.starSize)
            }
        }
        .frame(width: totalWidth, height: Constants.starSize, alignment: .leading)
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 8) {
        ForEach(0...5, id: \.self) { rating in
            RatingStarsView(rating: rating)
            RatingStarsView(rating: rating, spacing: 0, totalWidth: 60)
        }
    }
    .padding()
}
