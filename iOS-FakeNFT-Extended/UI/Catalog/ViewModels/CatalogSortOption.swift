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
