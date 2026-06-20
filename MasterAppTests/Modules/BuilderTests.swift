import Testing
import SwiftUI
@testable import MasterApp

@MainActor
struct TodoBuilderTests {
    @Test func buildReturnsTodoView() {
        let container = AppDIContainer()
        let view = TodoBuilder.build(container: container)
        #expect(view is TodoView)
    }
}

@MainActor
struct CountryBuilderTests {
    @Test func buildReturnsCountryView() {
        let container = AppDIContainer()
        let view = CountryBuilder.build(container: container)
        #expect(view is CountryView)
    }
}

@MainActor
struct ChessBuilderTests {
    @Test func buildReturnsChessView() {
        let container = AppDIContainer()
        let view = ChessBuilder.build(container: container)
        #expect(view is ChessView)
    }
}

