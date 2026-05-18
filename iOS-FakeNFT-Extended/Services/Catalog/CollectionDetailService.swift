import Foundation

/// Реальная реализация `CollectionDetailServiceProtocol`, ходящая в mock-сервер Practicum.
///
/// - Загружает NFT параллельно через `withTaskGroup` (best-effort:
///   индивидуальные ошибки глотаются, метод бросает только если все упали).
/// - Дедуплицирует id перед загрузкой, поэтому повторяющиеся id в `collection.nfts`
///   не вызывают повторных сетевых запросов.
/// - Кэширует загруженные NFT по id в памяти. Кэш сбрасывается через
///   `invalidateCache()` (вызывается из pull-to-refresh во View).
actor CollectionDetailService: CollectionDetailServiceProtocol {

    private let networkClient: NetworkClient

    /// Ключ — id NFT, значение — последний загруженный объект.
    private var cache: [String: Nft] = [:]

    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }

    func loadNfts(byIds ids: [String]) async throws -> [Nft] {
        let uniqueIds = Array(Set(ids))
        guard !uniqueIds.isEmpty else { return [] }

        let cached = uniqueIds.compactMap { cache[$0] }
        let missingIds = uniqueIds.filter { cache[$0] == nil }

        print("ℹ️ [\(fileName())]: :\(#line)] \(#function) requested \(uniqueIds.count) unique ids, \(cached.count) from cache, \(missingIds.count) to fetch")

        guard !missingIds.isEmpty else { return cached }

        let loaded = await loadFromNetwork(ids: missingIds)
        for nft in loaded {
            cache[nft.id] = nft
        }

        let result = cached + loaded
        let failedCount = missingIds.count - loaded.count
        if failedCount > 0 {
            print("ℹ️ [\(fileName())]: :\(#line)] \(#function) \(loaded.count) loaded, \(failedCount) failed (best-effort, kept successful)")
        }

        if result.isEmpty {
            print("❌ [\(fileName())]: :\(#line)] \(#function) no NFTs retrieved at all (cache empty + all requests failed)")
            throw NetworkClientError.urlSessionError
        }
        return result
    }

    func invalidateCache() {
        cache.removeAll()
    }

    // MARK: - Private

    /// Загружает NFT по списку id параллельно. Ошибки отдельных запросов
    /// игнорируются — в результат попадают только успешные.
    private func loadFromNetwork(ids: [String]) async -> [Nft] {
        await withTaskGroup(of: Nft?.self) { group in
            for id in ids {
                group.addTask { [networkClient] in
                    let request = NftByIdRequest(id: id)
                    print("ℹ️ [\(fileName())]: :\(#line)] \(#function) GET \(request.endpoint?.absoluteString ?? "nil")")
                    do {
                        let nft: Nft = try await networkClient.send(request: request)
                        return nft
                    } catch {
                        print("❌ [\(fileName())]: :\(#line)] \(#function) failed for id=\(id): \(error)")
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
