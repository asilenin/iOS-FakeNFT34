import Foundation

@Observable
@MainActor
final class CatalogViewModel {

    private(set) var state: CatalogState = .loading
    private(set) var collections: [NftCollection] = []
    var error: Error?

    /// При изменении триггерит повторную загрузку. Кэш `CatalogService` отдаёт мгновенный ответ,
    /// если такой `sortBy` уже загружался.
    var sortOption: CatalogSortOption {
        didSet {
            guard sortOption != oldValue else { return }
            Task { await load() }
        }
    }

    private let service: CatalogServiceProtocol
    private var currentTask: Task<Void, Never>?

    init(service: CatalogServiceProtocol, initialSortOption: CatalogSortOption) {
        self.service = service
        self.sortOption = initialSortOption
    }

    /// Отменяет предыдущую загрузку, если она была в процессе.
    func load() async {
        currentTask?.cancel()

        let task = Task { [service, sortOption] in
            await performLoad(using: service, sortOption: sortOption)
        }
        currentTask = task
        await task.value
    }

    /// Минует кэш сервиса. Вызывается из pull-to-refresh.
    func reload() async {
        await service.invalidateCache()
        await load()
    }

    private func performLoad(using service: CatalogServiceProtocol, sortOption: CatalogSortOption) async {
        state = .loading
        do {
            let loaded = try await service.loadCollections(sortBy: sortOption)
            try Task.checkCancellation()
            collections = loaded
            state = .success
        } catch is CancellationError {
            return
        } catch {
            print("❌ [\(fileName())]: :\(#line)] \(#function) sortBy=\(sortOption.apiSortKey) error: \(error)")
            state = .error
            self.error = error
        }
    }
}
