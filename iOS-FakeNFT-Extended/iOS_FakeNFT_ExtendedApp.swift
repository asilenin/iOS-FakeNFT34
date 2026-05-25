import SwiftUI

@main
struct iOS_FakeNFT_ExtendedApp: App {

    @State private var router = Router()
    @State private var services = ServicesAssembly(networkClient: DefaultNetworkClient())

    init() {
    }

    var body: some Scene {
        WindowGroup {
            TabBarView()
                .environment(router)
                .environment(services)
        }
    }
}
