import Testing
import Foundation
@testable import MasterApp

// MARK: - TodoRepository Tests

@MainActor
struct TodoRepositoryTests {
    @Test func fetchTodosUsesNetworking() async throws {
        let networking = PreviewNetworkingMock()
        let todos = [Todo(userId: 1, id: 1, title: "Test", body: "Body")]
        let data = try JSONEncoder().encode(todos)
        networking.setData(data)

        let repository = TodoRepositoryImpl(networking: networking)
        let result = try await repository.fetchTodos()

        #expect(result.count == 1)
        #expect(result[0].title == "Test")
    }

    @Test func fetchTodosNetworkError() async {
        let networking = PreviewNetworkingMock()
        networking.setError(NetworkError.unknown)

        let repository = TodoRepositoryImpl(networking: networking)

        do {
            let _ = try await repository.fetchTodos()
            Issue.record("Expected error")
        } catch {
            #expect(error is NetworkError)
        }
    }
}

// MARK: - CountryRepository Tests

@MainActor
struct CountryRepositoryTests {
    @Test func fetchCountriesUsesGraphQL() async throws {
        let networking = PreviewGraphQLNetworkingMock()
        let jsonData = """
        {"countries": [{"code": "IN", "name": "India", "capital": "Delhi"}]}
        """.data(using: .utf8)!
        networking.setData(jsonData)

        let repository = CountryRepositoryImpl(networking: networking)
        let result = try await repository.fetchCountries()

        #expect(result.count == 1)
        #expect(result[0].name == "India")
    }

    @Test func fetchCountryUsesGraphQL() async throws {
        let networking = PreviewGraphQLNetworkingMock()
        let jsonData = """
        {"country": {"code": "IN", "name": "India", "capital": "Delhi"}}
        """.data(using: .utf8)!
        networking.setData(jsonData)

        let repository = CountryRepositoryImpl(networking: networking)
        let result = try await repository.fetchCountry(for: "IN")

        #expect(result.code == "IN")
        #expect(result.name == "India")
    }

}

// MARK: - ChessRatingStore Tests

@MainActor
struct ChessRatingStoreTests {
    @Test func inMemoryStoreLoadsProfile() {
        let profile = ChessRatingProfile(userRating: 800, computerRating: 1_200)
        let store = InMemoryChessRatingStore(profile: profile)

        let loaded = store.loadProfile()
        #expect(loaded.userRating == 800)
        #expect(loaded.computerRating == 1_200)
    }

    @Test func inMemoryStoreSavesProfile() {
        let store = InMemoryChessRatingStore()
        let newProfile = ChessRatingProfile(userRating: 1_000, computerRating: 1_500)

        store.saveProfile(newProfile)
        let loaded = store.loadProfile()
        #expect(loaded.userRating == 1_000)
        #expect(loaded.computerRating == 1_500)
    }

    @Test func inMemoryStoreDefaultProfile() {
        let store = InMemoryChessRatingStore()
        let loaded = store.loadProfile()
        #expect(loaded.userRating == 600)
        #expect(loaded.computerRating == 600)
    }
}

// MARK: - GraphQLNetworking Mock Tests

@MainActor
struct GraphQLRequestConstructionTests {
    @Test func requestWithEmptyVariables() throws {
        let request = GraphQLRequest(query: "query { test }", variables: [:])
        let data = try JSONEncoder().encode(request)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        #expect(json?["query"] as? String == "query { test }")
    }
}

// MARK: - HTTPMethod Tests

@MainActor
struct HTTPMethodTests {
    @Test func allMethods() {
        #expect(HTTPMethod.GET.rawValue == "GET")
        #expect(HTTPMethod.POST.rawValue == "POST")
        #expect(HTTPMethod.PUT.rawValue == "PUT")
        #expect(HTTPMethod.DELETE.rawValue == "DELETE")
        #expect(HTTPMethod.PATCH.rawValue == "PATCH")
    }

    @Test func equality() {
        #expect(HTTPMethod.GET == HTTPMethod.GET)
        #expect(HTTPMethod.GET != HTTPMethod.POST)
    }
}