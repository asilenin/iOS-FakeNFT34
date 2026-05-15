import Foundation

/// Опция сортировки каталога коллекций.
///
/// Значение сохраняется в `UserDefaults` под ключом `"catalogSortOption"` и переживает перезапуск приложения.
enum CatalogSortOption: String, CaseIterable {
    /// Сортировка по названию коллекции в алфавитном порядке (локализованное сравнение).
    case name

    /// Сортировка по количеству NFT в коллекции в порядке убывания.
    /// При равном количестве NFT вторичный ключ — имя коллекции.
    case nftCount
}

extension CatalogSortOption {

    var comparator: (NftCollection, NftCollection) -> Bool {
        switch self {
        case .name:
            return { lhs, rhs in
                Self.compareByName(lhs, rhs)
            }
        case .nftCount:
            return { lhs, rhs in
                let lhsCount = lhs.nfts?.count ?? 0
                let rhsCount = rhs.nfts?.count ?? 0
                if lhsCount != rhsCount {
                    return lhsCount > rhsCount
                }
                return Self.compareByName(lhs, rhs)
            }
        }
    }

    /// Сравнение коллекций по имени с правилом:
    /// коллекции с `name == nil` всегда уходят в конец списка.
    private static func compareByName(_ lhs: NftCollection, _ rhs: NftCollection) -> Bool {
        switch (lhs.name, rhs.name) {
        case let (lhsName?, rhsName?):
            return lhsName.localizedStandardCompare(rhsName) == .orderedAscending
        case (_?, nil):
            return true   // именованная < безымянной
        case (nil, _?):
            return false  // безымянная > именованной
        case (nil, nil):
            return false  // одинаковы, порядок не важен
        }
    }
}
