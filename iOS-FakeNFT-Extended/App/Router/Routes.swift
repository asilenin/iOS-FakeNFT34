import Foundation

/// Маршруты навигации в эпике Каталог.
///
/// Используется с `NavigationStack` и `navigationDestination(for:)` для типобезопасной навигации.
enum CatalogRoute: Hashable {
    /// Переход на экран деталей конкретной коллекции.
    case collection(NftCollection)

    // case authorWeb(URL)  // TODO(PR#2): навигация на сайт автора
}

enum CartRoute: Hashable {
    case _placeholder
    // case currencySelection
    // case userAgreement(URL)
}

enum ProfileRoute: Hashable {
    case _placeholder
    // case myNfts
    // case favorites
    // case edit
    // case userWeb(URL)
}

enum StatisticsRoute: Hashable {
    case _placeholder
    // case user(User)
    // case userCollection(User)
    // case userWeb(URL)
}
