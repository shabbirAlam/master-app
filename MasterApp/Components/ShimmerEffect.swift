import SwiftUI

struct ShimmerModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    LinearGradient(
                        gradient: Gradient(colors: [
                            .clear,
                            .white.opacity(0.35),
                            .clear
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geometry.size.width * 0.5)
                    .offset(x: geometry.size.width * 0.25)
                    .blur(radius: 16)
                }
            )
            .mask(content)
    }
}

extension View {
    func shimmer() -> some View {
        modifier(ShimmerModifier())
    }
}

struct ShimmerRow: View {
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.25))
                    .frame(height: 16)
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
            Divider()
        }
        .shimmer()
    }
}

struct ShimmerList: View {
    let rowCount: Int

    init(rowCount: Int = 8) {
        self.rowCount = rowCount
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(0..<rowCount, id: \.self) { _ in
                    ShimmerRow()
                }
            }
        }
        .scrollDisabled(true)
    }
}
