import SwiftUI

@Observable
@MainActor
final class Router {

    // MARK: - State

    /// The tab currently displayed in the TabBar.
    var selectedTab: AppTab = .catalog

    /// Navigation stack for the Catalog tab.
    var catalogPath = NavigationPath()

    /// Navigation stack for the Cart tab.
    var cartPath = NavigationPath()

    /// Navigation stack for the Profile tab.
    var profilePath = NavigationPath()

    /// Navigation stack for the Statistics tab.
    var statisticsPath = NavigationPath()

    // MARK: - Init

    init() {}

    // MARK: - Tab switching

    /// Programmatically switch to a tab. Useful for cross-tab actions  (e.g. "go to Catalog after successful payment").
    func switchTo(_ tab: AppTab) {
        selectedTab = tab
    }

    // MARK: - Stack manipulation

    /// Push a route onto the given tab's stack.
    func push<R: Hashable>(_ route: R, in tab: AppTab) {
        switch tab {
        case .catalog:    catalogPath.append(route)
        case .cart:       cartPath.append(route)
        case .profile:    profilePath.append(route)
        case .statistics: statisticsPath.append(route)
        }
    }

    /// Pop the topmost route from the given tab's stack.
    func pop(in tab: AppTab) {
        switch tab {
        case .catalog    where !catalogPath.isEmpty:    catalogPath.removeLast()
        case .cart       where !cartPath.isEmpty:       cartPath.removeLast()
        case .profile    where !profilePath.isEmpty:    profilePath.removeLast()
        case .statistics where !statisticsPath.isEmpty: statisticsPath.removeLast()
        default: break
        }
    }

    /// Reset the given tab's stack to its root.
    func popToRoot(in tab: AppTab) {
        switch tab {
        case .catalog:    catalogPath = NavigationPath()
        case .cart:       cartPath = NavigationPath()
        case .profile:    profilePath = NavigationPath()
        case .statistics: statisticsPath = NavigationPath()
        }
    }
}
