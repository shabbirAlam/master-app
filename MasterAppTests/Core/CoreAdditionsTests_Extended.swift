import Testing
import SwiftUI
import Foundation
import CoreGraphics
@testable import MasterApp

// MARK: - DateFormatters Tests

@MainActor
struct DateFormattersTests {
    @Test func timestampFormatterExists() {
        let formatter = DateFormatters.timestamp
        #expect(formatter.dateStyle == .medium)
        #expect(formatter.timeStyle == .short)
    }

    @Test func timestampFormatterOutput() {
        let formatter = DateFormatters.timestamp
        let date = Date(timeIntervalSince1970: 0)
        let formatted = formatter.string(from: date)
        #expect(!formatted.isEmpty)
    }
}

// MARK: - Todo Codable Tests

@MainActor
struct TodoCodableTests {
    @Test func decode() throws {
        let json = """
        {"userId": 1, "id": 1, "title": "Test Title", "body": "Test Body"}
        """.data(using: .utf8)!
        let todo = try JSONDecoder().decode(Todo.self, from: json)
        #expect(todo.userId == 1)
        #expect(todo.id == 1)
        #expect(todo.title == "Test Title")
        #expect(todo.body == "Test Body")
    }

    @Test func encode() throws {
        let todo = Todo(userId: 1, id: 1, title: "Test", body: "Body")
        let data = try JSONEncoder().encode(todo)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        #expect(json?["userId"] as? Int == 1)
        #expect(json?["id"] as? Int == 1)
        #expect(json?["title"] as? String == "Test")
        #expect(json?["body"] as? String == "Body")
    }

    @Test func customInit() {
        let todo = Todo(userId: 42, id: 99, title: "Custom", body: "Body")
        #expect(todo.userId == 42)
        #expect(todo.id == 99)
        #expect(todo.title == "Custom")
        #expect(todo.body == "Body")
    }
}

// MARK: - Country Codable Tests

@MainActor
struct CountryCodableTests {
    @Test func decode() throws {
        let json = """
        {"code": "IN", "name": "India", "capital": "New Delhi"}
        """.data(using: .utf8)!
        let country = try JSONDecoder().decode(Country.self, from: json)
        #expect(country.code == "IN")
        #expect(country.name == "India")
        #expect(country.capital == "New Delhi")
    }

    @Test func decodeWithNilCapital() throws {
        let json = """
        {"code": "XX", "name": "Unknown", "capital": null}
        """.data(using: .utf8)!
        let country = try JSONDecoder().decode(Country.self, from: json)
        #expect(country.code == "XX")
        #expect(country.name == "Unknown")
        #expect(country.capital == nil)
    }

    @Test func equality() {
        let a = Country(code: "IN", name: "India", capital: "Delhi")
        let b = Country(code: "IN", name: "India", capital: "Delhi")
        let c = Country(code: "US", name: "USA", capital: "DC")
        #expect(a == b)
        #expect(a != c)
    }

    @Test func hashable() {
        let set: Set<Country> = [
            Country(code: "IN", name: "India", capital: "Delhi"),
            Country(code: "US", name: "USA", capital: "DC"),
            Country(code: "IN", name: "India", capital: "Delhi")
        ]
        #expect(set.count == 2)
    }
}

// MARK: - CountriesResponse Tests

@MainActor
struct CountriesResponseTests {
    @Test func decode() throws {
        let json = """
        {"countries": [{"code": "IN", "name": "India", "capital": "Delhi"}]}
        """.data(using: .utf8)!
        let response = try JSONDecoder().decode(CountriesResponse.self, from: json)
        #expect(response.countries.count == 1)
        #expect(response.countries[0].code == "IN")
    }
}

// MARK: - CountryWrapper Tests

@MainActor
struct CountryWrapperTests {
    @Test func decode() throws {
        let json = """
        {"country": {"code": "IN", "name": "India", "capital": "Delhi"}}
        """.data(using: .utf8)!
        let wrapper = try JSONDecoder().decode(CountryWrapper.self, from: json)
        #expect(wrapper.country.code == "IN")
        #expect(wrapper.country.name == "India")
    }
}

// MARK: - SecureContent Tests

@MainActor
struct SecureContentExtendedTests {
    @Test func initialContent() {
        let content = SecureContent(message: "This is secure view")
        #expect(content.message == "This is secure view")
    }

    @Test func customContent() {
        let content = SecureContent(message: "Custom")
        #expect(content.message == "Custom")
    }

    @Test func identifiable() {
        let a = SecureContent(message: "A")
        let b = SecureContent(message: "B")
        #expect(a.id != b.id)
    }

    @Test func hashableComparison() {
        let a = SecureContent(message: "Test")
        let b = SecureContent(message: "Different")
        #expect(a.hashValue != b.hashValue || a.id != b.id)
    }
}

