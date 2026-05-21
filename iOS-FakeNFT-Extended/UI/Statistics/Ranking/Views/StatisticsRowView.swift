//
//  StatisticsRowView.swift
//  iOS-FakeNFT-Extended
//
//  Created by МAK on 12.05.2026.
//

import SwiftUI
import Kingfisher

private enum Layout {
    static let rowHeight: CGFloat = 70
    static let avatarSide: CGFloat = 35
    static let rankWidth: CGFloat = 28
    static let cardCornerRadius: CGFloat = 12
}

struct StatisticsRowView: View {

    // MARK: - Properties

    let rank: Int
    let user: StatisticsUser
    let onSelect: () -> Void

    // MARK: - Body

    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            Text("\(rank)")
                .font(.regular17)
                .foregroundStyle(Color.ypBlack)
                .frame(width: Layout.rankWidth, alignment: .trailing)

            Button(action: onSelect) {
                HStack(spacing: 12) {
                    avatar
                    Text(user.name)
                        .font(.bold17)
                        .foregroundStyle(Color.ypBlack)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("\(user.nftsCount)")
                        .font(.regular17)
                        .foregroundStyle(Color.ypBlack)
                }
                .padding(.horizontal, 12)
                .frame(height: Layout.rowHeight)
                .frame(maxWidth: .infinity)
                .background(Color.ypGrayLight)
                .clipShape(RoundedRectangle(cornerRadius: Layout.cardCornerRadius))
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Private Views

    @ViewBuilder
    private var avatar: some View {
        if let url = user.avatarURL {
            KFImage(url)
                .placeholder { LoadingSpinner(size: .small) }
                .resizable()
                .scaledToFill()
                .frame(width: Layout.avatarSide, height: Layout.avatarSide)
                .clipShape(Circle())
        } else {
            Circle()
                .fill(Color.ypWhite)
                .frame(width: Layout.avatarSide, height: Layout.avatarSide)
                .overlay {
                    Image(systemName: "person.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(Color.ypGrayUniversal)
                }
        }
    }
}

#Preview {
    StatisticsRowView(
        rank: 1,
        user: StatisticsUser(
            id: "1",
            name: "Alice",
            avatarURL: URL(string: "https://code.s3.yandex.net/Mobile/iOS/NFT/Beige/April/1.png"),
            nftsCount: 42,
            rating: 98
        ),
        onSelect: {}
    )
    .padding()
}
