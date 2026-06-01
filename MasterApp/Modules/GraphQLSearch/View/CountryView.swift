import SwiftUI

struct CountryView: View {
    @StateObject private var viewModel: CountryViewModel
    private let theme: Theme

    init(viewModel: CountryViewModel, theme: Theme = AppTheme.light) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.theme = theme
    }

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

    private var searchField: some View {
        TextField("Country...", text: $viewModel.searchedText)
            .padding(.horizontal, 16)
            .frame(height: 40)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.gray, lineWidth: 1)
            )
            .padding(.horizontal)
            .accessibilityIdentifier("country_search")
            .onChange(of: viewModel.searchedText) { _ in
                viewModel.filterCountries()
            }
    }

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

    private var shimmerList: some View {
        ShimmerList()
            .accessibilityIdentifier("country_loading")
    }

    private var emptyState: some View {
        VStack {
            Spacer()
            Text("No data found")
                .accessibilityIdentifier("country_empty")
            Spacer()
        }
    }

    private func errorState(_ message: String) -> some View {
        VStack {
            Spacer()
            Text(message)
                .foregroundColor(.red)
                .padding()
                .accessibilityIdentifier("country_error")
            Spacer()
        }
    }
}

private struct CountryRow: View {
    let country: Country
    let theme: Theme
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

#if DEBUG
#Preview {
    let mock = PreviewGraphQLNetworkingMock()
    mock.setData([Country(code: "IN", name: "India", capital: "Delhi")])
    return CountryView(
        viewModel: CountryViewModel(
            service: CountryServiceImpl(repository: CountryRepositoryImpl(networking: mock))
        )
    )
}
#endif
