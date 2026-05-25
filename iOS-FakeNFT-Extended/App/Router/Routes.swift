import Foundation

/// Маршруты навигации в эпике Каталог.
///
/// Используется с `NavigationStack` и `navigationDestination(for:)` для типобезопасной навигации.
enum CatalogRoute: Hashable {
    /// Переход на экран деталей конкретной коллекции.
    case collection(NftCollection)

    /// Переход на экран WebView с сайтом автора коллекции.
    case authorWeb(URL)

    /// Переход на экран деталей NFT по идентификатору.
    case nftDetail(String)
}

enum CartRoute: Hashable {
    case payment
    case userAgreement(URL)
}

enum ProfileRoute: Hashable {
    case myNfts([String])
    case favorites([String])
    case edit(Profile)
    case userWeb(URL)
}

enum StatisticsRoute: Hashable {
    case userDetail(StatisticsUser)
    case userCollection(userId: String, userName: String)
    case userWebsite(URL)
    case nftDetail(String)
}
