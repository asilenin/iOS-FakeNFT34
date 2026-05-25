import XCTest
@testable import iOS_FakeNFT_Extended

@MainActor
final class PaymentViewModelTests: XCTestCase {

    private func makeCurrency(id: String = "BTC") -> PaymentCurrency {
        PaymentCurrency(id: id, title: "Bitcoin", name: "BTC", imageURL: nil)
    }

    func test_pay_successFlow_setsSuccessState() async {
        let viewModel = PaymentViewModel()
        let payment = StubPaymentService()
        let cart = OrderTrackingCartService(initial: ["nft-1", "nft-2"])
        let profile = InvalidationTrackingProfileService()

        viewModel.select(makeCurrency())
        await viewModel.pay(paymentService: payment, cartService: cart, profileService: profile)

        XCTAssertEqual(viewModel.state, .success)
        XCTAssertNil(viewModel.error)
        XCTAssertFalse(viewModel.isPaying)
    }

    func test_pay_followsCorrectOrder() async {
        let viewModel = PaymentViewModel()
        let payment = StubPaymentService()
        let cart = OrderTrackingCartService(initial: ["nft-1", "nft-2"])
        let profile = InvalidationTrackingProfileService()

        viewModel.select(makeCurrency())
        await viewModel.pay(paymentService: payment, cartService: cart, profileService: profile)

        let events = await cart.events
        // loadCart → performOrder(купленные) → setCart(пусто)
        XCTAssertEqual(events.first, "loadCart")
        XCTAssertTrue(events.contains("performOrder(nft-1,nft-2)"))
        XCTAssertTrue(events.contains("setCart()"), "Cart must be cleared with empty set")
        // performOrder раньше setCart
        let orderIdx = events.firstIndex(of: "performOrder(nft-1,nft-2)")!
        let clearIdx = events.firstIndex(of: "setCart()")!
        XCTAssertLessThan(orderIdx, clearIdx)
    }

    func test_pay_invalidatesProfileCache() async {
        let viewModel = PaymentViewModel()
        let payment = StubPaymentService()
        let cart = OrderTrackingCartService(initial: ["nft-1"])
        let profile = InvalidationTrackingProfileService()

        viewModel.select(makeCurrency())
        await viewModel.pay(paymentService: payment, cartService: cart, profileService: profile)

        let invalidated = await profile.invalidateCalled
        XCTAssertTrue(invalidated, "Profile cache must be invalidated after purchase")
    }

    func test_pay_paymentError_doesNotClearCartOrSucceed() async {
        let viewModel = PaymentViewModel()
        let payment = StubPaymentService()
        await payment.setPayError(PaymentServiceError.unsuccessfulPayment)
        let cart = OrderTrackingCartService(initial: ["nft-1"])
        let profile = InvalidationTrackingProfileService()

        viewModel.select(makeCurrency())
        await viewModel.pay(paymentService: payment, cartService: cart, profileService: profile)

        XCTAssertNotEqual(viewModel.state, .success)
        XCTAssertNotNil(viewModel.error)
        let events = await cart.events
        XCTAssertFalse(events.contains("setCart()"), "Cart must NOT be cleared on payment failure")
        let invalidated = await profile.invalidateCalled
        XCTAssertFalse(invalidated, "Profile cache must NOT be invalidated on failure")
    }

    func test_pay_withoutSelectedCurrency_doesNothing() async {
        let viewModel = PaymentViewModel()
        let payment = StubPaymentService()
        let cart = OrderTrackingCartService(initial: ["nft-1"])
        let profile = InvalidationTrackingProfileService()

        // не выбираем валюту
        await viewModel.pay(paymentService: payment, cartService: cart, profileService: profile)

        XCTAssertNotEqual(viewModel.state, .success)
        let events = await cart.events
        XCTAssertTrue(events.isEmpty, "Nothing should happen without selected currency")
    }
}
