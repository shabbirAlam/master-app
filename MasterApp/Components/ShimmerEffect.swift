import SwiftUI

/// View modifier that overlays an animated-looking shimmer gradient and masks
/// it to the content's shape, producing a loading placeholder effect.
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
    /// Applies a shimmer loading effect to the view.
    /// - Returns: The view with the shimmer overlay applied.
    func shimmer() -> some View {
        modifier(ShimmerModifier())
    }
}

/// A single skeleton list row used as a loading placeholder.
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

/// A scroll-disabled skeleton list of shimmer rows used while content loads.
struct ShimmerList: View {
    /// The number of placeholder rows to display.
    let rowCount: Int

    /// Creates a shimmer list.
    /// - Parameter rowCount: Number of rows (defaults to 8).
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
