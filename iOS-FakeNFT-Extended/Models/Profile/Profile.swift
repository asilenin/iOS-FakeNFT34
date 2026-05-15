//
//  Profile.swift
//  iOS-FakeNFT-Extended
//
//  Created by Анастасия Федотова on 06.05.2026.
//

import Foundation

struct Profile: Codable, Hashable, Identifiable, Sendable {
    let id: String?
    let name: String?
    let description: String?
    let website: String?
    let avatar: String?
    let nfts: [String]?
    let likes: [String]?
}
