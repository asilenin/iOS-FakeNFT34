import SwiftUI

struct LoadingSpinner: View {

    enum Size {
        case small   // 20pt — for cell-level placeholders (NFT thumbnail)
        case medium  // 30pt — default for "loading inside a card"
        case large   // 50pt — full-screen loaders
    }

    var size: Size = .medium
    var tint: Color = .ypBlack

    var body: some View {
        ProgressView()
            .progressViewStyle(.circular)
            .tint(tint)
            .scaleEffect(scale)
            .frame(width: pointSize, height: pointSize)
    }

    private var pointSize: CGFloat {
        switch size {
        case .small:  20
        case .medium: 30
        case .large:  50
        }
    }

    /// `ProgressView` renders at ~20pt natively. We scale it up for
    /// `medium` and `large` so the rays match the Figma sizes.
    private var scale: CGFloat {
        pointSize / 20
    }
}

#Preview("Variants") {
    HStack(spacing: 24) {
        LoadingSpinner(size: .small)
        LoadingSpinner(size: .medium)
        LoadingSpinner(size: .large)
    }
    .padding()
}

#Preview("On dark background") {
    ZStack {
        Color.ypBlackUniversal.ignoresSafeArea()
        LoadingSpinner(size: .large, tint: .ypWhiteUniversal)
    }
}
