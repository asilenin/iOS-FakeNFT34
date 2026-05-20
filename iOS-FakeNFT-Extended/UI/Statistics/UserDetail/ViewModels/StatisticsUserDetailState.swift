//
//  StatisticsUserDetailState.swift
//  iOS-FakeNFT-Extended
//
//  Created by МAK on 17.05.2026.
//

import Foundation

enum StatisticsUserDetailState: Equatable {
    case loading
    case success
    case error(message: String)
    
    static func error(_ error: Error) -> StatisticsUserDetailState {
        .error(message: error.localizedDescription)
    }
}
