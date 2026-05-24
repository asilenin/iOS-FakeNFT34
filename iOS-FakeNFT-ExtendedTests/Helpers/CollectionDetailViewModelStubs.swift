import Foundation
@testable import iOS_FakeNFT_Extended

/// Тестовые стабы для `CollectionDetailViewModel` и его коллабораторов.
///
/// Вынесены в отдельный файл, чтобы соблюсти лимит SwiftLint `type_body_length`
/// для test-классов. Стабы конфигурируются после создания через `set...`-методы
/// — это даёт возможность менять поведение между этапами теста (например,
/// сначала упасть на load, потом успешно отработать на retry).

actor StubFavoritesService: FavoritesServiceProtocol {

    private var stored: Set<String>
    private var loadError: Error?
    private var setError: Error?
    private(set) var setCalls: [[String]] = []

    init(initial: Set<String> = []) {
        stored = initial
    }

    func setLoadError(_ error: Error?) {
        loadError = error
    }

    func setSetError(_ error: Error?) {
        setError = error
    }

    func setStored(_ ids: Set<String>) {
        stored = ids
    }

    func loadFavorites() async throws -> Set<String> {
        if let loadError {
            throw loadError
        }
        return stored
    }

    func setFavorites(_ ids: Set<String>) async throws -> Set<String> {
        if let setError {
            throw setError
        }
        setCalls.append(ids.sorted())
        stored = ids
        return stored
    }

    func invalidateCache() async {}
}

actor StubCartService: CartServiceProtocol {

    private var stored: Set<String>
    private var loadError: Error?
    private var setError: Error?
    private(set) var setCalls: [[String]] = []

    init(initial: Set<String> = []) {
        stored = initial
    }

    func setLoadError(_ error: Error?) {
        loadError = error
    }

    func setSetError(_ error: Error?) {
        setError = error
    }

    func setStored(_ ids: Set<String>) {
        stored = ids
    }

    func loadCart() async throws -> Set<String> {
        if let loadError {
            throw loadError
        }
        return stored
    }

    func setCart(_ ids: Set<String>) async throws -> Set<String> {
        if let setError {
            throw setError
        }
        setCalls.append(ids.sorted())
        stored = ids
        return stored
    }

    func loadCartItems() async throws -> [CartItem] {
        []
    }

    func invalidateCache() async {}
}

actor StubCollectionDetailService: CollectionDetailServiceProtocol {

    private let nfts: [Nft]
    private let error: Error?

    init(nfts: [Nft] = [], error: Error? = nil) {
        self.nfts = nfts
        self.error = error
    }

    func loadNfts(byIds ids: [String]) async throws -> [Nft] {
        if let error {
            throw error
        }
        return nfts
    }

    func invalidateCache() async {}
}
