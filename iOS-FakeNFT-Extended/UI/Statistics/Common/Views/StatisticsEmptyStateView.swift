//
//  StatisticsEmptyStateView.swift
//  iOS-FakeNFT-Extended
//
//  Created by МAK on 17.05.2026.
//

import SwiftUI

struct StatisticsEmptyStateView: View {

    let message: LocalizedStringKey

    var body: some View {
        Text(message)
            .font(.bold17)
            .foregroundStyle(Color.ypBlack)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 32)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    StatisticsEmptyStateView(message: "Statistics.collection.empty")
}
