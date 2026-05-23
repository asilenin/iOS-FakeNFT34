//
//  ProfileNFTImageView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Анастасия Федотова on 23.05.2026.
//

import Kingfisher
import SwiftUI

struct ProfileNFTImageView: View {

    // MARK: - State

    @State private var didFail = false

    // MARK: - Properties

    let url: URL?
    let size: CGFloat
    let cornerRadius: CGFloat

    // MARK: - Body

    var body: some View {
        ZStack {
            if let url, !didFail {
                KFImage(url)
                    .placeholder {
                        SkeletonView(cornerRadius: cornerRadius)
                    }
                    .retry(maxCount: 2, interval: .seconds(1))
                    .fade(duration: 0.2)
                    .onFailure { _ in
                        didFail = true
                    }
                    .resizable()
                    .scaledToFill()
            } else {
                SkeletonView(cornerRadius: cornerRadius)
            }
        }
        .frame(width: size, height: size)
        .clipped()
    }
}
