//
//  ETHPriceFormatter.swift
//  iOS-FakeNFT-Extended
//
//  Created by Анастасия Федотова on 23.05.2026.
//

import Foundation

enum ETHPriceFormatter {

    // MARK: - Public Methods

    static func eth(_ value: Double, minimumFractionDigits: Int = 2) -> String {
        let number = NSNumber(value: value)
        let formattedValue = formatter(
            minimumFractionDigits: minimumFractionDigits
        ).string(from: number) ?? "\(value)"

        return "\(formattedValue) ETH"
    }

    static func eth(_ value: Float, minimumFractionDigits: Int = 2) -> String {
        eth(Double(value), minimumFractionDigits: minimumFractionDigits)
    }

    // MARK: - Private Methods

    private static func formatter(minimumFractionDigits: Int) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = minimumFractionDigits
        formatter.maximumFractionDigits = 2
        return formatter
    }
}
