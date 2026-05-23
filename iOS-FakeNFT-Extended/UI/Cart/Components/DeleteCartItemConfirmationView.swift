//
//  DeleteCartItemConfirmationView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Smirnov Michael on 14.05.2026.
//

import Kingfisher
import SwiftUI

struct DeleteCartItemConfirmationView: View {
    let item: CartItem
    let onDelete: () -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(spacing: Constants.mainSpacing) {
            KFImage(item.imageURL)
                .placeholder {
                    SkeletonView(cornerRadius: Constants.imageCornerRadius)
                }
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: Constants.imageSize, height: Constants.imageSize)
                .clipShape(
                    RoundedRectangle(cornerRadius: Constants.imageCornerRadius)
                )

            Text(String(localized: "Cart.Delete.confirmation"))
                .font(.regular17)
                .foregroundStyle(.ypBlack)
                .multilineTextAlignment(.center)
                .lineSpacing(Constants.textLineSpacing)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: Constants.buttonSpacing) {
                actionButton(
                    title: String(localized: "Cart.Delete.delete"),
                    foregroundColor: .ypRedUniversal,
                    action: onDelete
                )

                actionButton(
                    title: String(localized: "Cart.Delete.cancel"),
                    foregroundColor: .ypWhite,
                    action: onCancel
                )
            }
            .padding(.top, Constants.buttonsTopPadding)
        }
        .frame(maxWidth: Constants.contentMaxWidth)
    }

    private func actionButton(
        title: String,
        foregroundColor: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Text(title)
                .font(.regular17)
                .foregroundStyle(foregroundColor)
                .frame(maxWidth: .infinity)
                .frame(height: Constants.buttonHeight)
                .background(.ypBlack)
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: Constants.buttonCornerRadius
                    )
                )
        }
        .buttonStyle(.plain)
    }
}

private extension DeleteCartItemConfirmationView {
    enum Constants {
        static let mainSpacing: CGFloat = 20
        static let contentMaxWidth: CGFloat = 580

        static let imageSize: CGFloat = 108
        static let imageCornerRadius: CGFloat = 12

        static let textLineSpacing: CGFloat = 4

        static let buttonsTopPadding: CGFloat = 8
        static let buttonSpacing: CGFloat = 8
        static let buttonHeight: CGFloat = 44
        static let buttonCornerRadius: CGFloat = 12
    }
}

#Preview {
    DeleteCartItemConfirmationView(
        item: CartItem(
            id: "1",
            title: "April",
            imageURL: nil,
            rating: 4,
            price: 1.78
        ),
        onDelete: {},
        onCancel: {}
    )
    .padding(.horizontal, 62)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(.ultraThinMaterial)
}
