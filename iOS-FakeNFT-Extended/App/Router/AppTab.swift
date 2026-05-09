import SwiftUI

/// Top-level tabs of the app. Order in `allCases` defines the order in the TabBar.
enum AppTab: String, CaseIterable, Hashable, Identifiable {
    case profile
    case catalog
    case cart
    case statistics

    var id: String { rawValue }

    /// Localized label shown under the icon.
    var title: LocalizedStringKey {
        switch self {
        case .profile:    "Tab.profile"
        case .catalog:    "Tab.catalog"
        case .cart:       "Tab.cart"
        case .statistics: "Tab.statistics"
        }
    }

    /// Asset name of the icon for the given selection state.
    func iconName(active: Bool) -> String {
        let suffix = active ? "active" : "inactive"
        switch self {
        case .profile:    return "tab-profile-\(suffix)"
        case .catalog:    return "tab-catalog-\(suffix)"
        case .cart:       return "tab-cart-\(suffix)"
        case .statistics: return "tab-statistics-\(suffix)"
        }
    }
}
