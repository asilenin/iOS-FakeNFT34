//
//  CartPriceFormatter.swift
//  iOS-FakeNFT-Extended
//
//  Created by Smirnov Michael on 17.05.2026.
//

import Foundation

enum CartPriceFormatter {
    private static let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter
    }()

    static func eth(_ value: Double) -> String {
        let number = NSNumber(value: value)
        let formattedValue = formatter.string(from: number) ?? "\(value)"
        return "\(formattedValue) ETH"
    }
}
