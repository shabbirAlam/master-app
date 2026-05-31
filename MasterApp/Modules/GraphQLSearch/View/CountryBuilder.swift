import SwiftUI

enum CountryBuilder {
    static func build() -> CountryView {
        let service = CountryServiceImpl(networking: GraphQLNetworkingImpl())
        let vm = CountryViewModel(service: service)
        return CountryView(vm: vm)
    }
}
