import Foundation

enum CatalogRoute: Hashable {
    case collection(NftCollection)
    case authorWeb(URL)
    case nftDetail(String)
}

enum CartRoute: Hashable {
    case payment
    case userAgreement(URL)
}

enum ProfileRoute: Hashable {
    case _placeholder
}

enum StatisticsRoute: Hashable {
    case userDetail(StatisticsUser)
    case userCollection(userId: String, userName: String)
    case userWebsite(URL)
    case nftDetail(String)
    case _placeholder
}
