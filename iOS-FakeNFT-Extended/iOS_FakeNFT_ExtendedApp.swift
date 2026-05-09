import SwiftUI

@main
struct iOS_FakeNFT_ExtendedApp: App {

    @State private var router = Router()
    @State private var services = ServicesAssembly(networkClient: DefaultNetworkClient())

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(router)
                .environment(services)
        }
    }
}
