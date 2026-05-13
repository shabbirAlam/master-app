//
//  CountryView.swift
//  MasterApp
//
//  Created by Md Shabbir Alam on 19/04/26.
//

import SwiftUI

enum CountryBuilder {
    static func build() -> CountryView {
        let vm = CountryViewModel(networking: GraphQLNetworkingImpl())
        return CountryView(vm: vm)
    }
}

struct CountryView: View {
    @StateObject var vm: CountryViewModel
    private let themeManager = ThemeManager.shared
    
    init(vm: CountryViewModel) {
        _vm = StateObject(wrappedValue: vm)
    }
    
    var body: some View {
        ZStack {
            themeManager.background.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                TextField("Country...", text: $vm.searchedText)
                    .padding(.horizontal, 16)
                    .frame(height: 40)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                    .padding(.horizontal)
                    .onChange(of: vm.searchedText) { _ in
                        vm.filterCountries()
                    }
                
                if let error = vm.errorMessage {
                    Text(error)
                        .padding()
                } else if vm.countries.isEmpty {
                    Text("No data found")
                        .padding()
                } else {
                    List(vm.countries, id: \.id) { country in
                        VStack {
                            Text(country.name)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text("capital: \(country.capital ?? "")")
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text("code: \(country.code)")
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .foregroundStyle(themeManager.textPrimary)
                        .onTapGesture {
                            Task {
                                await vm.fetchCountry(country)
                            }
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .background(themeManager.background)
                }
                
                if vm.isLoading {
                    ProgressView()
                }
            }
        }
        .task {
            await vm.fetchCountries()
        }
        .navigationTitle("Countries")
    }
}

#Preview {
    let mock = PreviewGraphQLNetworkingMock()
    mock.setData([Country(code: "IN", name: "India", capital: "Delhi")])
    return CountryView(vm: CountryViewModel(networking: mock))
}
