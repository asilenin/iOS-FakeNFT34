import Foundation

@Observable
@MainActor
final class CatalogViewModel {

    enum LoadState {
        case idle
        case loading
        case loaded([NftCollection])
        case error
    }

    private(set) var state: LoadState = .idle
    var error: Error?

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

    private func applySortToState() {
        guard case .loaded(let collections) = state else { return }
        state = .loaded(collections.sorted(by: sortOption.comparator))
    }
}
