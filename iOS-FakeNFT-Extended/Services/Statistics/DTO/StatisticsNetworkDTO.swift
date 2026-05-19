//
//  StatisticsNetworkDTO.swift
//  iOS-FakeNFT-Extended
//
//  Created by МAK on 19.05.2026.
//

import Foundation

// MARK: - API DTO

struct UserNetworkDTO: Decodable {
    let id: String
    let name: String
    let avatar: String?
    let description: String?
    let website: String?
    let nfts: [String]?
    let rating: FlexibleInt?
}

struct NftNetworkDTO: Decodable {
    let id: String
    let name: String
    let images: [String]?
    let rating: Int?
    let price: Float?
}

struct ProfileNetworkDTO: Decodable {
    let likes: [String]?
}

struct OrderNetworkDTO: Decodable {
    let nfts: [String]?
}

struct FlexibleInt: Decodable {
    let value: Int

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let intValue = try? container.decode(Int.self) {
            value = intValue
            return
        }
        if let stringValue = try? container.decode(String.self),
           let intValue = Int(stringValue) {
            value = intValue
            return
        }
        value = 0
    }
}

// MARK: - Mapping

extension UserNetworkDTO {

    func toStatisticsUser() -> StatisticsUser {
        StatisticsUser(
            id: id,
            name: name,
            avatarURL: avatar.flatMap(URL.init(string:)),
            nftsCount: NetworkIdListParser.parse(nfts).count,
            rating: rating?.value ?? 0
        )
    }

    func toStatisticsUserDetail() -> StatisticsUserDetail {
        StatisticsUserDetail(
            id: id,
            name: name,
            description: description ?? "",
            avatarURL: avatar.flatMap(URL.init(string:)),
            websiteURL: website.flatMap(URL.init(string:)),
            nftsCount: NetworkIdListParser.parse(nfts).count,
            rating: rating?.value ?? 0
        )
    }
}

extension NftNetworkDTO {

    func toStatisticsNft() -> StatisticsNft {
        StatisticsNft(
            id: id,
            name: name,
            imageURL: images?.first.flatMap(URL.init(string:)),
            rating: rating ?? 0,
            price: price ?? 0
        )
    }
}
