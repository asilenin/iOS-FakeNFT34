//
//  StatisticsUserPlaceholderView.swift
//  iOS-FakeNFT-Extended
//
//  Created by МAK on 12.05.2026.
//

import SwiftUI

struct StatisticsUserPlaceholderView: View {
    let user: StatisticsUser

    var body: some View {
        VStack(spacing: 16) {
            Text(user.name)
                .font(.bold22)
                .foregroundStyle(Color.ypBlack)
            Text("ID: \(user.id)")
                .font(.regular15)
                .foregroundStyle(Color.ypGrayUniversal)
            Text("Statistics.user.placeholder")
                .font(.regular17)
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.ypBlack)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.ypWhite.ignoresSafeArea())
        .navigationTitle(Text("Statistics.user.title"))
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        StatisticsUserPlaceholderView(
            user: StatisticsUser(id: "1", name: "Alice", avatarURL: nil, nftsCount: 1, rating: 1)
        )
    }
}
