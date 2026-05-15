import SwiftUI

// MARK: - REMOVE Before release
///  Usage:
/// Wrap inside a `.toolbar { ToolbarItem(placement: .topBarTrailing) }`
/// when used in a navbar.

struct MenuButton: View {

    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(.menu)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .foregroundStyle(Color.ypBlack)
                .frame(width: 40, height: 40)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text("Common.sort"))
    }
}

#Preview {
    MenuButton(action: {})
}
