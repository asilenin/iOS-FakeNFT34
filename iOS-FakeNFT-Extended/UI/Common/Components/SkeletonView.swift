import SwiftUI

// MARK: - REMOVE Before release
///  Usage:
///  KFImage(url)
///    .placeholder { SkeletonView() }  // ← вот он, скелетон
///    .resizable()
///    .aspectRatio(contentMode: .fill)

struct SkeletonView: View {

    var cornerRadius: CGFloat = 12

    @State private var phase: CGFloat = -1

    var body: some View {
        GeometryReader { geo in
            base
                .overlay {
                    shimmer
                        .offset(x: geo.size.width * phase)
                        .blendMode(.plusLighter)
                }
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        }
        .onAppear {
            withAnimation(
                .linear(duration: 1.4).repeatForever(autoreverses: false)
            ) {
                phase = 1
            }
        }
    }

    private var base: some View {
        Color.ypGrayLight
    }

    private var shimmer: some View {
        LinearGradient(
            colors: [
                Color.white.opacity(0),
                Color.white.opacity(0.4),
                Color.white.opacity(0)
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}

#Preview("Sizes") {
    VStack(spacing: 16) {
        SkeletonView()
            .frame(width: 160, height: 160)

        SkeletonView(cornerRadius: 8)
            .frame(width: 240, height: 80)

        SkeletonView(cornerRadius: 4)
            .frame(width: 200, height: 16)
    }
    .padding()
}

#Preview("On dark background") {
    ZStack {
        Color.ypBlackUniversal.ignoresSafeArea()
        SkeletonView()
            .frame(width: 200, height: 200)
    }
}
