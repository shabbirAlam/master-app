import SwiftUI

/// Screen listing countries fetched via GraphQL with search filtering,
/// shimmer loading, empty, and error states.
struct CountryView: View {
    /// Presentation state for the screen.
    @State private var viewModel: CountryViewModel
    /// The active design-system theme.
    private let theme: Theme

    /// Creates the view.
    /// - Parameters:
    ///   - viewModel: The injected view model.
    ///   - theme: The theme used for styling.
    init(viewModel: CountryViewModel, theme: Theme) {
        self.viewModel = viewModel
        self.theme = theme
    }

    /// Renders the screen and kicks off the initial country fetch.
    var body: some View {
        ZStack {
            theme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                searchField
                    .padding(.vertical, 8)

                content
            }
        }
        .task {
            await viewModel.fetchCountries()
        }
        .navigationTitle("Countries")
    }

    /// Switches between error, loading, empty, and list states.
    @ViewBuilder
    private var content: some View {
        if let error = viewModel.errorMessage {
            errorState(error)
        } else if viewModel.isLoading {
            shimmerList
        } else if viewModel.filteredCountries.isEmpty {
            emptyState
        } else {
            listView
        }
    }

    /// The search text field bound to the view model's query.
    private var searchField: some View {
        TextField("Country...", text: $viewModel.searchedText)
            .foregroundStyle(theme.textPrimary)
            .tint(theme.accent)
            .padding(.horizontal, 16)
            .frame(height: 40)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(theme.accent.opacity(0.3), lineWidth: 1)
            )
            .padding(.horizontal)
            .accessibilityIdentifier("country_search")
            .onChange(of: viewModel.searchedText) {
                viewModel.filterCountries()
            }
    }

    /// The scrollable list of filtered countries.
    private var listView: some View {
        List(viewModel.filteredCountries) { country in
            CountryRow(country: country, theme: theme) {
                Task {
                    await viewModel.fetchCountry(country)
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(theme.background)
        .accessibilityIdentifier("country_list")
    }

    /// Skeleton placeholder rows shown while loading.
    private var shimmerList: some View {
        ShimmerList()
            .accessibilityIdentifier("country_loading")
    }

    /// Placeholder shown when no countries match the search.
    private var emptyState: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "globe")
                .font(.title2)
                .foregroundStyle(theme.textPrimary.opacity(0.4))
            Text("No data found")
                .foregroundStyle(theme.textPrimary.opacity(0.6))
                .accessibilityIdentifier("country_empty")
            Spacer()
        }
    }

    /// Full-screen error state with the given message.
    private func errorState(_ message: String) -> some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "exclamationmark.triangle")
                .font(.title2)
                .foregroundStyle(theme.accent)
            Text(message)
                .foregroundStyle(theme.accent)
                .padding()
                .accessibilityIdentifier("country_error")
            Spacer()
        }
    }
}

/// A single tappable row displaying a country's name, capital, and code.
private struct CountryRow: View {
    /// The country to display.
    let country: Country
    /// The active theme.
    let theme: Theme
    /// Action invoked when the row is tapped.
    let onTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(country.name)
                .frame(maxWidth: .infinity, alignment: .leading)
            if let capital = country.capital {
                Text("capital: \(capital)")
                    .font(.subheadline)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            Text("code: \(country.code)")
                .font(.subheadline)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .foregroundStyle(theme.textPrimary)
        .accessibilityIdentifier("country_row_\(country.code)")
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
    }
}

#Preview {
    let mock = PreviewGraphQLNetworkingMock()
    mock.setData([Country(code: "IN", name: "India", capital: "Delhi")])
    return CountryView(
        viewModel: CountryViewModel(
            service: CountryServiceImpl(repository: CountryRepositoryImpl(networking: mock))
        ),
        theme: AppTheme.light
    )
}
