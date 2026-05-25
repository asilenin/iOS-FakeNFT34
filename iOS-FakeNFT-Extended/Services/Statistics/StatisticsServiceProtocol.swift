//
//  StatisticsServiceProtocol.swift
//  iOS-FakeNFT-Extended
//
//  Created by МAK on 12.05.2026.
//

import Foundation

protocol StatisticsServiceProtocol: Sendable {
    func fetchRankingUsers() async throws -> [StatisticsUser]
    func fetchUserDetail(userId: String) async throws -> StatisticsUserDetail
    func fetchUserNfts(userId: String) async throws -> [StatisticsNft]
}
