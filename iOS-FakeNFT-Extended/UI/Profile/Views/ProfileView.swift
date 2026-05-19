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

    // MARK: - State

    @Bindable var viewModel: ProfileViewModel

    // MARK: - Body

    var body: some View {
        content
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        if let profile = viewModel.loadedProfile {
                            router.push(ProfileRoute.edit(profile), in: .profile)
                        }
                    } label: {
                        Image(.edit)
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .foregroundStyle(Color.ypBlack)
                            .frame(width: 42, height: 42)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(Text("Profile.edit.accessibility"))
                }
            }
            .task {
                await viewModel.loadProfile()
            }
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            LoadingSpinner(size: .medium)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.ypWhite)
        case .loaded(let profile):
            profileContent(profile)
        case .failed(let message):
            errorContent(message)
        }
    }

    private func profileContent(_ profile: Profile) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                header(profile)

                VStack(spacing: 0) {
                    navigationRow(
                        title: String(localized: "Profile.myNfts"),
                        count: profile.nfts?.count ?? 0,
                        route: .myNfts(profile.nfts ?? [])
                    )

                    navigationRow(
                        title: String(localized: "Profile.favoriteNfts"),
                        count: profile.likes?.count ?? 0,
                        route: .favorites
                    )
                }
                .padding(.top, 32)
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
                avatar(sources: profileAvatarSources(from: profile.avatar ?? ""))

                Text(profile.name ?? "")
                    .font(.bold22)
                    .foregroundStyle(Color.ypBlack)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(height: 70)

            if let description = profile.description, !description.isEmpty {
                Text(description)
                    .font(.regular13)
                    .foregroundStyle(Color.ypBlack)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 20)
            }

            if let website = profile.website,
               let websiteURL = URL(string: website) {
                Button {
                    router.push(ProfileRoute.userWeb(websiteURL), in: .profile)
                } label: {
                    Text(websiteTitle(for: website))
                        .font(.regular15)
                        .foregroundStyle(Color.ypBlueUniversal)
                        .lineLimit(1)
                        .truncationMode(.middle)
                }
                .buttonStyle(.plain)
                .padding(.top, 8)
            }
        }
    }

    // MARK: - Avatar

    @ViewBuilder
    private func avatar(sources: [Source]) -> some View {
        if sources.isEmpty {
            avatarPlaceholder
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
                .frame(width: 70, height: 70)
                .clipShape(Circle())
        }
    }

    private var avatarPlaceholder: some View {
        ZStack {
            Color.ypWhite

            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .scaledToFit()
                .foregroundStyle(.ypGrayLight)
                .frame(width: 70, height: 70)
        }
        .frame(width: 70, height: 70)
        .clipShape(Circle())
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

            Button(String(localized: "Profile.retry")) {
                Task {
                    await viewModel.loadProfile()
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
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(title)
                        .font(.bold17)
                        .foregroundStyle(Color.ypBlack)
                }
            }
    }
}

#Preview {
    NavigationStack {
        ProfileView(
            viewModel: ProfileViewModel(
                profileService: ProfileService(networkClient: DefaultNetworkClient())
            )
        )
            .environment(Router())
    }
}
