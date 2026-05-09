import XCTest

final class TabBarUITests: XCTestCase {

    func test_appLaunches_andTabsAreTappable() {
        let app = XCUIApplication()
        app.launch()

        let tabs = ["Профиль", "Каталог", "Корзина", "Статистика"]
        for tab in tabs {
            let button = app.buttons[tab]
            XCTAssertTrue(
                button.waitForExistence(timeout: 2),
                "Tab '\(tab)' is missing from the TabBar"
            )
            button.tap()
            XCTAssertTrue(button.exists, "Tab '\(tab)' disappeared after tapping it")
        }
    }
}
