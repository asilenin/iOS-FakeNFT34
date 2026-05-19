//
//  StatisticsNftDetailView.swift
//  iOS-FakeNFT-Extended
//
//  Created by МAK on 17.05.2026.
//

import SwiftUI

struct StatisticsNftDetailView: View {

    let nftId: String

    var body: some View {
        ZStack {
            Color.ypWhite.ignoresSafeArea()

            VStack(spacing: 8) {
                Text("Statistics.nftDetail.title")
                    .font(.bold22)
                    .foregroundStyle(Color.ypBlack)

                Text("id: \(nftId)")
                    .font(.regular13)
                    .foregroundStyle(Color.ypGrayUniversal)

                Text("Statistics.nftDetail.placeholder")
                    .font(.regular17)
                    .foregroundStyle(Color.ypGrayUniversal)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        StatisticsNftDetailView(nftId: "1-nft-0")
    }
}
