//
//  PaymentView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Smirnov Michael on 14.05.2026.
//

import SwiftUI

struct PaymentView: View {
    @Environment(Router.self) private var router

    private let agreementURL = URL(string: "https://yandex.ru/legal/practicum_termsofuse")

    var body: some View {
        VStack(spacing: Constants.spacing) {
            Spacer()

            Text("Выбор способа оплаты")
                .font(.bold22)
                .foregroundStyle(.ypBlack)

            Text("Экран валют будет реализован в Sprint 4")
                .font(.regular15)
                .foregroundStyle(.ypBlack)
                .multilineTextAlignment(.center)

            Button("Пользовательское соглашение") {
                guard let agreementURL else { return }
                router.push(CartRoute.userAgreement(agreementURL), in: .cart)
            }
            .font(.regular15)
            .foregroundStyle(.ypBlueUniversal)

            Spacer()
        }
        .padding(.horizontal, Constants.horizontalPadding)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.ypWhite)
        .navigationBarTitleDisplayMode(.inline)
    }
}

private extension PaymentView {
    enum Constants {
        static let spacing: CGFloat = 16
        static let horizontalPadding: CGFloat = 16
    }
}

#Preview {
    NavigationStack {
        PaymentView()
            .environment(Router())
    }
}
