import Foundation

/// Опция сортировки каталога. Хранится в `UserDefaults` под ключом `"catalogSortOption"`.
enum CatalogSortOption: String, CaseIterable {
    case name
    case nftCount
}

extension CatalogSortOption {

    /// Значение query-параметра `sortBy` для mock-сервера.
    var apiSortKey: String {
        switch self {
        case .name:
            return "name"
        case .nftCount:
            return "nfts"
        }
    }

    /// Локальный компаратор для `MockCatalogService` и тестов.
    /// `.nftCount`: по убыванию количества, при равенстве — по имени.
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

    /// Коллекции с `name == nil` уходят в конец.
    private static func compareByName(_ lhs: NftCollection, _ rhs: NftCollection) -> Bool {
