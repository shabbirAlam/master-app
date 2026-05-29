# agents.md

## Project Overview

Modern iOS application built with:

* Swift 6
* SwiftUI
* MVVM
* async/await
* SOLID design principles

---

# Architecture

Follow MVVM architecture.

Rules:

* Views should remain lightweight
* Business logic belongs in ViewModels/UseCases
* Networking should go through repositories
* Prefer protocol abstractions
* Follow SOLID principles across all layers

---

# SwiftUI Rules

* Avoid heavy logic inside body
* Extract reusable components
* Use @StateObject for owned state
* Use @ObservedObject for injected state

---

# Concurrency

Use:

* async/await
* Task
* actors where appropriate

Avoid:

* callback-based APIs
* unnecessary DispatchQueue usage

Always support cancellation for long-running tasks.

---

# Testing

Focus on:

* ViewModel unit tests
* repository tests
* async testing
* UI testing for user flows and navigation
* snapshot/UI validation where appropriate

Avoid testing SwiftUI internals directly, but ensure critical UI behavior and interactions are covered through UI tests.

---

# Project Structure

Features/
Core/
Networking/
DesignSystem/
Tests/

---

# AI Agent Instructions

When generating code:

* preserve architecture consistency
* prefer small reusable components
* avoid unnecessary dependencies
* maintain Swift 6 compatibility
* generate testable code
* apply SOLID principles when designing classes, protocols, and modules

When editing:

* avoid unrelated refactors
* preserve naming conventions
* do not modify public APIs unnecessarily

---

# Code Style

* Prefer clarity over brevity
* Avoid force unwraps
* Use typed errors
* One primary type per file

---

# Performance

* Avoid unnecessary SwiftUI re-renders
* Use lazy containers where appropriate
* Never block the main thread

---

# Security

Never:

* hardcode secrets
* expose API keys
* log sensitive data

## Project Overview

Modern iOS application built with:

* Swift 6
* SwiftUI
* MVVM
* async/await
* modular architecture

---

# Architecture

Follow MVVM architecture.

Rules:

* Views should remain lightweight
* Business logic belongs in ViewModels/UseCases
* Networking should go through repositories
* Prefer protocol abstractions

---

# SwiftUI Rules

* Avoid heavy logic inside body
* Extract reusable components
* Use @StateObject for owned state
* Use @ObservedObject for injected state

---

# Concurrency

Use:

* async/await
* Task
* actors where appropriate

Avoid:

* callback-based APIs
* unnecessary DispatchQueue usage

Always support cancellation for long-running tasks.

---

# Testing

Focus on:

* ViewModel unit tests
* repository tests
* async testing

Avoid testing SwiftUI internals.

---

# Project Structure

Features/
Core/
Networking/
DesignSystem/
Tests/

---

# AI Agent Instructions

When generating code:

* preserve architecture consistency
* prefer small reusable components
* avoid unnecessary dependencies
* maintain Swift 6 compatibility
* generate testable code

When editing:

* avoid unrelated refactors
* preserve naming conventions
* do not modify public APIs unnecessarily

---

# Code Style

* Prefer clarity over brevity
* Avoid force unwraps
* Use typed errors
* One primary type per file

---

# Performance

* Avoid unnecessary SwiftUI re-renders
* Use lazy containers where appropriate
* Never block the main thread

---

# Security

Never:

* hardcode secrets
* expose API keys
* log sensitive data
