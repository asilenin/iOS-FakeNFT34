//
//  StatisticsState.swift
//  iOS-FakeNFT-Extended
//
//  Created by МAK on 16.05.2026.
//

import Foundation

enum StatisticsState: Equatable {
    case loading
    case empty
    case success
    case error(message: String)

    static func error(_ error: Error) -> StatisticsState {
        .error(message: error.localizedDescription)
    }
}
