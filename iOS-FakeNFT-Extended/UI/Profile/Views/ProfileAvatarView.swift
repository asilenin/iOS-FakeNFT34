//
//  ProfileAvatarView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Анастасия Федотова on 23.05.2026.
//

import Kingfisher
import SwiftUI

struct ProfileAvatarView: View {

    // MARK: - Properties

    let avatar: String?

    // MARK: - Body

    var body: some View {
        let sources = profileAvatarSources(from: avatar ?? "")

        if sources.isEmpty {
            placeholder
        } else {
            KFImage(source: sources.first)
                .placeholder {
                    ZStack {
                        Color.ypBackgroundUniversal

                        LoadingSpinner(size: .medium, tint: .ypWhiteUniversal)
                    }
                }
                .alternativeSources(Array(sources.dropFirst()))
                .retry(maxCount: 2, interval: .seconds(1))
                .fade(duration: 0.2)
                .onFailure { error in
                    print("Profile avatar load failed: \(error)")
                }
                .resizable()
                .scaledToFill()
                .frame(width: Constants.size, height: Constants.size)
                .clipShape(Circle())
        }
    }

    // MARK: - Content

    private var placeholder: some View {
        ZStack {
            Color.ypWhite

            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .scaledToFit()
                .foregroundStyle(.ypGrayLight)
                .frame(width: Constants.size, height: Constants.size)
        }
        .frame(width: Constants.size, height: Constants.size)
        .clipShape(Circle())
    }

    // MARK: - Constants

    private enum Constants {
        static let size: CGFloat = 70
    }
}

#Preview {
    ProfileAvatarView(avatar: nil)
        .padding()
}
