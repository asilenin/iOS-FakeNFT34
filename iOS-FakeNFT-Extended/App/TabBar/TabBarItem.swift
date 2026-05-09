import SwiftUI

struct TabBarItem: View {

    let tab: AppTab
    let isActive: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 0) {
                icon
                    .frame(width: iconSize, height: iconSize)

                Text(tab.title)
                    .font(.medium10)
                    .foregroundStyle(isActive ? Color.ypBlueUniversal : Color.ypBlack)
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(tab.title)
        .accessibilityAddTraits(isActive ? [.isSelected] : [])
    }

    @ViewBuilder
    private var icon: some View {
        if isActive {
            Image(tab.iconName(active: true))
                .resizable()
                .renderingMode(.original)
        } else {
            Image(tab.iconName(active: false))
                .resizable()
                .renderingMode(.template)
                .foregroundStyle(Color.ypBlack)
        }
    }

    private let iconSize: CGFloat = 30
}
