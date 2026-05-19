//
//  StatisticsUserDetailView.swift
//  iOS-FakeNFT-Extended
//
//  Created by МAK on 17.05.2026.
//

import SwiftUI
import Kingfisher

struct StatisticsUserDetailView: View {

    @Environment(Router.self) private var router
    @State private var viewModel: StatisticsUserDetailViewModel

    init(viewModel: StatisticsUserDetailViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        ZStack {
            Color.ypWhite.ignoresSafeArea()
            content
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    router.pop(in: .statistics)
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(Color.ypBlack)
                }
            }
        }
        .task { await viewModel.load() }
        .errorAlert(error: $viewModel.loadError) {
            Task { await viewModel.load() }
        }
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .loading:
            LoadingSpinner(size: .large)
        case .success:
            successContent
        case .error:
            StatisticsEmptyStateView(message: "Statistics.loadErrorHint")
        }
    }

    private var successContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                profileHeader

                if viewModel.websiteURL != nil {
                    websiteButton
                        .padding(.top, 20)
                }

                collectionRow
                    .padding(.top, 32)
            }
            .padding(.horizontal, 16)
            .padding(.top, 20)
            .padding(.bottom, 24)
        }
    }

    // MARK: - Header

    private var profileHeader: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center, spacing: 16) {
                avatar
                Text(viewModel.displayName)
                    .font(.bold22)
                    .foregroundStyle(Color.ypBlack)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(height: 70)

            if !viewModel.displayDescription.isEmpty {
                Text(viewModel.displayDescription)
                    .font(.regular13)
                    .foregroundStyle(Color.ypBlack)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 20)
            }
        }
    }

    @ViewBuilder
    private var avatar: some View {
        let side: CGFloat = 70
        if let url = viewModel.avatarURL {
            KFImage(url)
                .placeholder {
                    ZStack {
                        Color.ypBackgroundUniversal
                        LoadingSpinner(size: .medium, tint: .ypWhiteUniversal)
                    }
                }
                .resizable()
                .scaledToFill()
                .frame(width: side, height: side)
                .clipShape(Circle())
        } else {
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .scaledToFit()
                .foregroundStyle(Color.ypGrayLight)
                .frame(width: side, height: side)
        }
    }

    // MARK: - Website

    private var websiteButton: some View {
        Button {
            guard let url = viewModel.websiteURL else { return }
            router.push(StatisticsRoute.userWebsite(url), in: .statistics)
        } label: {
            Text("Statistics.user.openWebsite")
                .font(.regular17)
                .foregroundStyle(Color.ypBlack)
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .background(Color.ypWhite)
                .clipShape(Capsule())
                .overlay {
                    Capsule()
                        .stroke(Color.ypBlack, lineWidth: 1)
                }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Collection row

    private var collectionRow: some View {
        Button {
            router.push(
                StatisticsRoute.userCollection(
                    userId: viewModel.userId,
                    userName: viewModel.displayName
                ),
                in: .statistics
            )
        } label: {
            HStack(spacing: 12) {
                Text(
                    String(
                        format: NSLocalizedString("Statistics.user.collectionRow", comment: ""),
                        viewModel.nftsCount
                    )
                )
                .font(.bold17)
                .foregroundStyle(Color.ypBlack)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color.ypBlack)
                    .frame(width: 8, height: 14)
            }
            .frame(height: 54)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    @Previewable @State var router = Router()
    let services = ServicesAssembly(networkClient: DefaultNetworkClient())
    let user = StatisticsUser(
        id: "1",
        name: "Alice",
        avatarURL: nil,
        nftsCount: 5,
        rating: 90
    )

    NavigationStack(path: $router.statisticsPath) {
        StatisticsUserDetailView(
            viewModel: StatisticsUserDetailViewModel(
                summary: user,
                statisticsService: services.statisticsService
            )
        )
    }
    .environment(router)
}
