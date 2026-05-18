import Foundation
@testable import iOS_FakeNFT_Extended

/// Тестовые стабы для `CollectionDetailViewModel` и его коллабораторов.
///
/// Вынесены в отдельный файл, чтобы соблюсти лимит SwiftLint `type_body_length`
/// для test-классов. Стабы конфигурируются после создания через `set...`-методы
/// — это даёт возможность менять поведение между этапами теста (например,
/// сначала упасть на load, потом успешно отработать на retry).

actor StubCollectionDetailService: CollectionDetailServiceProtocol {
    private var nfts: [Nft]
    private var error: Error?

    init(nfts: [Nft] = [], error: Error? = nil) {
        self.nfts = nfts
        self.error = error
    }

    func loadNfts(byIds ids: [String]) async throws -> [Nft] {
        if let error { throw error }
        return nfts
    }

    func invalidateCache() {}
}

actor StubFavoritesService: CatalogFavoritesServiceProtocol {
    private var stored: Set<String>
    private(set) var loadError: Error?
    private(set) var setError: Error?
    private(set) var setCalls: [Set<String>] = []

    init(initial: Set<String> = []) {
        self.stored = initial
    }

    func setLoadError(_ error: Error?) { loadError = error }
    func setSetError(_ error: Error?) { setError = error }
    func setStored(_ ids: Set<String>) { stored = ids }

    func loadFavorites() async throws -> Set<String> {
        if let loadError { throw loadError }
        return stored
    }

    func setFavorites(_ ids: Set<String>) async throws -> Set<String> {
        setCalls.append(ids)
        if let setError { throw setError }
        stored = ids
        return ids
    }

    func invalidateCache() {}
}

actor StubCartService: CatalogCartServiceProtocol {
    private var stored: Set<String>
    private(set) var loadError: Error?
    private(set) var setError: Error?
    private(set) var setCalls: [Set<String>] = []

    init(initial: Set<String> = []) {
        self.stored = initial
    }

    func setLoadError(_ error: Error?) { loadError = error }
    func setSetError(_ error: Error?) { setError = error }
    func setStored(_ ids: Set<String>) { stored = ids }

    func loadCart() async throws -> Set<String> {
        if let loadError { throw loadError }
        return stored
    }

    func setCart(_ ids: Set<String>) async throws -> Set<String> {
        setCalls.append(ids)
        if let setError { throw setError }
        stored = ids
        return ids
    }

    func invalidateCache() {}
}
