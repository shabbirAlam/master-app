# Repository Guidelines

## Project Overview
This repository contains a Swift 6 iOS app built with SwiftUI, MVVM, Clean Architecture, async/await, structured concurrency, protocol-oriented design, and test-driven engineering practices. Prioritize long-term maintainability, accessibility, reliability, security, and predictable architecture over short-term implementation speed.

## Project Structure & Module Organization
Source code lives in `MasterApp/`. Shared cross-cutting code belongs in `MasterApp/Core/`, reusable UI in `MasterApp/Components/`, and feature code in `MasterApp/Modules/<Feature>/`.

Each feature should stay isolated and follow the existing folder pattern:

```text
MasterApp/Modules/<Feature>/
    Model/
    View/
    ViewModel/
    Service/
    Repository/
```

Tests mirror the app structure in `MasterAppTests/` and `MasterAppUITests/`. Snapshot tests and baselines live in `MasterAppTests/SnapshotTests/` and `MasterAppTests/SnapshotTests/__Snapshots__/`.

## Build, Test, and Development Commands
Use the shared Xcode schemes in `MasterApp.xcodeproj/xcshareddata/xcschemes/`.

- `xcodebuild -scheme MasterApp -project MasterApp.xcodeproj build` builds the app.
- `xcodebuild -scheme MasterAppTests -project MasterApp.xcodeproj test` runs unit and snapshot tests.
- `xcodebuild -scheme MasterAppUITests -project MasterApp.xcodeproj test` runs UI tests.

When practical, build first, then run the most relevant test target. Use `MasterApp.xctestplan` for coverage-aware validation.

## Architecture Rules
Use MVVM + Clean Architecture with Repository and Service layers. Views render UI and forward user actions only. ViewModels own presentation state and orchestration. Services contain business workflows. Repositories coordinate networking, persistence, and data sources.

Use constructor injection by default. Wire dependencies through `AppDIContainer`; do not introduce singletons or global mutable state. Builders such as `TodoBuilder`, `CountryBuilder`, and feature-specific builders should receive or resolve dependencies from the container and return `some View`.

Do not bypass layers. Views must not call networking directly, repositories must not contain UI logic, and business rules must not leak into SwiftUI bodies.

## SwiftUI & State Management
Keep `body` implementations small and composable. Extract reusable subviews into their own files, and keep one primary top-level `View` per file. Support Dynamic Type, Dark Mode, VoiceOver, and accessibility identifiers for UI tests.

Use the Observation framework patterns already present in the app:

- `@State` for owned `@Observable` instances and value state.
- `@Environment(...)` for injected dependencies.
- `@Binding` for value bindings.
- `@Bindable` when a child view needs bindings into an `@Observable` type.

Avoid `ObservableObject`, `@Published`, `@StateObject`, and `@EnvironmentObject` for new code unless maintaining older code requires it.

## ViewModel Rules
All ViewModels should be `@MainActor @Observable final class` types. Expose state as `private(set)` where callers should not mutate it directly. Use typed UI error state such as `errorMessage: String?`; do not expose raw `Error` values to views.

ViewModels receive services through initializers and should avoid SwiftUI or UIKit dependencies where possible. Log ViewModel-level events with `AppLogger.viewModel`.

For previews and snapshots, add explicit helpers in a `// MARK: - Test Helpers` section, such as `setLoadingForSnapshot(_:)` and `setErrorForSnapshot(_:)`. Do not make state publicly settable only for tests.

## Networking, Errors, and Concurrency
Networking should use `URLSession`, async/await, `Codable`, typed errors, request cancellation, timeout handling, secure headers, and response validation. Keep networking abstractions under `MasterApp/Core/Networking/` and feature data access inside repositories.

Use domain-specific errors such as `NetworkError`. Avoid `fatalError()`, `try!`, force unwraps, force casts, and silently swallowed failures. Errors should be actionable for debugging while preserving a recoverable user experience.

Long-running operations must support cancellation with `try Task.checkCancellation()` where appropriate. UI updates must occur on the MainActor. Use actors for shared mutable state when needed, and respect Swift 6 strict concurrency.

## Logging & Security
Use structured logging through `AppLogger`; never use `print()` in production code. Files using `AppLogger` should import `os` when required by the logging API. Mark interpolated sensitive values as private and avoid logging personally identifiable information.

Never hardcode API keys, tokens, or secrets. Store sensitive data securely, prefer Keychain where appropriate, and use HTTPS-only network flows.

## Testing Guidelines
Use Swift Testing for unit and snapshot tests, and XCTest for UI tests that rely on `XCUIApplication`. New behavior should include focused tests where applicable, especially for ViewModels, services, repositories, async flows, edge cases, and failure handling.

ViewModel tests should be `@MainActor`. Prefer protocol mocks with private mutable state. Keep tests deterministic and avoid testing SwiftUI internals directly.

For snapshot tests, record intentionally with `.all`, inspect the generated baseline, then commit with `.never`. Snapshot test files should import `Testing`, `SnapshotTesting`, `SwiftUI`, and `@testable import MasterApp`.

## Performance, Memory, and Design System
Avoid heavy computation in SwiftUI `body`, unnecessary re-renders, excessive `AnyView`, deep view nesting, blocking the main thread, and unnecessary allocations. Prefer lazy containers for large lists and review performance-sensitive changes with Instruments when needed.

Watch for retain cycles, strong captures in async closures, leaking tasks, and excessive state updates. Reuse design-system primitives from `MasterApp/Core/DesignSystem/` for typography, spacing, colors, buttons, loaders, and error states instead of hardcoding styling.

## Coding Style & Imports
Prefer clarity over brevity. Use explicit names, small focused functions, value types where appropriate, and protocol abstractions at module boundaries. Preserve public APIs unless a breaking change is explicitly requested.

Typical imports:

- Views: `SwiftUI`, plus `os` only when using view logging.
- ViewModels: `Foundation`, `Observation`, plus `os` when needed.
- Services, repositories, and networking: `Foundation`, plus `os` when logging.
- Unit tests: `Testing`, `@testable import MasterApp`, and additional modules only as needed.
- UI tests: `XCTest`.

## Commit & Pull Request Guidelines
Keep commits focused and avoid unrelated refactors. Recent history uses short imperative messages such as `chess added`, `code refactored`, and `fix multiple window sharing same navigation obj issue`; prefer clearer variants like `Add chess module` or `Fix shared navigation state`.

Pull requests should explain what changed, why it changed, and how it was verified. Include screenshots or screen recordings for UI changes. Call out snapshot updates, test-plan changes, migration concerns, and concurrency-sensitive behavior.

## Definition of Done
Before considering work complete, ensure the project compiles, impacted tests pass, accessibility is preserved, architecture boundaries remain intact, cancellation and error paths are handled, concurrency warnings are addressed, and no unrelated files were modified.
