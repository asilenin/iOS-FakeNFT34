//
//  PaymentResponseDTO.swift
//  iOS-FakeNFT-Extended
//
//  Created by Smirnov Michael on 17.05.2026.
//

import Foundation

struct PaymentResponseDTO: Decodable, Sendable {
    let success: Bool
    let orderId: String
    let id: String
}
