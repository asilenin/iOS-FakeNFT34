//
//  ProfileView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Анастасия Федотова on 08.05.2026.
//

import Kingfisher
import SwiftUI

struct ProfileView: View {

    // MARK: - Environment

    @Environment(Router.self) private var router
    @Environment(ServicesAssembly.self) private var servicesAssembly

    // MARK: - State

    @State private var viewModel: ProfileViewModel?

    // MARK: - Body

    var body: some View {
        content
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        // TODO(profile epic S3): open edit profile screen.
                    } label: {
                        Image(.edit)
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .foregroundStyle(Color.ypBlack)
                            .frame(width: 24, height: 24)
                            .frame(width: 42, height: 42)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Редактировать профиль")
                }
            }
            .task {
                if viewModel == nil {
                    viewModel = ProfileViewModel(profileService: servicesAssembly.profileService)
                }

                await viewModel?.loadProfile()
            }
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        switch viewModel?.state {
        case .none, .some(.idle), .some(.loading):
            LoadingSpinner(size: .medium)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.ypWhite)
        case .some(.loaded(let profile)):
            profileContent(profile)
        case .some(.failed(let message)):
            errorContent(message)
        }
    }

    private func profileContent(_ profile: Profile) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                header(profile)

                VStack(spacing: 0) {
                    navigationRow(
                        title: "Мои NFT",
                        count: profile.nfts.count,
                        route: .myNfts
                    )

                    navigationRow(
                        title: "Избранные NFT",
                        count: profile.likes.count,
                        route: .favorites
                    )
                }
                .padding(.top, 40)
            }
            .padding(.horizontal, 16)
            .padding(.top, 20)
        }
        .background(Color.ypWhite)
    }

    // MARK: - Header

    private func header(_ profile: Profile) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center, spacing: 16) {
                avatar(sources: avatarSources(from: profile.avatar))

                Text(profile.name)
                    .font(.bold22)
                    .foregroundStyle(Color.ypBlack)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(height: 70)

            Text(profile.description ?? "")
                .font(.regular13)
                .foregroundStyle(Color.ypBlack)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 20)

            if let websiteURL = URL(string: profile.website) {
                Button {
                    router.push(ProfileRoute.userWeb(websiteURL), in: .profile)
                } label: {
                    Text(websiteTitle(for: profile.website))
                        .font(.regular15)
                        .foregroundStyle(Color.ypBlueUniversal)
                        .lineLimit(1)
                        .truncationMode(.middle)
                }
                .buttonStyle(.plain)
                .padding(.top, 8)
            }
        }
        .frame(height: 162, alignment: .topLeading)
    }

    // MARK: - Avatar

    private func avatar(sources: [Source]) -> some View {
        ZStack {
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .scaledToFit()
                .foregroundStyle(Color.ypGrayLight)

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
        }
        .frame(width: 70, height: 70)
        .clipShape(Circle())
    }

    private func avatarSources(from avatar: String) -> [Source] {
        guard let range = avatar.range(of: "/ipfs/") else {
            guard let url = URL(string: avatar) else {
                return []
            }

            return [
                .network(KF.ImageResource(downloadURL: url))
            ]
        }

        let ipfsPath = String(avatar[range.upperBound...])

        let gateways = [
            "https://ipfs.io/ipfs/",
            "https://gateway.pinata.cloud/ipfs/",
            "https://dweb.link/ipfs/"
        ]

        return gateways.compactMap { gateway in
            URL(string: "\(gateway)\(ipfsPath)")
        }
        .map {
            .network(KF.ImageResource(downloadURL: $0))
        }
    }

    // MARK: - Navigation

    private func navigationRow(
        title: String,
        count: Int,
        route: ProfileRoute
    ) -> some View {
        Button {
            router.push(route, in: .profile)
        } label: {
            HStack(spacing: 12) {
                Text("\(title)  (\(count))")
                    .font(.bold17)
                    .foregroundStyle(Color.ypBlack)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color.ypBlack)
                    .frame(width: 8, height: 14)
            }
            .contentShape(Rectangle())
            .frame(height: 54)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Helpers

    private func websiteTitle(for website: String) -> String {
        guard let url = URL(string: website),
              let host = url.host() else {
            return website
        }

        return host.replacingOccurrences(of: "www.", with: "")
    }

    private func errorContent(_ message: String) -> some View {
        VStack(spacing: 16) {
            Text(message)
                .font(.bold17)
                .foregroundStyle(Color.ypBlack)
                .multilineTextAlignment(.center)

            Button("Повторить") {
                Task {
                    await viewModel?.loadProfile()
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.ypWhite)
    }
}

// MARK: - ProfilePlaceholderView

struct ProfilePlaceholderView: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.bold22)
            .foregroundStyle(Color.ypBlack)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.ypWhite)
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        ProfileView()
            .environment(Router())
            .environment(ServicesAssembly(networkClient: DefaultNetworkClient()))
    }
}
