# agents.md

# Project Overview

This is a modern enterprise-grade iOS application built using:

* Swift 6
* SwiftUI
* MVVM + Clean Architecture
* SOLID Principles
* async/await
* Structured Concurrency
* Modular architecture
* Protocol-oriented programming
* Test-driven engineering practices

Primary engineering goals:

* Scalability
* Maintainability
* Performance
* Reliability
* Testability
* Accessibility
* Security
* Reusability
* Predictable architecture consistency

The codebase should always prioritize long-term maintainability over short-term implementation speed.

---

# Core Engineering Principles

All generated or modified code MUST:

* follow SOLID principles
* follow Apple Human Interface Guidelines
* follow Apple performance best practices
* remain modular and reusable
* be production-ready
* avoid technical debt
* support future scalability
* remain highly testable
* preserve backward compatibility unless explicitly instructed otherwise

Prefer explicit, maintainable, readable code over overly clever implementations.

---

# Architecture

## Primary Architecture

Use:

* MVVM
* Clean Architecture
* Repository Pattern
* Dependency Injection via `AppDIContainer`
* Protocol Abstractions

---

## Dependency Injection Pattern

Use a centralized `AppDIContainer` (`@MainActor final class`) that builds the full dependency graph:

```swift
AppDIContainer
  ├── Networking (NetworkingImpl)
  ├── GraphQLNetworking (GraphQLNetworkingImpl)
  ├── KeyValueStore (InMemoryKeyValueStore)
  ├── Theme (AppTheme)
  ├── Repositories (TodoRepositoryImpl, CountryRepositoryImpl)
  └── Services (TodoServiceImpl, CountryServiceImpl)
```

Rules:
* Container is provided via SwiftUI `EnvironmentKey` (`\.appContainer`)
* Views access dependencies through `@Environment(\.appContainer) var container`
* Builders (`TodoBuilder`, `CountryBuilder`, `SecureBuilder`) receive `container: AppDIContainer`
* Never use singletons or global mutable state for DI
* Container defaults use production implementations for convenience

```swift
// Environment key setup
private struct AppContainerKey: EnvironmentKey {
    static let defaultValue: AppDIContainer = AppDIContainer()
}

extension EnvironmentValues {
    var appContainer: AppDIContainer {
        get { self[AppContainerKey.self] }
        set { self[AppContainerKey.self] }
    }
}
```

---

## Layer Responsibilities

### View

Responsibilities:

* rendering UI
* bindings
* user interaction forwarding
* lightweight state handling only

Rules:

* Views must remain lightweight
* Views must NOT contain business logic
* Views must NOT perform networking
* Views must NOT contain heavy computations
* Large Views must be decomposed into reusable child views
* Separate reusable views into separate files

---

### ViewModel

Responsibilities:

* presentation logic
* state management
* orchestration
* async operations
* UI-ready transformations

Rules:

* ViewModels must be platform-independent where possible
* Avoid UIKit/SwiftUI dependencies inside ViewModels
* Expose immutable state via `@Published private(set)` on state properties
* Avoid massive ViewModels
* All ViewModels MUST be `@MainActor final class: ObservableObject`
* Error state uses a typed `errorMessage: String?` (never expose `Error` directly)
* Use `AppLogger.viewModel` for all ViewModel-level logging

### ViewModel Test Helpers

For snapshot testing and SwiftUI previews, add explicit test-helper methods:

```swift
func setItemsForSnapshot(_ items: [Todo]) {
    self.allItems = items
    self.items = items
}

func setLoadingForSnapshot(_ loading: Bool) {
    self.isLoading = loading
}

func setErrorForSnapshot(_ message: String?) {
    self.errorMessage = message
}
```

These are placed in a `// MARK: - Test Helpers` section and MUST NOT expose setters on `@Published` properties directly.

---

### UseCases / Services

Responsibilities:

* business logic
* orchestration
* domain rules
* feature workflows

Rules:

* Business rules must NOT leak into Views
* Keep domain logic isolated and testable

---

### Repository

Responsibilities:

* networking abstraction
* database abstraction
* caching abstraction
* data source coordination

Rules:

* Repositories must be protocol-driven
* Avoid direct networking calls outside repositories
* Support mocking for tests

---

# Project Structure

Follow this structure strictly:

```text
Modules/
    FeatureA/
        Model/
        View/
        ViewModel/
        Service/
        Repository/

Core/
    Networking/
        Config/
        GraphQL/
    Extensions/
    Utilities/
    DesignSystem/
    DI/
    Storage/
    Logging/
    Navigation/

Components/
Tests/
    Core/
        Network/
    Modules/
    SnapshotTests/
Resources/
```

Each feature should remain isolated and modular.

Key conventions:

* Each feature has its own `Repository/` folder with a protocol and `Impl` class
* Services hold business logic and take repositories via constructor injection
* ViewModels receive services via constructor injection (no direct repository access)
* Views receive ViewModel and Theme via init parameters
* Builders assemble features: `static func build(container:) -> SomeView`
* All Core cross-cutting concerns live in `Core/`: logging, networking, storage, design, DI, navigation
* Test files mirror the source structure under `Tests/`
* Snapshot tests live in `Tests/SnapshotTests/`

---

# SwiftUI Rules

## General Rules

* Keep body implementations small and composable
* Prefer composition over inheritance
* Extract reusable UI components aggressively
* Prefer immutable data flow
* Support Dynamic Type
* Support Dark Mode
* Support accessibility

---

## State Management

Use:

* @State
* @Binding
* @StateObject
* @ObservedObject
* @EnvironmentObject only when truly necessary

Rules:

* Use @StateObject only for owned lifecycle
* Use @ObservedObject for injected dependencies
* Avoid deeply nested state propagation
* Avoid duplicate sources of truth

---

## Performance Rules

Avoid:

* unnecessary re-renders
* heavy computations inside body
* excessive AnyView usage
* deeply nested view hierarchies
* blocking the main thread

Prefer:

* LazyVStack
* LazyHStack
* EquatableView where appropriate
* memoized computations when needed

---

# Swift Concurrency Rules

Use:

* async/await
* structured concurrency
* Task
* actors where appropriate

Avoid:

* callback-based APIs
* completion-handler pyramids
* unnecessary DispatchQueue.main.async
* detached tasks unless absolutely necessary

---

## Cancellation

Long-running operations MUST support cancellation.

Always check cancellation for:

* streaming
* uploads/downloads
* search
* polling
* AI/network requests

Example:

```swift id="ivnl2u"
try Task.checkCancellation()
```

---

## Thread Safety

* UI updates MUST occur on MainActor
* Shared mutable state should use actors where appropriate
* Avoid data races
* Respect Swift 6 strict concurrency

---

# Dependency Injection

Use constructor injection by default.

Example:

```swift
init(repository: UserRepositoryProtocol)
```

For feature module assembly, use static builder methods that accept `AppDIContainer`:

```swift
static func build(container: AppDIContainer = AppDIContainer()) -> SomeView
```

Avoid:

* hidden dependencies
* hardcoded singletons
* global mutable state

The central DI container (`AppDIContainer`) wires all dependencies:

```swift
let container = AppDIContainer()
container.todoService   // returns TodoServiceImpl wired with NetworkingImpl
container.countryService // returns CountryServiceImpl wired with GraphQLNetworkingImpl
```

---

# Networking Standards

Use:

* URLSession
* async/await
* Codable
* typed errors
* protocol abstractions

Requirements:

* proper error handling
* retry support where appropriate
* timeout handling
* request cancellation
* secure headers
* response validation

Avoid:

* force casts
* loosely typed networking
* business logic inside networking layer

---

# Error Handling

Use:

* typed errors
* domain-specific errors (e.g., `NetworkError`)
* recoverable UI states

The app defines a `NetworkError` enum with typed cases:

```swift
enum NetworkError: LocalizedError, Equatable {
    case unknown
    case invalidURL
    case decodingError
    case encodingError
    case invalidResponse
    case badStatusCode(Int)
}
```

Avoid:

```swift
fatalError()
try!
force unwraps
```

Errors should:

* provide actionable debugging information
* preserve user experience
* avoid app crashes

---

# Testing Standards

## Coverage Requirements

* Minimum test coverage: 90%
* All new code MUST include tests where applicable

---

## Required Test Types

### Unit Tests

Focus on:

* ViewModels
* repositories
* UseCases
* async flows
* edge cases
* failure handling

All ViewModel tests MUST be annotated `@MainActor` and use `@Test` macros from Swift Testing.

Mocks for repository protocols use `@MainActor final class` with private state:

```swift
@MainActor
final class MockTodoRepository: TodoRepository {
    private var mockData: [Todo]?
    private var mockError: Error?
    ...
}
```

---

### UI Tests

Cover:

* navigation flows
* user journeys
* accessibility identifiers
* critical interactions

Use `XCTest` for UI tests (compatibility with XCUIApplication).

---

### Snapshot Tests

Use where appropriate for:

* reusable UI components
* design validation
* regression prevention

Snapshot tests use `SnapshotTesting` library with Swift Testing and `@MainActor struct`:

```swift
let record: SnapshotTestingConfiguration.Record = .never // .all to re-record

func test_todoView_withData() {
    let vm = TodoViewModel(...)
    vm.setItemsForSnapshot([...])
    let view = TodoView(viewModel: vm, theme: AppTheme.light)
    assertSnapshot(of: view, as: ...)
}
```

Use `.never` in committed code and `.all` when intentionally re-recording baselines.

---

## Testing Rules

* Tests must be deterministic
* Avoid flaky async tests
* Use protocol mocks
* Prefer isolated testing
* Avoid testing SwiftUI internals directly
* All test structs/test classes must be `@MainActor` when ViewModel is `@MainActor`

---

# Accessibility

All generated UI must:

* support VoiceOver
* support Dynamic Type
* use accessibility labels
* use accessibility identifiers for UI tests
* maintain sufficient contrast

Accessibility is NOT optional.

---

# Security Rules

Never:

* hardcode API keys
* expose secrets
* log sensitive user data
* store tokens insecurely

Use:

* Keychain
* secure storage
* backend token exchange
* HTTPS only

Sensitive data must never appear in logs.

---

# Logging & Analytics

Use structured logging via OSLog (`Logger`).

Never use `print()` in production code.

## AppLogger Usage

Use the categorized `AppLogger` enum:

```swift
AppLogger.network.error("...")
AppLogger.repository.info("...")
AppLogger.service.debug("...")
AppLogger.viewModel.warning("...")
AppLogger.view.info("...")
AppLogger.auth.notice("...")
AppLogger.secure.notice("...")
AppLogger.app.error("...")
```

All files using `AppLogger` must add `import os`.

Use privacy annotations for interpolated values:

```swift
AppLogger.viewModel.error("Error: \(error.localizedDescription, privacy: .public)")
```

Logs should:

* be meaningful
* avoid PII (mark as `privacy: .private` for user data)
* support debugging
* support observability

---

# Performance Requirements

Always optimize for:

* launch time
* memory usage
* scroll performance
* battery efficiency
* networking efficiency

Avoid:

* unnecessary allocations
* retain cycles
* excessive state updates
* blocking operations

Use Instruments when performance-sensitive code changes occur.

---

# AI Agent Instructions

When generating code:

* preserve architecture consistency
* preserve modularity
* avoid unrelated refactors
* maintain naming consistency
* generate production-grade code
* generate testable code
* prefer reusable abstractions
* maintain Swift 6 compatibility
* always use new modern swift syntax
* preserve public APIs unless explicitly instructed otherwise

---

# Import Rules

Always add the correct module imports for each file type:

* **ViewModels**: `import Combine` (for `@Published`), `import os` (for `AppLogger`), `import Foundation`
* **Views**: `import SwiftUI`, `import os` (if using `AppLogger.view`)
* **Services**: `import Foundation`, `import os`
* **Repositories**: `import Foundation`, `import os`
* **Networking**: `import Foundation`, `import os`
* **Tests**: `import Testing`, `@testable import MasterApp`; add `import Foundation` if using Data/JSON, `import SwiftUI` if constructing views
* **Snapshot Tests**: `import Testing`, `import SnapshotTesting`, `import SwiftUI`, `@testable import MasterApp`

---

# AI Code Generation Rules

Always:

* generate compile-safe code
* generate concurrency-safe code
* generate testable code
* generate scalable code
* follow Apple best practices
* prefer protocol abstractions
* prefer value types where appropriate

Avoid:

* overengineering
* unnecessary dependencies
* giant files
* force unwraps
* hidden side effects

---

# Post-Implementation Validation

After completing changes ALWAYS:

1. Ensure project compiles successfully
2. Run impacted tests
3. Verify no concurrency warnings
4. Verify no memory leaks introduced
5. Verify accessibility compatibility
6. Verify SwiftUI previews compile if applicable
7. Run application in simulator
8. Verify new functionality manually
9. Ensure linting/style consistency
10. Ensure no unrelated files were modified

---

# Git & PR Standards

Commits should:

* remain focused
* avoid mixing unrelated changes
* preserve clean git history

Preferred commit style:

```text id="o9plb8"
Add streaming support for AI chat responses
Fix actor isolation issue in repository layer
Refactor payment flow ViewModel into modular components
```

---

# Code Style

* Prefer clarity over brevity
* One primary type per file
* Prefer explicit naming
* Avoid abbreviations
* Keep functions focused
* Keep files maintainable in size
* Avoid deep nesting

---

# Design System

Prefer reusable:

* typography
* spacing
* colors
* buttons
* loaders
* error states

Avoid hardcoded styling values where possible.

---

# Memory Management

Avoid:

* retain cycles
* strong self captures
* leaking Tasks

Always review:

* async closures
* Combine subscriptions
* Task lifecycles

---

# Forbidden Practices

Never:

* use force unwraps in production code
* introduce hidden side effects
* add unrelated refactors
* bypass architecture layers
* duplicate business logic
* ignore compiler warnings
* suppress errors silently
* add unnecessary dependencies

---

# Definition of Done

A feature is NOT complete until:

* code compiles
* tests pass
* accessibility validated
* architecture preserved
* edge cases handled
* concurrency safety verified
* performance considered
* manual validation completed
* no major warnings remain
* code is production-ready
