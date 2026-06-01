import Testing
import SwiftUI
@testable import MasterApp

@MainActor
struct SecureBuilderTests {
    @Test func buildReturnsSecureView() {
        let container = AppDIContainer()
        let view = SecureBuilder.build(container: container)
        #expect(view is SecureView)
    }
}

@MainActor
struct SecureContentTests {
    @Test func viewModelInitialState() {
        let vm = SecureViewModel()
        #expect(vm.content.message == "This is secure view")
    }

    @Test func viewModelCustomContent() {
        let content = SecureContent(message: "Custom message")
        let vm = SecureViewModel(content: content)
        #expect(vm.content.message == "Custom message")
        #expect(vm.content.id == content.id)
    }

    @Test func secureContentIdentifiable() {
        let content1 = SecureContent(message: "A")
        let content2 = SecureContent(message: "B")
        #expect(content1.id != content2.id)
    }

    @Test func secureContentHashable() {
        let content = SecureContent(message: "test")
        let set: Set<SecureContent> = [content]
        #expect(set.contains(content))
    }
}
