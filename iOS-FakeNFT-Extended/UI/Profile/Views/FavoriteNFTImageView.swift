//
//  FavoriteNFTImageView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Анастасия Федотова on 21.05.2026.
//

import Kingfisher
import SwiftUI

struct FavoriteNFTImageView: View {

    // MARK: - State

    @State private var didFail = false

    // MARK: - Properties

    let url: URL?

    // MARK: - Body

    var body: some View {
        ZStack {
            if let url, !didFail {
                KFImage(url)
                    .placeholder {
                        SkeletonView(cornerRadius: Constants.cornerRadius)
                    }
                    .retry(maxCount: 2, interval: .seconds(1))
                    .fade(duration: 0.2)
                    .onFailure { _ in
                        didFail = true
                    }
                    .resizable()
                    .scaledToFill()
            } else {
                SkeletonView(cornerRadius: Constants.cornerRadius)
            }
        }
        .frame(width: Constants.imageSize, height: Constants.imageSize)
        .clipped()
    }

    // MARK: - Constants

    private enum Constants {
        static let imageSize: CGFloat = 80
        static let cornerRadius: CGFloat = 12
    }
}

#Preview {
    FavoriteNFTImageView(url: nil)
        .frame(width: 80, height: 80)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding()
}
