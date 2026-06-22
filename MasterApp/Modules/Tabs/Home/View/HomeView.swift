import SwiftUI

struct HomeView: View {
    @Environment(Router.self) private var router
    @State private var viewModel: HomeViewModel

    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                headerSection
                featuresGrid
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 32)
        }
        .background(viewModel.theme.background.ignoresSafeArea())
        .accessibilityIdentifier("home_view")
    }

    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "square.grid.2x2")
                .font(.system(size: 36, weight: .light))
                .foregroundStyle(viewModel.theme.accent)
                .symbolVariant(.fill)
                .symbolRenderingMode(.hierarchical)

            Text("Master App")
                .font(.largeTitle.weight(.bold))
                .foregroundStyle(viewModel.theme.textPrimary)

            Text("Explore features and tools")
                .font(.subheadline)
                .foregroundStyle(viewModel.theme.textPrimary.opacity(0.6))
        }
        .padding(.top, 40)
        .padding(.bottom, 8)
    }

    private var featuresGrid: some View {
        VStack(spacing: 16) {
            ForEach(viewModel.items, id: \.self) { item in
                featureCard(for: item)
            }
        }
    }

    private func featureCard(for item: HomeFeatures) -> some View {
        Button {
            if let route = viewModel.route(for: item) {
                router.push(route)
            }
        } label: {
            HStack(spacing: 16) {
                iconCircle(for: item)

                VStack(alignment: .leading, spacing: 4) {
                    Text(item.name)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(viewModel.theme.textPrimary)

                    Text(item.description)
                        .font(.caption)
                        .foregroundStyle(viewModel.theme.textPrimary.opacity(0.6))
                        .lineLimit(2)
                }

                Spacer(minLength: 8)

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(viewModel.theme.accent.opacity(0.6))
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(viewModel.theme.background)
                    .shadow(color: .black.opacity(0.06), radius: 8, y: 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(viewModel.theme.accent.opacity(0.15), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(item.name)
        .accessibilityLabel("\(item.name): \(item.description)")
    }

    private func iconCircle(for item: HomeFeatures) -> some View {
        ZStack {
            Circle()
                .fill(viewModel.theme.accent.opacity(0.12))
                .frame(width: 48, height: 48)

            Image(systemName: item.iconName)
                .font(.title3)
                .foregroundStyle(viewModel.theme.accent)
        }
    }
}
