import Foundation

/// Top-level tabs of the app. Order in `allCases` defines the order in the TabBar.
enum AppTab: String, CaseIterable, Hashable, Identifiable {
    case profile
    case catalog
    case cart
    case statistics

    var id: String { rawValue }
}
