import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var router: Router
    @StateObject private var viewModel: HomeViewModel

    init(viewModel: HomeViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ZStack {
            viewModel.theme.background.ignoresSafeArea()

            List(viewModel.items, id: \.self) { item in
                Button {
                    if let route = viewModel.route(for: item) {
                        router.push(route)
                    }
                } label: {
                    HStack {
                        Text(item.name)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundStyle(viewModel.theme.textPrimary)
                        Image(systemName: "chevron.right")
                            .foregroundStyle(viewModel.theme.textPrimary.opacity(0.5))
                    }
                }
                .accessibilityIdentifier(item.name)
                .accessibilityLabel(item.name)
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .accessibilityIdentifier("home_view")
        }
    }
}
