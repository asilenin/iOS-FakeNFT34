import Foundation

@Observable
@MainActor
final class CatalogViewModel {

    /// Текущее состояние загрузки.
    private(set) var state: CatalogState = .loading

    private(set) var collections: [NftCollection] = []

    /// Ошибка последней попытки загрузки, если она была.
    /// Используется для отображения алерта через `ErrorAlert` компонент.
    var error: Error?

    /// Опция сортировки, выбранная пользователем.
    /// При изменении триггерится повторная загрузка с сервера (с новым `sortBy`).
    /// Запрос проходит через кэш `CatalogService` — если такой sortBy уже загружался,
    /// сеть не дёргается, ответ приходит мгновенно.
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

    /// Загрузить коллекции с сервера с текущей `sortOption`.
    /// Отменяет предыдущую загрузку, если она была в процессе.
    func load() async {
        currentTask?.cancel()

        let task = Task { [service, sortOption] in
            await performLoad(using: service, sortOption: sortOption)
        }
        currentTask = task
        await task.value
    }

    /// Принудительно перезагружает с сервера, минуя кэш.
    /// Вызывается из pull-to-refresh.
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
