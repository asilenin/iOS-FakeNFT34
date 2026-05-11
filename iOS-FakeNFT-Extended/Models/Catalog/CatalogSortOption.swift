import Foundation

enum CatalogSortOption: String, CaseIterable {
    case name
    case nftCount
}

extension CatalogSortOption {

    var comparator: (NftCollection, NftCollection) -> Bool {
        switch self {
        case .name:
            return { lhs, rhs in
                lhs.name.localizedStandardCompare(rhs.name) == .orderedAscending
            }
        case .nftCount:
            return { lhs, rhs in
                if lhs.nfts.count != rhs.nfts.count {
                    return lhs.nfts.count > rhs.nfts.count
                }
                return lhs.name.localizedStandardCompare(rhs.name) == .orderedAscending
            }
        }
    }
}
