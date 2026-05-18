import SwiftUI

// MARK: - REMOVE Before release
///  Usage:
/// Wrap inside a `.toolbar { ToolbarItem(placement: .topBarTrailing) }`
/// when used in a navbar.

struct MenuButton: View {

    // MARK: - Constants

    private enum Constants {
        static let size: CGFloat = 40
    }

    // MARK: - Properties

    let action: () -> Void

    // MARK: - Body

    var body: some View {
        Button(action: action) {
            Image(.menu)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .foregroundStyle(Color.ypBlack)
                .frame(width: Constants.size, height: Constants.size)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text("Common.sort"))
    }
}

#Preview {
    MenuButton(action: {})
}
