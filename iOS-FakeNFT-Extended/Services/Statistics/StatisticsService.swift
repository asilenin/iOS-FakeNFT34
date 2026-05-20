//
//  StatisticsService.swift
//  iOS-FakeNFT-Extended
//
//  Created by МAK on 19.05.2026.
//

import Foundation

actor StatisticsService: StatisticsServiceProtocol {

    private let networkClient: NetworkClient
    private let pageSize: Int

    init(
        networkClient: NetworkClient,
        pageSize: Int = RequestConstants.defaultStatisticsPageSize
    ) {
        self.networkClient = networkClient
        self.pageSize = pageSize
    }

    func fetchRankingUsers() async throws -> [StatisticsUser] {
        var page = 0
        var result: [StatisticsUser] = []

        while true {
            let dtos: [UserNetworkDTO] = try await networkClient.send(
                request: GetUsersRequest(page: page, size: pageSize)
            )
            let users = dtos.map { $0.toStatisticsUser() }
            result.append(contentsOf: users)

            if users.count < pageSize {
                break
            }
            page += 1
        }

        return result
    }

    func fetchUserDetail(userId: String) async throws -> StatisticsUserDetail {
        let dto: UserNetworkDTO = try await networkClient.send(
            request: GetUserRequest(userId: userId)
        )
        return dto.toStatisticsUserDetail()
    }

    func fetchUserNfts(userId: String) async throws -> [StatisticsNft] {
        let user: UserNetworkDTO = try await networkClient.send(
            request: GetUserRequest(userId: userId)
        )
        let nftIds = NetworkIdListParser.parse(user.nfts)
        guard !nftIds.isEmpty else { return [] }

        let client = networkClient
        return try await withThrowingTaskGroup(of: StatisticsNft.self) { group in
            for nftId in nftIds {
                group.addTask {
                    let dto: CartNftDTO = try await client.send(
                        request: LoadNftRequest(nftID: nftId)
                    )
                    return dto.toStatisticsNft()
                }
            }

            var nfts: [StatisticsNft] = []
            for try await nft in group {
                nfts.append(nft)
            }
            return nfts.sorted {
                $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
            }
        }
    }
}
