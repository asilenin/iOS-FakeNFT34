import Foundation

/// Маршруты навигации в эпике Каталог.
///
/// Используется с `NavigationStack` и `navigationDestination(for:)` для типобезопасной навигации.
enum CatalogRoute: Hashable {
    /// Переход на экран деталей конкретной коллекции.
    case collection(NftCollection)
 
    /// Переход на экран WebView с сайтом автора коллекции.
    case authorWeb(URL)
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
