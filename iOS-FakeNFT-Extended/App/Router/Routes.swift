import Foundation

enum CatalogRoute: Hashable {
    case _placeholder
    // case collection(NftCollection)
    // case authorWeb(URL)
}

enum CartRoute: Hashable {
    case payment
    case userAgreement(URL)
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
