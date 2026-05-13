import Foundation

@Observable
@MainActor
final class CatalogViewModel {
    
    /// Состояние загрузки и данные каталога.
    ///
    /// `.idle` — начальное состояние перед первой загрузкой.
    /// `.loading` — идёт загрузка коллекций с сервера.
    /// `.loaded([collections])` — коллекции успешно загружены и отсортированы.
    /// `.error` — произошла ошибка при загрузке; детали в `error`.
    enum LoadState {
        case idle
        case loading
        case loaded([NftCollection])
        case error
    }

    /// Текущее состояние загрузки.
    private(set) var state: LoadState = .idle
    
    /// Ошибка последней попытки загрузки, если она была.
    /// Используется для отображения алерта через `ErrorAlert` компонент.
    var error: Error?
    
    /// Опция сортировки, выбранная пользователем.
    /// При изменении список коллекций автоматически пересортируется.
    var sortOption: CatalogSortOption = .nftCount {
        didSet {
            guard sortOption != oldValue else { return }
            applySortToState()
        }
    }

    private let service: CatalogServiceProtocol
    private var currentTask: Task<Void, Never>?

    init(service: CatalogServiceProtocol) {
        self.service = service
    }
    
    /// Загрузить коллекции с сервера и отсортировать по текущей опции.
    /// Отменяет предыдущую загрузку, если она была в процессе.
    func load() async {
        currentTask?.cancel()

        let task = Task { [service] in
            await performLoad(using: service)
        }
        currentTask = task
        await task.value
    }

    private func performLoad(using service: CatalogServiceProtocol) async {
        state = .loading

        do {
            let collections = try await service.loadCollections()
            try Task.checkCancellation()
            state = .loaded(collections.sorted(by: sortOption.comparator))
        } catch is CancellationError {
            return
        } catch {
            state = .error
            self.error = error
        }
    }
    
    /// Пересортировать текущий набор коллекций (вызывается при смене `sortOption`).
    private func applySortToState() {
        guard case .loaded(let collections) = state else { return }
        state = .loaded(collections.sorted(by: sortOption.comparator))
    }
}
