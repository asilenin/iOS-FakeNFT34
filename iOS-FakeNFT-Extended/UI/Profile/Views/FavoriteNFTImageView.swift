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
                        ZStack {
                            Color.ypBackgroundUniversal

                            LoadingSpinner(size: .medium, tint: .ypWhiteUniversal)
                        }
                    }
                    .retry(maxCount: 2, interval: .seconds(1))
                    .fade(duration: 0.2)
                    .onFailure { _ in
                        didFail = true
                    }
                    .resizable()
                    .scaledToFill()
            } else {
                FavoriteNFTImagePlaceholder()
            }
        }
        .frame(width: Constants.imageSize, height: Constants.imageSize)
        .clipped()
    }

    // MARK: - Constants

    private enum Constants {
        static let imageSize: CGFloat = 80
    }
}

// MARK: - FavoriteNFTImagePlaceholder

private struct FavoriteNFTImagePlaceholder: View {

    // MARK: - Constants

    private enum Constants {
        static let cellSize: CGFloat = 20
        static let gridSize = 4
        static let imageSize: CGFloat = 80
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            ForEach(0..<Constants.gridSize, id: \.self) { row in
                HStack(spacing: 0) {
                    ForEach(0..<Constants.gridSize, id: \.self) { column in
                        Rectangle()
                            .fill((row + column).isMultiple(of: 2) ? Color.ypWhite : Color.ypBlack)
                            .frame(width: Constants.cellSize, height: Constants.cellSize)
                    }
                }
            }
        }
        .frame(width: Constants.imageSize, height: Constants.imageSize)
    }
}

#Preview {
    FavoriteNFTImageView(url: nil)
        .frame(width: 80, height: 80)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding()
}
