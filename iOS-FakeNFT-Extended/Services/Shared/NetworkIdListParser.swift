//
//  NetworkIdListParser.swift
//  iOS-FakeNFT-Extended
//
//  Created by МAK on 19.05.2026.
//

import Foundation

enum NetworkIdListParser {

    static func parse(_ values: [String]?) -> [String] {
        guard let values else { return [] }
        return values
            .flatMap { $0.split(separator: ",") }
            .map { String($0).trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
    }

    static func parseSet(_ values: [String]?) -> Set<String> {
        Set(parse(values))
    }

    static func joined(_ ids: Set<String>) -> String {
        ids.sorted().joined(separator: ",")
    }
}
