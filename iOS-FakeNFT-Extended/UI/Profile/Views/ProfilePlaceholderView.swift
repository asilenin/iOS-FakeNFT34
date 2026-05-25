//
//  ProfilePlaceholderView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Анастасия Федотова on 23.05.2026.
//

import SwiftUI

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
