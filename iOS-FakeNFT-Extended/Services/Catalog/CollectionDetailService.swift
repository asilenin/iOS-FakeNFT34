import Foundation

/// Параллельная загрузка NFT по id с in-memory кэшем и дедупликацией.
/// Контракт best-effort — см. `CollectionDetailServiceProtocol`.
actor CollectionDetailService: CollectionDetailServiceProtocol {

    private let networkClient: NetworkClient

    private var cache: [String: Nft] = [:]

    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }

    func loadNfts(byIds ids: [String]) async throws -> [Nft] {
        let uniqueIds = Array(Set(ids))
        guard !uniqueIds.isEmpty else { return [] }

        let cached = uniqueIds.compactMap { cache[$0] }
        let missingIds = uniqueIds.filter { cache[$0] == nil }

        guard !missingIds.isEmpty else { return cached }

        let loaded = await loadFromNetwork(ids: missingIds)
        for nft in loaded {
            cache[nft.id] = nft
        }

        let result = cached + loaded

        if result.isEmpty {
            throw NetworkClientError.urlSessionError
        }
        return result
    }

    func invalidateCache() {
        cache.removeAll()
    }

    // MARK: - Private

    /// Параллельная загрузка через `withTaskGroup`. Ошибки отдельных запросов игнорируются.
    private func loadFromNetwork(ids: [String]) async -> [Nft] {
        await withTaskGroup(of: Nft?.self) { group in
            for id in ids {
                group.addTask { [networkClient] in
                    let request = NftRequest(id: id)
                    do {
                        let nft: Nft = try await networkClient.send(request: request)
                        return nft
                    } catch {
                        return nil
                    }
                }
            }
            var loaded: [Nft] = []
            for await nft in group {
                if let nft {
                    loaded.append(nft)
                }
            }
            return loaded
        }
    }
}
