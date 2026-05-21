//
//  ProfileAvatarSources.swift
//  iOS-FakeNFT-Extended
//
//  Created by Анастасия Федотова on 15.05.2026.
//

import Kingfisher
import Foundation

func profileAvatarSources(from avatar: String) -> [Source] {
    guard let range = avatar.range(of: "/ipfs/") else {
        guard let url = URL(string: avatar) else {
            return []
        }

        return [
            .network(KF.ImageResource(downloadURL: url))
        ]
    }

    let ipfsPath = String(avatar[range.upperBound...])

    let gateways = [
        "https://ipfs.io/ipfs/",
        "https://gateway.pinata.cloud/ipfs/",
        "https://dweb.link/ipfs/"
    ]

    return gateways.compactMap { gateway in
        URL(string: "\(gateway)\(ipfsPath)")
    }
    .map {
        .network(KF.ImageResource(downloadURL: $0))
    }
}
