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
        static let totalWidth: CGFloat = 60
    }

    // MARK: - Properties

    let rating: Int

    private var normalizedRating: Int {
        min(max(rating, 0), Constants.maxRating)
    }

    // MARK: - Body

    var body: some View {
        HStack(spacing: 0) {
            ForEach(1...Constants.maxRating, id: \.self) { index in
                Image(index <= normalizedRating ? .starActive : .starInactive)
                    .renderingMode(.original)
                    .resizable()
                    .scaledToFit()
                    .frame(width: Constants.starSize, height: Constants.starSize)
            }
        }
        .frame(width: Constants.totalWidth, height: Constants.starSize, alignment: .leading)
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 8) {
        ForEach(0...5, id: \.self) { rating in
            RatingStarsView(rating: rating)
        }
    }
    .padding()
}
