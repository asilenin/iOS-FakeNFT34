//
//  RatingStarsView.swift
//  iOS-FakeNFT-Extended
//
//  Created by МAK on 17.05.2026.
//

import SwiftUI

private enum Constants {
    static let maxRating = 5
    static let starSize = CGSize(width: 12, height: 12)
    static let spacing: CGFloat = 2
    static let totalWidth: CGFloat = 68
}

struct RatingStarsView: View {

    let rating: Int

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

    private var normalizedRating: Int {
        min(max(rating, 0), Constants.maxRating)
    }
}

#Preview {
    VStack(spacing: 12) {
        RatingStarsView(rating: 0)
        RatingStarsView(rating: 3)
        RatingStarsView(rating: 5)
    }
    .padding()
}
