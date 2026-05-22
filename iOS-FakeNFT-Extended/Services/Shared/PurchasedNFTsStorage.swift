import Foundation

protocol PurchasedNFTsStorageProtocol: Sendable {
    func loadPurchasedNFTIds() async -> Set<String>
    func addPurchasedNFTIds(_ ids: Set<String>) async
}

actor PurchasedNFTsStorage: PurchasedNFTsStorageProtocol {

    private let userDefaults: UserDefaults
    private let key = "purchased_nft_ids"

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func loadPurchasedNFTIds() async -> Set<String> {
        let ids = userDefaults.stringArray(forKey: key) ?? []
        return Set(ids)
    }

    func addPurchasedNFTIds(_ ids: Set<String>) async {
        let currentIds = await loadPurchasedNFTIds()
        let updatedIds = currentIds.union(ids)
        userDefaults.set(Array(updatedIds), forKey: key)
    }
}
