import SwiftUI

struct WebViewScreen: View {

    let url: URL

    @State private var isLoading = false
    @State private var progress: Double = 0

    var body: some View {
        WebViewRepresentable(
            url: url,
            isLoading: $isLoading,
            progress: $progress
        )
        .overlay(alignment: .top) {
            if isLoading {
                ProgressView(value: progress)
                    .progressViewStyle(.linear)
                    .tint(Color.ypBlueUniversal)
                    .background(Color.ypGrayLight)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        WebViewScreen(url: URL(string: "https://practicum.yandex.ru")!)
    }
}
