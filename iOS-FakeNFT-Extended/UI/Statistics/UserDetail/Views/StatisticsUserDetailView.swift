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
        .navigationTitle(Text("Statistics.user.title"))
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
            VStack(alignment: .leading, spacing: 16) {
                avatar
                nameLabel
                descriptionLabel
                nftsCountLabel

                if viewModel.websiteURL != nil {
                    websiteButton
                }

                collectionButton
            }
            .padding(16)
        }
    }

    // MARK: - Subviews

    @ViewBuilder
    private var avatar: some View {
        let side: CGFloat = 310
        if let url = viewModel.avatarURL {
            KFImage(url)
                .placeholder { LoadingSpinner(size: .medium) }
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity)
                .frame(height: side)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        } else {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.ypGrayLight)
                .frame(height: side)
                .overlay {
                    Image(systemName: "person.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(Color.ypGrayUniversal)
                }
        }
    }

    private var nameLabel: some View {
        Text(viewModel.displayName)
            .font(.bold22)
            .foregroundStyle(Color.ypBlack)
    }

    private var descriptionLabel: some View {
        Text(viewModel.displayDescription)
            .font(.regular15)
            .foregroundStyle(Color.ypBlack)
            .fixedSize(horizontal: false, vertical: true)
    }

    private var nftsCountLabel: some View {
        Text(
            String(
                format: NSLocalizedString("Statistics.user.nftsCount", comment: ""),
                viewModel.nftsCount
            )
        )
        .font(.regular17)
        .foregroundStyle(Color.ypGrayUniversal)
    }

    private var websiteButton: some View {
        Button {
            guard let url = viewModel.websiteURL else { return }
            router.push(StatisticsRoute.userWebsite(url), in: .statistics)
        } label: {
            Text("Statistics.user.website")
                .font(.regular17)
                .foregroundStyle(Color.ypBlueUniversal)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .buttonStyle(.plain)
    }

    private var collectionButton: some View {
        Button {
            router.push(
                StatisticsRoute.userCollection(
                    userId: viewModel.userId,
                    userName: viewModel.displayName
                ),
                in: .statistics
            )
        } label: {
            Text("Statistics.user.openCollection")
                .font(.bold17)
                .foregroundStyle(Color.ypWhiteUniversal)
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .background(Color.ypBlack)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
        .padding(.top, 8)
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
