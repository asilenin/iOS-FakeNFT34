import SwiftUI

struct CustomTabBar: View {

    @Binding var selection: AppTab

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            ForEach(AppTab.allCases) { tab in
                TabBarItem(
                    tab: tab,
                    isActive: tab == selection,
                    action: { selection = tab }
                )
            }
        }
        .padding(.top, 8)
        .background(Color.ypWhite)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(Color.ypGrayLight)
                .frame(height: 0.5)
        }
    }
}

#Preview {
    @Previewable @State var selection: AppTab = .catalog
    return VStack {
        Spacer()
        CustomTabBar(selection: $selection)
    }
}
