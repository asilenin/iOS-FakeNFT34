import SwiftUI

/// Состояние пустого экрана для эпика "Каталог".
///
/// Отображает центрированный текст по макету "Корзина пуста" / "Нет NFT".
/// Используется при `state == .error` в `CatalogView` и `CollectionDetailView`,
/// в дополнение к `errorAlert` — даёт пользователю понятный путь после закрытия алерта.
struct CatalogEmptyStateView: View {

    let message: LocalizedStringKey

    var body: some View {
        Text(message)
            .font(.bold17)
            .foregroundStyle(Color.ypBlack)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 32)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    CatalogEmptyStateView(message: "Catalog.loadErrorHint")
}
