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
            state = .loaded(collections)
        } catch is CancellationError {
            return
        } catch {
            state = .error
            self.error = error
        }
    }
}
