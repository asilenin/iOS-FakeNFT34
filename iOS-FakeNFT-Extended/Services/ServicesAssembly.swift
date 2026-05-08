import Foundation

@Observable
@MainActor
final class ServicesAssembly {

    private let networkClient: NetworkClient

    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }

    // TODO: register services here as epics are implemented
    // (catalog, cart, profile, users, currencies)
}
