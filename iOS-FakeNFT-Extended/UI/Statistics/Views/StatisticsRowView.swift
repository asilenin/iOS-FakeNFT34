//
//  StatisticsRowView.swift
//  iOS-FakeNFT-Extended
//
//  Created by МAK on 12.05.2026.
//

import SwiftUI
import Kingfisher

struct StatisticsRowView: View {

    // MARK: - Properties

    let rank: Int
    let user: StatisticsUser
    let onSelect: () -> Void

    // MARK: - Body

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                Text("\(rank)")
                    .font(.regular15)
                    .foregroundStyle(Color.ypBlack)
                    .frame(minWidth: 24, alignment: .leading)

                avatar
                nameLabel
                Spacer(minLength: 8)
                nftCountLabel
            }
            .padding(.vertical, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Private Views

    private var nameLabel: some View {
        Text(user.name)
            .font(.regular17)
            .foregroundStyle(Color.ypBlack)
            .lineLimit(1)
    }

    private var nftCountLabel: some View {
        Text("\(user.nftsCount)")
            .font(.regular17)
            .foregroundStyle(Color.ypBlack)
    }

    @ViewBuilder
    private var avatar: some View {
        let side: CGFloat = 48
        if let url = user.avatarURL {
            KFImage(url)
                .placeholder {
                    LoadingSpinner(size: .small)
                }
                .resizable()
                .scaledToFill()
                .frame(width: side, height: side)
                .clipShape(Circle())
        } else {
            Circle()
                .fill(Color.ypGrayLight)
                .frame(width: side, height: side)
                .overlay {
                    Image(systemName: "person.fill")
                        .foregroundStyle(Color.ypGrayUniversal)
                }
        }
    }
}

#Preview {
    List {
        StatisticsRowView(
            rank: 1,
            user: StatisticsUser(id: "p", name: "Preview", avatarURL: nil, nftsCount: 10, rating: 50),
            onSelect: {}
        )
    }
}
